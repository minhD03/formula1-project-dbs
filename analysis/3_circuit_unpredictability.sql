-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Analysis 3: Which circuits produce the most unpredictable races?
-- MAGIC "Unpredictable" is measured as the average absolute difference between
-- MAGIC starting grid position and final race position - a circuit where
-- MAGIC drivers frequently gain/lose many places (overtaking-friendly, high
-- MAGIC strategy variance, high attrition) scores higher than a circuit where
-- MAGIC grid position basically decides the finish (e.g. Monaco).
-- MAGIC
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 1) Most unpredictable circuits (min 10 races)

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW race_position_changes AS
SELECT
    r.season,
    r.round,
    r.circuit_id,
    c.circuit_name,
    c.country,
    r.driver_id,
    r.grid,
    r.position,
    ABS(r.grid - r.position) AS position_change
FROM f1_presentation.fact_results r
JOIN f1_presentation.dim_circuits c ON r.circuit_id = c.circuit_id
WHERE r.grid IS NOT NULL
  AND r.position IS NOT NULL
  AND r.grid > 0;

-- COMMAND ----------

SELECT
    circuit_name,
    country,
    COUNT(DISTINCT concat(season, '-', round)) AS races_held,
    ROUND(AVG(position_change), 2) AS avg_position_change,
    MAX(position_change) AS biggest_single_swing
FROM race_position_changes
GROUP BY circuit_name, country
HAVING COUNT(DISTINCT concat(season, '-', round)) >= 10
ORDER BY avg_position_change DESC
LIMIT 15;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 2) Top 5 Most predictable circuits:

-- COMMAND ----------

SELECT
    circuit_name,
    country,
    COUNT(DISTINCT concat(season, '-', round)) AS races_held,
    ROUND(AVG(position_change), 2) AS avg_position_change
FROM race_position_changes
GROUP BY circuit_name, country
HAVING COUNT(DISTINCT concat(season, '-', round)) >= 10
ORDER BY avg_position_change ASC
LIMIT 15;