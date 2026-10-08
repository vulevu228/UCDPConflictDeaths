-- Tote 2025 vs. Vorjahr
-- Metabase visualization: smartscalar

SELECT make_date(year, 1, 1) AS year, SUM(deaths_best) AS deaths
FROM ged
GROUP BY year
ORDER BY year;
