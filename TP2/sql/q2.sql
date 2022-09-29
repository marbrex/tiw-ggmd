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