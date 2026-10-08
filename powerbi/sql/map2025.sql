-- 2025 events with deaths, snapped to a 0.5 degree grid (about 55 km) so the map stays under
-- Power BI's point limit. One row per grid cell.
SELECT ROUND(latitude * 2) / 2  AS lat,
       ROUND(longitude * 2) / 2 AS lon,
       MIN(country)             AS country,
       MIN(region)              AS region,
       COUNT(*)                 AS events,
       SUM(deaths_best)         AS deaths
FROM ged
WHERE year = 2025
  AND deaths_best > 0
GROUP BY 1, 2
