-- 01_create_view_ged.sql
-- Clean, readable view on top of the raw UCDP GED import (ged_raw, all text).
-- Renames cryptic columns with AS, casts text to proper types, turns codes into words.
CREATE VIEW ged AS
SELECT
    id::int                                   AS event_id,
    relid                                     AS event_code,
    year::int                                 AS year,
    CASE type_of_violence
        WHEN '1' THEN 'State-based'
        WHEN '2' THEN 'Non-state'
        WHEN '3' THEN 'One-sided (civilians)'
    END                                       AS violence_type,
    conflict_new_id::int                      AS conflict_id,
    conflict_name,
    side_a,
    side_b,
    country,
    region,
    NULLIF(adm_1, '')                         AS province,
    latitude::numeric                         AS latitude,
    longitude::numeric                        AS longitude,
    where_prec::int                           AS location_precision,
    date_start::date                          AS start_date,
    date_end::date                            AS end_date,
    date_prec::int                            AS date_precision,
    deaths_a::int                             AS deaths_side_a,
    deaths_b::int                             AS deaths_side_b,
    deaths_civilians::int                     AS deaths_civilians,
    deaths_unknown::int                       AS deaths_unknown,
    best::int                                 AS deaths_best,
    low::int                                  AS deaths_low,
    high::int                                 AS deaths_high,
    NULLIF(number_of_sources, '-1')::int      AS source_count,
    (low::int > best::int OR best::int > high::int) AS estimate_order_flag
FROM ged_raw;

-- Try it:
SELECT * FROM ged LIMIT 20;
