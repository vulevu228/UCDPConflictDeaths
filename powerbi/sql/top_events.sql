-- Two short lists for the "Datenfallen" page.
-- exact: the 15 deadliest events known to the exact day (date_precision = 1, start = end).
-- multi: the 15 largest rows that cover more than one day (sieges, offensives, yearly summaries).
WITH exact AS (
    SELECT 'exact' AS list, event_id, start_date, end_date, end_date - start_date + 1 AS days, date_precision,
           country, region, conflict_name, violence_type, deaths_best
    FROM ged
    WHERE date_precision = 1
      AND start_date = end_date
    ORDER BY deaths_best DESC
    LIMIT 15
),
multi AS (
    SELECT 'multi' AS list, event_id, start_date, end_date, end_date - start_date + 1 AS days, date_precision,
           country, region, conflict_name, violence_type, deaths_best
    FROM ged
    WHERE end_date > start_date
    ORDER BY deaths_best DESC
    LIMIT 15
)
SELECT * FROM exact
UNION ALL
SELECT * FROM multi
