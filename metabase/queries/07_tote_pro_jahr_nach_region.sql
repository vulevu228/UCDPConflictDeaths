-- Tote pro Jahr nach Region
-- Metabase visualization: bar

SELECT make_date(year, 1, 1) AS year, region, SUM(deaths_best) AS deaths
FROM ged
GROUP BY 1, 2
ORDER BY 1;
