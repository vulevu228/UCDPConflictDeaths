-- Gewaltart nach Region
-- Metabase visualization: treemap

SELECT region, violence_type, SUM(deaths_best) AS deaths
FROM ged
GROUP BY 1, 2;
