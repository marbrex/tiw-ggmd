-- Quel est le top 10 des personnes déclarées mortes le plus grand nombre de fois ?
explain (analyse, verbose, costs, buffers, timing, summary, FORMAT JSON)
SELECT nomprenom, datenaiss, lieunaiss, count(datedeces) as NB
FROM personne_clean
GROUP BY nomprenom, datenaiss, lieunaiss
ORDER BY NB DESC
LIMIT 10;

-- Quels sont les homonymes (même nom et même premier prénom) qui sont nés la même année ?
explain (analyse, verbose, costs, buffers, timing, summary, FORMAT JSON)
SELECT split_part(p1.nomprenom, '*', 1)                                        as nom,
       split_part(split_part(REPLACE(p1.nomprenom, '/', ' '), '*', 2), ' ', 1) as prenom
FROM personne p1
         JOIN personne p2 on substr(p1.datenaiss, 1, 4) = substr(p2.datenaiss, 1, 4)
    AND split_part(split_part(REPLACE(p1.nomprenom, '/', ' '), '*', 2), ' ', 1) =
        split_part(split_part(REPLACE(p2.nomprenom, '/', ' '), '*', 2), ' ', 1)
    AND split_part(p1.nomprenom, '*', 1) = split_part(p2.nomprenom, '*', 1)
    AND p1.lieunaiss != p2.lieunaiss
GROUP BY nom, prenom;

-- Quelle est la durée de vie moyenne des personnes selon leur région de naissance ?
explain (analyse, verbose, costs, buffers, timing, summary, FORMAT JSON)
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

SELECT r.reg,
       r.nom,
       justify_interval(((avg(to_date(p.datedeces, 'YYYYMMDD') - to_date(p.datenaiss, 'YYYYMMDD')))::varchar ||
                         ' days')::interval) as age_moyen
FROM region r
         JOIN departement d on r.reg = d.reg
         JOIN commune c on d.dep = c.dep
         JOIN personne_part p on c.com = p.lieunaiss
WHERE date_isvalide(p.datedeces)
  AND date_isvalide(p.datenaiss)
  AND age_positif(p.datenaiss, p.datedeces)
GROUP BY r.reg, r.nom
ORDER BY age_moyen;

--Vues

CREATE OR REPLACE VIEW personne_clean AS
SELECT *
FROM personne
WHERE date_isvalide(datenaiss)
  AND date_isvalide(datedeces)
  AND age_positif(datenaiss, datedeces);

-- Fonctions

CREATE OR REPLACE FUNCTION date_isvalide(date text)
    RETURNS boolean
    LANGUAGE plpgsql
    STRICT
AS
$function$
BEGIN
    RETURN date !~ '^[0-9]{4}[0-9]{2}00$' -- date jour inconnu
        AND date !~ '^[0-9]{4}00[0-9]{2}$' -- date mois inconnu
        AND date !~ '^0000[0-9]{2}[0-9]{2}$' -- date annee inconnue
        AND date !~ '^[0-9]{4}(02|04|06|09|11)31$' -- date 31 d'un mois de moins de 31 jours
        AND date !~ '^[0-9]{4}0230$' -- date 30 février
        AND date NOT LIKE '' -- date date de naissance inconnue
        AND (date !~ '^[0-9]{4}0229$'
            OR (date ~ '^[0-9]{4}0229$'
                AND substr(date, 1, 4)::int % 4 = 0
                AND substr(date, 1, 4) != '1900'
                 )
               );
--         AND to_date(date, 'YYYYMMDD') ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$function$;

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
