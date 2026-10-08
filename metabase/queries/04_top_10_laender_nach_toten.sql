-- Top 10 Länder nach Toten
-- Metabase visualization: row

SELECT country, SUM(deaths_best) AS total_deaths
FROM ged
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
