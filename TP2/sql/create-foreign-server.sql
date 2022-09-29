CREATE EXTENSION postgres_fdw;
	
CREATE SERVER ggmd_prof
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host '192.168.246.201', port '5432', dbname 'insee');

GRANT USAGE ON FOREIGN SERVER ggmd_prof TO etum2;