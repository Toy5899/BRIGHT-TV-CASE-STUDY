-- Databricks notebook source
-- II WANTED TO SEE THE WHOLE TABLE BEFORE DOING ANY ANALYSIS ON IT.

SELECT *
FROM `bright-tv`.`data`.`userprofiles`
LIMIT 10;

-- CHECKNG FOR DUPLICATE ON MY DATA
SELECT UserID,
 COUNT(*) AS duplicate_count
FROM `bright-tv`.`data`.`userprofiles`
GROUP BY UserID
HAVING COUNT(*) > 1;

-- CHECKING THE SIZE OF MY DATA
SELECT COUNT(*) AS number_of_rows,
 COUNT(DISTINCT UserID) AS number_subs
FROM `bright-tv`.`data`.`userprofiles`;

-- CHECKING FOR ROWS THAT HAVE A NULL
SELECT COUNT(*) AS cnt
FROM `bright-tv`.`data`.`userprofiles`
WHERE UserID IS NULL;

SELECT DISTINCT UserID
FROM `bright-tv`.`data`.`userprofiles`;

-- GENDER CHECKS
SELECT DISTINCT Gender
FROM `bright-tv`.`data`.`userprofiles`;

SELECT 
   COUNT(DISTINCT UserID) AS Subs,
  CASE
    WHEN Gender = 'NONE' THEN 'Unknown'
    WHEN Gender = ' ' THEN 'Unknown'
    WHEN Gender IS NULL THEN 'Unknown'
    ELSE Gender
  END AS Gender
FROM `bright-tv`.`data`.`userprofiles`
GROUP BY Gender;

-- RACE CHECKS
SELECT COUNT(*)AS num_rows
FROM `bright-tv`.`data`.`userprofiles`
WHERE Race IS NULL;

SELECT DISTINCT Race
FROM `bright-tv`.`data`.`userprofiles`;

SELECT DISTINCT
  CASE
    WHEN Race = 'other' THEN 'Unknown'
    WHEN Race = 'NONE' THEN 'Unknown'
    WHEN Race = ' ' THEN 'Unknown'
    WHEN Race IS NULL THEN 'Unknown'
    ELSE Race
  END AS Ethnicity
FROM `bright-tv`.`data`.`userprofiles`;

-- PROVINCE CHECKS
SELECT DISTINCT Province
FROM `bright-tv`.`data`.`userprofiles`;  

SELECT DISTINCT 
  CASE 
    WHEN Province = 'NONE' THEN 'Uncategorized'
    WHEN Province = ' ' THEN 'Uncategorized'
    ELSE Province
  END AS Region
FROM `bright-tv`.`data`.`userprofiles`;

-- AGE CHECKS
SELECT min(Age), max(Age), avg(Age)
FROM `bright-tv`.`data`.`userprofiles`;

SELECT
  CASE
    WHEN Age = 0 THEN 'Infant'
    WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
    WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
    WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
    WHEN Age > 65 THEN 'Pensioner'
  END AS `Age GROUP`
  
FROM `bright-tv`.`data`.`userprofiles`;

