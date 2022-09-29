SELECT p.idp, p.nom, p.prenoms
FROM personnes p
JOIN commune cn ON p.lieunaiss=cn.com
JOIN departement dn ON cn.dep=dn.dep
JOIN region rn ON dn.reg=rn.reg

JOIN commune cd ON p.lieudeces=cd.com
JOIN departement dd ON cd.dep=dd.dep
JOIN region rd ON dd.reg=rd.reg

WHERE rn.nom = 'Hauts-de-France' AND rd.nom = 'Occitanie'