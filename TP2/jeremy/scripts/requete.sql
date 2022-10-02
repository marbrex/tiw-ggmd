-- Quel est le top 10 des personnes déclarées mortes le plus grand nombre de fois ?
explain (analyse, verbose, costs, buffers, timing, summary, FORMAT JSON)
SELECT nomprenom, datenaiss, lieunaiss, count(datedeces) as NB
FROM personne
GROUP BY nomprenom, datenaiss, lieunaiss
ORDER BY NB DESC
LIMIT 10;

-- Quels sont les homonymes (même nom et même premier prénom) qui sont nés la même année ?
explain (analyse, verbose, costs, buffers, timing, summary, FORMAT JSON)
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
