DROP INDEX IF EXISTS idx_personne;
CREATE INDEX idx_personne
    ON personne
        using btree (substr(datenaiss, 1, 4),
                     split_part(split_part(REPLACE(nomprenom, '/', ' '), '*', 2), ' ', 1),
                     split_part(nomprenom, '*', 1),
                     lieunaiss);

DROP INDEX IF EXISTS idx_personne_nomprenom_naiss;
CREATE INDEX idx_personne_nomprenom_naiss ON personne (nomprenom, datenaiss, lieunaiss);

DROP INDEX IF EXISTS idx_personne_clean;
CREATE INDEX idx_personne_clean ON personne_clean_m (date_isvalide(datenaiss), date_isvalide(datedeces),
                                             age_positif(datenaiss, datedeces));