-- Anteil Zivilisten %
-- Metabase visualization: scalar

select round(100.0 * sum(deaths_civilians) / sum(deaths_best), 1) as civilian_share
from ged;
