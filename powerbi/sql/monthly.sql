-- One row per country and month. deaths_spread: each event's deaths spread evenly over its days
-- (start_date..end_date). deaths_start_month: everything counted in the start month (the naive way).
WITH spread AS (
    SELECT g.country, g.region,
           date_trunc('month', d)::date AS month,
           SUM(g.deaths_best::numeric / (g.end_date - g.start_date + 1)) AS deaths_spread
    FROM ged g
    CROSS JOIN LATERAL generate_series(g.start_date, g.end_date, interval '1 day') AS d
    GROUP BY 1, 2, 3
),
naive AS (
    SELECT country, region, date_trunc('month', start_date)::date AS month,
           SUM(deaths_best) AS deaths_start_month
    FROM ged
    GROUP BY 1, 2, 3
),
rank_2025 AS (
    SELECT country, RANK() OVER (ORDER BY SUM(deaths_best) DESC) AS rank_2025
    FROM ged
    WHERE year = 2025
    GROUP BY country
)
SELECT COALESCE(s.country, n.country) AS country,
       COALESCE(s.region, n.region)   AS region,
       COALESCE(s.month, n.month)     AS month,
       ROUND(COALESCE(s.deaths_spread, 0), 2)  AS deaths_spread,
       COALESCE(n.deaths_start_month, 0)       AS deaths_start_month,
       r.rank_2025
FROM spread s
FULL JOIN naive n ON n.country = s.country AND n.region = s.region AND n.month = s.month
LEFT JOIN rank_2025 r ON r.country = COALESCE(s.country, n.country)
ORDER BY 3, 1
