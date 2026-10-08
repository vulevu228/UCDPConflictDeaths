-- Tote pro Jahr nach Gewaltart
-- Metabase visualization: area

SELECT make_date(year, 1, 1) AS year, violence_type, SUM(deaths_best) AS deaths
FROM ged
GROUP BY 1, 2
ORDER BY 1;
