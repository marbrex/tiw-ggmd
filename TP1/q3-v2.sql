SELECT COUNT(*)
FROM personnes p
WHERE p.lieunaiss NOT IN
(SELECT com FROM commune)