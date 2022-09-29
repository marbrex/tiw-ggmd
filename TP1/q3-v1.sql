SELECT COUNT(*)
FROM personnes p
LEFT OUTER JOIN commune c ON p.lieunaiss=c.com
WHERE c is NULL