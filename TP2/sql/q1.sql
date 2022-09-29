EXPLAIN (analyse, verbose, costs, buffers, timing, summary, format json)
SELECT p.nomprenom, p.datenaiss, p.lieunaiss, COUNT(*) as nb
FROM personne p
GROUP BY p.nomprenom, p.datenaiss, p.lieunaiss
ORDER BY nb DESC
LIMIT 10;