-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Analysis 1: Who are the most dominant F1 drivers of all time?
-- MAGIC Built from `fact_results` + `dim_drivers`. Uses a custom scoring
-- MAGIC system (10 pts for 1st down to 1 pt for 10th) so eras with different
-- MAGIC official points rules are comparable on equal footing.
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 1) Dominant Drivers with more than 50 races:

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW driver_race_scores AS
SELECT
    r.season,
    r.driver_id,
    d.given_name,
    d.family_name,
    concat(d.given_name, ' ', d.family_name) AS driver_name,
    d.nationality,
    r.position,
    r.points,
    CASE WHEN r.position <= 10 THEN 11 - r.position ELSE 0 END AS calculated_points
FROM f1_presentation.fact_results r
JOIN f1_presentation.dim_drivers d ON r.driver_id = d.driver_id
WHERE r.position IS NOT NULL;

-- COMMAND ----------

SELECT
    driver_name,
    nationality,
    COUNT(1) AS total_races,
    SUM(calculated_points) AS total_points,
    ROUND(AVG(calculated_points), 2) AS avg_points,
    SUM(CASE WHEN position = 1 THEN 1 ELSE 0 END) AS wins
FROM driver_race_scores
GROUP BY driver_name, nationality
HAVING COUNT(1) >= 50
ORDER BY avg_points DESC
LIMIT 15;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 2) Seasons and Total Points by Drivers
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW top_10_drivers AS
SELECT driver_name, AVG(calculated_points) AS avg_calculated_points
FROM driver_race_scores
GROUP BY driver_name
HAVING COUNT(1) >= 50
ORDER BY avg_calculated_points DESC
LIMIT 10;

-- COMMAND ----------

SELECT
    season,
    driver_name,
    COUNT(1) AS races_that_season,
    SUM(calculated_points) AS total_points,
    ROUND(AVG(calculated_points), 2) AS avg_points
FROM driver_race_scores
WHERE driver_name IN (SELECT driver_name FROM top_10_drivers)
GROUP BY season, driver_name
ORDER BY season, avg_points DESC;