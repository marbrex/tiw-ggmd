CREATE USER MAPPING
FOR CURRENT_USER
SERVER ggmd_prof
OPTIONS(user 'etum2', password 'etum2');

CREATE FOREIGN TABLE remote_region(
	reg varchar(5),
	nom varchar(254),
	cheflieu varchar(10),
	zone smallint
)
SERVER ggmd_prof
OPTIONS (schema_name 'public', table_name 'region');

CREATE TABLE region AS (SELECT * FROM remote_region);

DROP FOREIGN TABLE remote_region;

CREATE FOREIGN TABLE remote_departement(
	dep varchar(5),
	nom varchar(254),
	cheflieu varchar(10),
	reg varchar(5)
)
SERVER ggmd_prof
OPTIONS (schema_name 'public', table_name 'departement');

CREATE TABLE departement AS (SELECT * FROM remote_departement);

DROP FOREIGN TABLE remote_departement;

CREATE FOREIGN TABLE remote_commune(
	com varchar(5),
	nom varchar(254),
	dep varchar(5)
)
SERVER ggmd_prof
OPTIONS (schema_name 'public', table_name 'commune');

CREATE TABLE commune AS (SELECT * FROM remote_commune);

DROP FOREIGN TABLE remote_commune;