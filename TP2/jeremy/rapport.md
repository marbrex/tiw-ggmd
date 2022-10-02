# A - Les requêtes SQL

## Q1. Quel est le top 10 des personnes déclarées mortes le plus grand nombre de fois ?

```sql
SELECT nomprenom, datenaiss, lieunaiss, count(datedeces) as NB
FROM personne
GROUP BY nomprenom, datenaiss, lieunaiss
ORDER BY NB DESC
LIMIT 10;
```

## Q2. Quels sont les homonymes (même nom et même premier prénom) qui sont nés la même année ?

```sql
SELECT split_part(p1.nomprenom, '*', 1)                                        as nom,
       split_part(split_part(REPLACE(p1.nomprenom, '/', ' '), '*', 2), ' ', 1) as prenom
FROM personne p1
         JOIN personne p2
              ON substr(p1.datenaiss, 1, 4) = substr(p2.datenaiss, 1, 4)
                  AND split_part(split_part(REPLACE(p1.nomprenom, '/', ' '), '*', 2), ' ', 1) =
                      split_part(split_part(REPLACE(p2.nomprenom, '/', ' '), '*', 2), ' ', 1)
                  AND split_part(p1.nomprenom, '*', 1) = split_part(p2.nomprenom, '*', 1)
                  AND p1.lieunaiss != p2.lieunaiss
GROUP BY nom, prenom;
```

## Q3. Quel est la durée de vie moyenne des personnes selon leur région de naissance ?

On crée une fonction qui retourne si une date est valide ou non.

```sql
CREATE OR REPLACE FUNCTION date_isvalide(date text)
    RETURNS boolean
    LANGUAGE plpgsql
    STRICT
    IMMUTABLE
AS
$function$
BEGIN
    RETURN date !~ '^[0-9]{4}[0-9]{2}00$'                   -- jour inconnu
        AND date !~ '^[0-9]{4}00[0-9]{2}$'                  -- mois inconnu
        AND date !~ '^0000[0-9]{2}[0-9]{2}$'                -- annee inconnue
        AND date !~ '^[0-9]{4}(02|04|06|09|11)31$'          -- 31 d'un mois de moins de 31 jours
        AND date !~ '^[0-9]{4}0230$'                        -- 30 février
        AND date NOT LIKE ''                                -- date de naissance inconnue
        AND (date !~ '^[0-9]{4}0229$'
            OR (date ~ '^[0-9]{4}0229$'
                AND substr(date, 1, 4)::int % 4 = 0
                AND substr(date, 1, 4) != '1900'
                 )
               );                                           -- 29 février bissextile
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$function$;
```

On crée une fonction qui retourne si l'age est positif ou non.

```sql
CREATE OR REPLACE FUNCTION age_positif(datenaiss text, datedeces text)
    RETURNS boolean
    LANGUAGE plpgsql
    STRICT
    IMMUTABLE
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

On crée une vue qui contient les personnes avec des données sur les dates correctes.

```sql
CREATE OR REPLACE VIEW personne_clean AS
SELECT *
FROM personne
WHERE date_isvalide(datenaiss)
  AND date_isvalide(datedeces)
  AND age_positif(datenaiss, datedeces);
```
La requête 

```sql
SELECT r.reg,
       r.nom,
       count(p.*)                            as nb,
       justify_interval(((avg(to_date(p.datedeces, 'YYYYMMDD') - to_date(p.datenaiss, 'YYYYMMDD')))::varchar ||
                         ' days')::interval) as age_moyen
FROM region r
         JOIN departement d on r.reg = d.reg
         JOIN commune c on d.dep = c.dep
         JOIN personne_clean p on c.com = p.lieunaiss
GROUP BY r.reg, r.nom
ORDER BY age_moyen DESC;
```

# B - Traitement des requêtes sur grp-XX-small

## Experimentations GGMD1

### Q1
Execution time: 5m 24s  
Planning time: 232ms  
Cout : 5 490 000  
[Plan d'exécution json](plan_execution/small/q1/Q1_small_base_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q1/Q1_small_base_on_personne.png)  
[Statistiques](plan_execution/small/q1/Q1_small_base_on_personne_stats.png)  

### Q2
Execution time: N/A  
Planning time: N/A  
Cout : 13 200 000  
[Plan d'exécution json](plan_execution/small/q2/Q2_small_base_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q2/Q2_small_base_on_personne.png)  
[Statistiques](plan_execution/small/q2/Q2_small_base_on_personne_stats.png)  

Erreur générée:
```log
[53100] ERROR: could not write to file "base/pgsql_tmp/pgsql_tmp19593.1": No space left on device
```

### Q3
Execution time: 6m 16s  
Planning time: 8,4ms  
Cout : 19 300 000  
[Plan d'exécution json](plan_execution/small/q3/Q3_small_base_on_personne_clean.json)  
[Plan d'exécution image](plan_execution/small/q3/Q3_small_base_on_personne_clean.png)  
[Statistiques](plan_execution/small/q3/Q3_small_base_on_personne_clean_stats.png)  

## Expérimentations GGMD1 - Index 

### Q1
Execution time:   
Planning time:   
Cout :  
[Plan d'exécution json](plan_execution/small/q1/Q1_small_index_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q1/Q1_small_index_on_personne.png)  
[Statistiques](plan_execution/small/q1/Q1_small_index_on_personne_stats.png)  

### Q2
Execution time:   
Planning time:   
Cout :  
[Plan d'exécution json](plan_execution/small/q2/Q2_small_index_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q2/Q2_small_index_on_personne.png)  
[Statistiques](plan_execution/small/q2/Q2_small_index_on_personne_stats.png)  

### Q3
Execution time:   
Planning time:   
Cout :  
[Plan d'exécution json](plan_execution/small/q3/Q3_small_index_on_personne_clean.json)  
[Plan d'exécution image](plan_execution/small/q3/Q3_small_index_on_personne_clean.png)  
[Statistiques](plan_execution/small/q3/Q3_small_index_on_personne_stats_clean.png)  

## Expérimentations GGMD1 - configuration 

### Changement de la configuration de la base de données

| parametre | ancienne valeur | nouvelle valeur |
|-|-|-|
| shared_buffers | 128MB | 1024MB |
| effective_cache_size | unsued | 1024MB |
| wal_sync_method |unused | fsync |
| wal_buffers | unused | -1 |
| max_connections | 100 | 10 |
| work_mem | unused | 512MB |
| maintenance_work_mem | unused | 1024MB |
| autovacuum_work_mem | unused | -1 |
| autovacuum | unused | on |
| track_counts | unused | on |

### Q1
Execution time: 8m 17s  
Planning time: 196ms  
Cout : 3 890 000  
[Plan d'exécution json](plan_execution/small/q1/Q1_small_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q1/Q1_small_config_opti_on_personne.png)  
[Statistiques](plan_execution/small/q1/Q1_small_config_opti_on_personne_stats.png)  

Le plan d'execution est simplifié et le cout diminué mais le temps d'execution est allongé.

### Q2

Execution time: N/A  
Planning time: N/A  
Cout :  11 500 000  
[Plan d'exécution json](plan_execution/small/q2/Q2_small_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/small/q2/Q2_small_config_opti_on_personne.png)  
[Statistiques](plan_execution/small/q2/Q2_small_config_opti_on_personne_stats.png)

Erreur générée:
```log
[57P02] terminating connection because of crash of another server process
```

Le plan d'execution n'est pas modifié et postgreql crash en executant la requête.

### Q3

Execution time: 8m 28s  
Planning time: 2s 323ms  
Cost : 19 300 000  
[Plan d'exécution json](plan_execution/small/q3/Q3_small_config_opti_on_personne_clean.json)  
[Plan d'exécution image](plan_execution/small/q3/Q3_small_config_opti_on_personne_clean.png)  
[Statistiques](plan_execution/small/q3/Q3_small_config_opti_on_personne_clean_stats.png)  

Le plan d'execution n'est pas modifié et le cout est le même mais le temps d'execution ainsi que celui de planification sont allongés.

# C - Traitement des requêtes sur grp-XX-medium

## Expérimentations GGMD1

### Q1
Execution time: 6m 57s  
Planning time: 117ms  
Cout : 5 490 000  
[Plan d'exécution json](plan_execution/medium/q1/Q1_medium_base_on_personne.json)  
[Plan d'exécution image](plan_execution/medium/q1/Q1_medium_base_on_personne.png)  
[Statistiques](plan_execution/medium/q1/Q1_medium_base_on_personne_stats.png)  

### Q2
Execution time: 40m 40s  
Planning time: 3,59ms  
Cout : 13 200 000  
[Plan d'exécution json](plan_execution/medium/q2/Q2_medium_base_on_personne.json)  
[Plan d'exécution image](plan_execution/medium/q2/Q2_medium_base_on_personne.png)  
[Statistiques](plan_execution/medium/q2/Q2_medium_base_on_personne_stats.png)  

### Q3
Execution time: 11m 27s  
Planning time: 242ms  
Cost : 19 300 000  
[Plan d'exécution json](plan_execution/medium/q3/Q3_medium_base_on_personne_clean.json)  
[Plan d'exécution image](plan_execution/medium/q3/Q3_medium_base_on_personne_clean.png)  
[Statistiques](plan_execution/medium/q3/Q3_medium_base_on_personne_clean_stats.png)  

## Expérimentations GGMD2 - Index 

Création d'un index sur les colonnes "nomprenom", "datenaiss" et "lieunaiss" de la table "personne" car le plan d'execution de la requête Q1 montre que ces colonnes sont utilisées pour le tri.
```sql 
CREATE INDEX idx_personne_nomprenom_naiss ON personne (nomprenom, datenaiss, lieunaiss);
```
Mauvaise idée, la requête Q1 est beaucoup plus longue à s'exécuter et le cout est plus élevé.

### Q1
Execution time: N/A (plus de 1h)   

### Problèmes rencontrés

Je ne comprends pas comment créer des index efficaces.

Je ne fais donc pas plus sur cette partie.

## Expérimentations GGMD2 - configuration

Même configuration que pour la vm small car ici plus de ressources sont disponibles mais on a vu que sur small les changements de configuration ont fait crashé postgresql. 

### Q1
Execution time: 8m 16s  
Planning time: 416ms  
Cout : 3 890 000
[Plan d'exécution json](plan_execution/medium/q1/Q1_medium_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/medium/q1/Q1_medium_config_opti_on_personne.png)  
[Statistiques](plan_execution/medium/q1/Q1_medium_config_opti_on_personne_stats.png)  

### Q2
Execution time: 22m 45s  
Planning time: 1,16ms  
Cout : 11 500 000  
[Plan d'exécution json](plan_execution/medium/q2/Q2_medium_config_opti_on_personne.json)  
[Plan d'exécution image](plan_execution/medium/q2/Q2_medium_config_opti_on_personne.png)  
[Statistiques](plan_execution/medium/q2/Q2_medium_config_opti_on_personne_stats.png)  

Le temps d'éxécution, le temps de planification et le cout sont diminués.