-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Analysis 2: Which constructors have dominated Formula 1 across eras?
-- MAGIC Built from `fact_constructor_standings` + `dim_constructors`. It uses
-- MAGIC the official end-of-season standings directly, rather than
-- MAGIC recalculating from race results.
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 1) Dominant constructors of all time (minimum 3 seasons):

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW constructor_season_standings AS
SELECT
    cs.season,
    cs.constructor_id,
    c.name AS constructor_name,
    c.nationality,
    cs.position,
    cs.points,
    cs.wins
FROM f1_presentation.fact_constructor_standings cs
JOIN f1_presentation.dim_constructors c ON cs.constructor_id = c.constructor_id;

-- COMMAND ----------

SELECT
    constructor_name,
    nationality,
    COUNT(DISTINCT season) AS seasons_contested,
    SUM(points) AS total_points,
    ROUND(AVG(points), 2) AS avg_points_per_season,
    SUM(wins) AS total_wins,
    SUM(CASE WHEN position = 1 THEN 1 ELSE 0 END) AS championships
FROM constructor_season_standings
GROUP BY constructor_name, nationality
HAVING COUNT(DISTINCT season) >= 3
ORDER BY avg_points_per_season DESC
LIMIT 15;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 2) Constructors Performance by Seasons:

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW top_5_constructors AS
SELECT constructor_name, AVG(points) AS avg_points
FROM constructor_season_standings
GROUP BY constructor_name
HAVING COUNT(DISTINCT season) >= 3
ORDER BY avg_points DESC
LIMIT 5;


-- COMMAND ----------

SELECT
    season,
    constructor_name,
    points,
    wins,
    position AS final_standing
FROM constructor_season_standings
WHERE constructor_name IN (SELECT constructor_name FROM top_5_constructors)
ORDER BY season, points DESC;