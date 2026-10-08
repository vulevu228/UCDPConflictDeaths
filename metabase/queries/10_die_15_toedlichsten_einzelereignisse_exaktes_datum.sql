-- Die 15 tödlichsten Einzelereignisse (exaktes Datum)
-- Metabase visualization: table

SELECT start_date, country, conflict_name, violence_type, deaths_best
FROM ged
WHERE date_precision = 1
  AND start_date = end_date
ORDER BY deaths_best DESC
LIMIT 15;
