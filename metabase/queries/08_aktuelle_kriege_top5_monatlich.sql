-- Aktuelle Kriege: Top 5 Länder 2025, monatlich (lange Ereignisse auf Tage verteilt)
-- Metabase visualization: line

WITH top5 AS (
    SELECT country
    FROM ged
    WHERE year = 2025
    GROUP BY country
    ORDER BY SUM(deaths_best) DESC
    LIMIT 5
),
daily AS (
    SELECT g.country,
           d::date AS day,
           g.deaths_best::numeric / (g.end_date - g.start_date + 1) AS deaths
    FROM ged g
    CROSS JOIN LATERAL generate_series(g.start_date, g.end_date, interval '1 day') AS d
    WHERE g.country IN (SELECT country FROM top5)
      AND g.end_date >= DATE '2023-01-01'
)
SELECT date_trunc('month', day)::date AS month,
       country,
       ROUND(SUM(deaths)) AS deaths
FROM daily
WHERE day >= DATE '2023-01-01'
GROUP BY 1, 2
ORDER BY 1;
