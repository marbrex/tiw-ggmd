SELECT m.adresse, m.email
FROM mairie m
JOIN personnes p ON m.codeInsee=p.lieunaiss
JOIN commune cd ON p.lieudeces=cd.com
WHERE cd.dep='63' AND to_char(p.datedeces, 'yyyy-mm')='2018-04'