-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Analysis 4: How has pit stop speed evolved by constructor over time?
-- MAGIC `fact_pit_stops` doesn't carry constructor_id directly. Therefore, it's joined
-- MAGIC through `fact_results` on (season, round, driver_id) to attach each
-- MAGIC pit stop to the team that performed it, then to `dim_constructors`
-- MAGIC for the display name.
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 1) Fastest pit crews of all time with minimum 50 stops:

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW pit_stops_with_constructor AS
SELECT
    p.season,
    p.round,
    p.driver_id,
    r.constructor_id,
    c.name AS constructor_name,
    p.stop,
    p.duration
FROM f1_presentation.fact_pit_stops p
JOIN f1_presentation.fact_results r
    ON p.season = r.season AND p.round = r.round AND p.driver_id = r.driver_id
JOIN f1_presentation.dim_constructors c
    ON r.constructor_id = c.constructor_id
WHERE p.duration IS NOT NULL;

-- COMMAND ----------

SELECT
    constructor_name,
    COUNT(1) AS total_stops,
    ROUND(AVG(duration), 3) AS avg_pit_stop_seconds,
    ROUND(MIN(duration), 3) AS fastest_stop_seconds
FROM pit_stops_with_constructor
GROUP BY constructor_name
HAVING COUNT(1) >= 50
ORDER BY avg_pit_stop_seconds ASC
LIMIT 15;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 2) Top 2 Fastest Crew by Seasons:

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW top_5_fastest_crews AS
SELECT constructor_name, AVG(duration) AS avg_duration
FROM pit_stops_with_constructor
GROUP BY constructor_name
HAVING COUNT(1) >= 50
ORDER BY avg_duration ASC
LIMIT 5;


-- COMMAND ----------

SELECT
    season,
    constructor_name,
    COUNT(1) AS stops_that_season,
    ROUND(AVG(duration), 3) AS avg_pit_stop_seconds
FROM pit_stops_with_constructor
WHERE constructor_name IN (SELECT constructor_name FROM top_5_fastest_crews)
GROUP BY season, constructor_name
ORDER BY season, avg_pit_stop_seconds ASC;