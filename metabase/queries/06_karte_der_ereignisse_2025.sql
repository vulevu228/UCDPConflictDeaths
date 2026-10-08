-- Karte der Ereignisse 2025
-- Metabase visualization: map

SELECT latitude, longitude, country, conflict_name, start_date, deaths_best
FROM ged
WHERE year = 2025 AND deaths_best > 0;
