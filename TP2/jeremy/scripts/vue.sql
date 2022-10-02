CREATE OR REPLACE VIEW personne_clean AS
SELECT *
FROM personne
WHERE date_isvalide(datenaiss)
  AND date_isvalide(datedeces)
  AND age_positif(datenaiss, datedeces);


DROP MATERIALIZED VIEW IF EXISTS personne_clean_m;

CREATE MATERIALIZED VIEW personne_clean_m AS
SELECT *
FROM personne
WHERE date_isvalide(datenaiss)
  AND date_isvalide(datedeces)
  AND age_positif(datenaiss, datedeces);
