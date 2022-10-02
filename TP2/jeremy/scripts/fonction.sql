CREATE OR REPLACE FUNCTION date_isvalide(date text)
    RETURNS boolean
    LANGUAGE plpgsql
    STRICT
    IMMUTABLE
AS
$function$
BEGIN
    RETURN date !~ '^[0-9]{4}[0-9]{2}00$' -- date jour inconnu
        AND date !~ '^[0-9]{4}00[0-9]{2}$' -- date mois inconnu
        AND date !~ '^0000[0-9]{2}[0-9]{2}$' -- date annee inconnue
        AND date !~ '^[0-9]{4}(02|04|06|09|11)31$' -- date 31 d'un mois de moins de 31 jours
        AND date !~ '^[0-9]{4}0230$' -- date 30 février
        AND date NOT LIKE '' -- date date de naissance inconnue
        AND (date !~ '^[0-9]{4}0229$'
            OR (date ~ '^[0-9]{4}0229$'
                AND substr(date, 1, 4)::int % 4 = 0
                AND substr(date, 1, 4) != '1900'
                 )
               );
--         AND to_date(date, 'YYYYMMDD') ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$function$;

CREATE OR REPLACE FUNCTION age_positif(datenaiss text, datedeces text)
    RETURNS boolean
    LANGUAGE plpgsql
    STRICT
    IMMUTABLE
AS
$function$
BEGIN
    RETURN to_date(datedeces, 'YYYYMMDD') - to_date(datenaiss, 'YYYYMMDD') > 0;
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$function$;
