---
tags: [TP]
aliases: ["GGMD TP2", "TP2 GGMD", "TP2"]
---

# TP2 de GGMD
Binôme:
- Eldar Kasmamytov p1712650
- Jérémy Gau p2111894

[Dépot du code](https://forge.univ-lyon1.fr/p2111894/ggmd_tp2_code.git)

A - Les requêtes SQL
---

```bash
psql --host=localhost --username=etum2 -d insee -f ~/tp2/sql/q0.sql > analyze-q0.json
```

### Importer les regions, les departements et les communes de *ggmd_prof*

Importer les scripts SQL du TP1 (voir [[tp1-ggmd|GGMD TP1]]) sur chacune des VMs. Après:

```bash
# en tant qu'admin
psql -h localhost -U postgres -d insee -f ~/tp2/sql/create-foreign-server.sql

# en tant qu'etum2
psql -h localhost -U etum2 -d insee -f ~/tp2/sql/import-data.sql
```

### 2 - Quelles différences observez-vous entre la table 'personnes' et la table 'personne'?

**Réponse:** La différence entre les tables *'personnes'* et *'personne'* est que dans la première nous avons les données non traitées provenant directement de la base de données de l'INSEE, tandis que la deuxième ne contient que les données traitées préalablement. 

### 3 - Les requêtes SQL

#### Q1

```sql
EXPLAIN (analyse, verbose, costs, buffers, timing, summary, format json)
SELECT p.nomprenom, p.datenaiss, p.lieunaiss, COUNT(p.datedeces) as nb
FROM personne p
GROUP BY p.nomprenom, p.datenaiss, p.lieunaiss
ORDER BY nb DESC
LIMIT 10;
```

- Small: 16m 10s
- Medium: 6m 43s
- Large: 1m 12s

#### Q2

```sql
SELECT split_part(p1.nomprenom, '*', 1) as nom, 
       split_part(split_part(REPLACE(p1.nomprenom, '/', ' '), '*', 2), ' ', 1) as prenom  
FROM personne p1
     JOIN personne p2 on substr(p1.datenaiss, 1, 4) = substr(p2.datenaiss, 1, 4)  
          AND split_part(split_part(REPLACE(p1.nomprenom, '/', ' '), '*', 2), ' ', 1) = split_part(split_part(REPLACE(p2.nomprenom, '/', ' '), '*', 2), ' ', 1)  
          AND split_part(p1.nomprenom, '*', 1) = split_part(p2.nomprenom, '*', 1)  
          AND p1.lieunaiss != p2.lieunaiss  
GROUP BY nom, prenom;
```

- Small: échoue (voir la section B.2)
- Medium: 
- Large: 

#### Q3

```sql
SELECT r.reg,
       r.nom,
       count(p.*) as nb,
       justify_interval(((avg(to_date(p.datedeces, 'YYYYMMDD') -to_date(p.datenaiss, 'YYYYMMDD')))::varchar || ' days')::interval) as age_moyen
FROM region r
     JOIN departement d on r.reg = d.reg
     JOIN commune c on d.dep = c.dep
     JOIN personne_clean p on c.com = p.lieunaiss
GROUP BY r.reg, r.nom
ORDER BY age_moyen DESC;
```

- Small: 
- Medium: 
- Large: 

Pour pouvoir utiliser la fonction `TO_DATE` sans aucun problème, nous avons créé 2 fonctions SQL auxiliaires qui ont pour but de produire une vue `personne_clean` qui ne contient que des **données "propres"** (éliminer les dates pas existantes, par exemple: 30 février).

La définition de la vue:
```sql
CREATE OR REPLACE VIEW personne_clean AS (
  SELECT *  
  FROM personne  
  WHERE date_isvalide(datenaiss)  
    AND date_isvalide(datedeces)  
    AND age_positif(datenaiss, datedeces)
);
```

Une fonction pour vérifier si la date en entrée est valide ou pas:
```sql
CREATE OR REPLACE FUNCTION date_isvalide(date text)
  RETURNS boolean
  LANGUAGE plpgsql
  STRICT
AS
$function$
BEGIN
  RETURN date !~ '^[0-9]{4}[0-9]{2}00$'         -- date jour inconnu  
     AND date !~ '^[0-9]{4}00[0-9]{2}$'         -- date mois inconnu  
     AND date !~ '^0000[0-9]{2}[0-9]{2}$'       -- date annee inconnue  
     AND date !~ '^[0-9]{4}(02|04|06|09|11)31$' -- date 31 d'un mois de moins de 31 jours  
     AND date !~ '^[0-9]{4}0230$' -- date 30 février  
     AND date NOT LIKE ''         -- date date de naissance inconnue  
     AND (date !~ '^[0-9]{4}0229$'
       OR (date ~ '^[0-9]{4}0229$'
         AND substr(date, 1, 4)::int % 4 = 0
         AND substr(date, 1, 4) != '1900'
       )
     );
  EXCEPTION
    WHEN others THEN
      RETURN FALSE;
END;
$function$;
```

Une fonction pour vérifier si l'age d'une personne est positif:
```sql
CREATE OR REPLACE FUNCTION age_positif(datenaiss text, datedeces text)
  RETURNS boolean
  LANGUAGE plpgsql
  STRICT
AS
$function$
BEGIN
  RETURN to_date(datedeces, 'YYYYMMDD') - to_date(datenaiss, 'YYYYMMDD') > 0;  
  EXCEPTION
    WHEN others THEN
      RETURN FALSE;
END;
$function$;
```

### 4 - Les valeurs des paramètres des fichiers de configuration

Le seul paramètre actif dans les configurations des VMs est:
- **shared_buffers**: 128 MB (pour toutes les VMs)

Les autres sont commentés.

B - Traitement des requêtes sur grp-XX-small
---

### 1 - Les requêtes pouvant être traitées sur la VM Small

Les requêtes pouvant être traitées sur la VM Small sont: **Q1** et **Q3**.

#### Les plans d'exécution:

Après avoir généré les plans d'exécution des requêtes SQL avec
```sql
EXPLAIN (analyse, verbose, costs, buffers, timing, summary, format json)
-- REQUETE SQL ...
```
et en les éditant sur [Explain Dalibo](https://explain.dalibo.com), on obtient les résultats suivants:

##### La requête Q1:
![Q1](assets/q1-small-plan-exec-no-optim.png)

##### La requête Q3:
![Q3](assets/q3-small-plan-exec-no-optim.png)

### 2 - L'exécution d'une requête qui n'a pas pu aboutir

L'exécution de la requête **Q2** entraîne une erreur:

```log
[53100] ERROR: could not write to file "base/pgsql_tmp/pgsql_tmp19593.1": No space left on device
```

L'erreur est survenue à cause d'**espace de stockage insuffisant** pour sauvegarder des résultats intermédiaires de la requête.

#### Le plan d'exécution de la Q2:
![Q2](assets/q2-small-plan-exec-error.png)

### 3 - Solutions possibles

Le résultat de la commande ci-dessous montre qu'il n'y a que **3.3 GB d'espace disponible** sur la VM Small.
```bash
ubuntu@grp-27-small:/tmp$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1       9.6G  6.3G  3.3G  66% /
# ...
```
Une des solutions est d'augmenter l'espace attribué à cette VM.

### 4 - Appliquer un protocole de résolution

