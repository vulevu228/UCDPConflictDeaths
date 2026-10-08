-- 02_levels_1-3.sql
-- UCDP GED tasks, Levels 1-3 (view: ged). Comments explain the key concept of each query.

--LEVEL 1

--1 Show event_code, country, start_date and deaths_best for the 10 deadliest events.
-- No aggregate (sum/count/...) -> no GROUP BY needed: we just want individual rows.
-- LIMIT keeps only the first n rows AFTER sorting.
select event_code, country, start_date, deaths_best from ged
order by deaths_best desc
limit 10;

--2 How many events happened in Ukraine?
-- count(*) counts rows (= events, one row per event); count(col) would skip NULLs in col.
-- WHERE filters rows BEFORE grouping. country can be selected because it is in the GROUP BY
-- (it has one value per bucket).
select count(*) as event_count, country, sum(deaths_best) as total_deaths from ged
where country = 'Ukraine'
group by country;

--3 List all events in Germany. Look at side_a and side_b: what were they? (There are 6, and you'll recognise some.)
-- DISTINCT removes rows that are identical in ALL selected columns.
-- (Not needed here: event_code is unique, so no two rows can be identical.)
select distinct event_code, country, province, side_a, side_b, deaths_best, start_date from ged
where country = 'Germany'
order by start_date desc;

--4 Events in Syria during 2024 with 50 or more deaths, newest first.
-- FIX: removed GROUP BY (no aggregate -> it would only merge look-alike rows silently)
--      and the end_date filter (it dropped events starting in Dec 2024 and ending in 2025).
-- Half-open date range: >= first day AND < first day of the next period -> never misses a day.
select country, start_date, end_date, deaths_best from ged
where country = 'Syria'
  and start_date >= '2024-01-01' and start_date < '2025-01-01'
  and deaths_best >= 50
order by start_date desc;

--5 How many events have no province (NULL)? Why might that be?
-- NULL means "unknown/missing": test it with IS NULL (= NULL never matches anything).
-- Grouping by location_precision explains WHY: 6 = only country known, 5 = along a road/river/border,
-- 7 = at sea/in the air. Exception: Bosnia-Herzegovina has exact places but no provinces (data gap).
select location_precision, count(*) from ged
where province is null
group by location_precision
order by location_precision;

--LEVEL 2

--6. Total deaths per violence_type, largest first.
-- GROUP BY puts rows into buckets (one per violence_type); sum() turns each bucket into one number.
-- Rule: every selected column is either in GROUP BY or inside an aggregate.
-- The measure (deaths_best) goes INSIDE sum(), never into GROUP BY.
select violence_type, sum(deaths_best) as total_deaths from ged
group by violence_type
order by total_deaths desc;

--7. Top 3 countries by total deaths since 1989.
-- start_date has many values per country bucket -> it can only appear inside an aggregate:
-- min()/max() turn all dates of a country into one value (first and last event).
select country,
    sum(deaths_best) as total_deaths,
    min(start_date) as first_event,
    max(start_date) as last_event
from ged
where start_date >= '1989-01-01'
group by country
order by total_deaths desc
limit 3;

--8. The deadliest year in the whole dataset.
-- The bucket defines the question: group by year -> one total per year.
-- (Grouping by start_date would give one total per DAY.)
select year,
       sum(deaths_best) as total_deaths
from ged
group by year
order by total_deaths desc
limit 1;

--9. How many distinct countries appear?
-- count(distinct col) counts unique values, not rows.
select count(distinct country) from ged;

--10. How many conflicts have more than 10,000 deaths in total? (Use HAVING.)
-- Two steps: inner query = one row per conflict, HAVING keeps only the big ones;
-- outer query counts those rows.
-- HAVING filters BUCKETS after grouping (can use sum); WHERE filters ROWS before grouping (cannot).
-- Execution order: FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT.
select count(*) as conflicts_over_10000 from (
    select conflict_id
    from ged
    group by conflict_id
    having sum(deaths_best) > 10000
) as big_conflicts;

--11. Share of civilian deaths out of all deaths, in % with 1 decimal place.
-- FIX: written out (was commented out).
-- No GROUP BY -> the aggregates cover the whole table and return ONE row.
-- 100.0 (with a decimal point) avoids integer division: int / int drops the decimals (-> 0).
-- round(value, n) rounds to n decimal places.
select round(100.0 * sum(deaths_civilians) / sum(deaths_best), 1) as civilian_share_pct
from ged;

--12. The deadliest region in 2025.
-- WHERE first keeps only 2025 rows, THEN they are grouped into regions.
select region, sum(deaths_best) as total_deaths from ged
where year = 2025
group by region
order by total_deaths desc
limit 1;

--LEVEL 3

--13. Ukraine deaths per year, 2021–2025.
-- FIX: year is an integer -> compare with numbers, not text ('2021').
-- BETWEEN a AND b includes both ends (same as >= a and <= b).
select sum(deaths_best) as total_deaths, year from ged
where country = 'Ukraine' and year between 2021 and 2025
group by year
order by year desc;

--14. Deaths per weekday in Ukraine, exact dates only (date_precision = 1).
-- to_char(date, 'Day') = weekday name as text; extract(isodow ...) = weekday number 1 (Mon) .. 7 (Sun).
-- Group by both: the name for display, the number for correct sorting (names sort alphabetically).
-- date_precision = 1 keeps only events with an exact day; others have no meaningful weekday.
select to_char(start_date, 'Day') as weekday,
       extract(isodow from start_date) as day_no,
       sum(deaths_best) as deaths
from ged
where country = 'Ukraine' and date_precision = 1
group by weekday, day_no
order by day_no asc;

--15. Sort events into size classes with CASE: 0, 1-9, 10-99, 100-999, 1000+, and count each class.
-- CASE = if/else: checks WHEN conditions top to bottom and returns the FIRST match.
-- Biggest class first, so plain >= is enough (larger values are already caught above).
-- A CASE result is a new column -> it can be grouped by like any other column.
-- order by min(deaths_best) sorts classes by size; sorting the text labels would put '1000+' before '1-9'.
select case when deaths_best = 0 then '0'
               when deaths_best >= 1000 then '1000+'
               when deaths_best >= 100 then '100-999'
               when deaths_best >= 10 then '10-99'
               else '1-9'
           end as size_class,
           count(*) as events
from ged
group by size_class
order by min(deaths_best);

--16. With a CTE (WITH ...): the deadliest conflict of each year, 2015–2025.
-- CTE = a named temporary result that exists only during this query (step 1: totals per year + conflict).
-- Filter inside the CTE so it only sums the years we need.
-- DISTINCT ON (year) = PostgreSQL-only "keep the FIRST row per year"; ORDER BY decides which row is first
-- (year, then biggest total). The DISTINCT ON column must come first in ORDER BY.
-- Portable alternative: max per year in a 2nd CTE + JOIN, or ROW_NUMBER() (Level 4).
with conflict_year as(
    select year, conflict_name, sum(deaths_best) as total_deaths
    from ged
    where year between 2015 and 2025
    group by year, conflict_name
)
select distinct on (year) year, conflict_name, total_deaths
from conflict_year
order by year, total_deaths desc;

--17. The deadliest single day in Ukraine.
-- Check what one row means before aggregating: one UCDP row can be a 2-month siege (Mariupol, precision 5).
-- date_precision = 1 keeps only exact-day events.
-- A day = all its events added up -> sum() per start_date (max() would give the deadliest EVENT of a day).
-- Result: 2022-03-16, 719 deaths (600 in the Mariupol theatre strike).
select start_date, to_char(start_date, 'Day') as weekday,
       sum(deaths_best) as deaths,
       count(*) as events
from ged
where country = 'Ukraine' and date_precision = 1
group by start_date
order by deaths desc
limit 1;
