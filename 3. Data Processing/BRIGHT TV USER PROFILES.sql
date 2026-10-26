-- Databricks notebook source
SELECT *
FROM `bright-tv`.data.userprofiles;

-- COUNTING UNIQUE USERIDs --
SELECT COUNT(DISTINCT UserID)
FROM `bright-tv`.data.userprofiles;

-- Checking for Duplicates --
SELECT UserID, COUNT(*) AS duplicate_count
FROM `bright-tv`.data.userprofiles
GROUP BY UserID
HAVING COUNT(*) > 1;

-- Inspect Gender Columns --
SELECT DISTINCT Gender
FROM `bright-tv`.data.userprofiles;

-- Cleaning the gender column --
SELECT DISTINCT
    CASE 
        WHEN Gender = 'None' THEN 'unknown'
        WHEN Gender = ' ' THEN 'unknown'
        WHEN Gender IS NULL THEN 'unknown'
        ELSE Gender
    END AS Sex
FROM `bright-tv`.data.userprofiles;

-- INSPECTING RACE COLUMN --
SELECT DISTINCT Race
FROM `bright-tv`.data.userprofiles;

-- CLEANING/STANDARDISING THE RACE COLUMN --
SELECT DISTINCT
    CASE
        WHEN Race = 'other' THEN 'Unknown'
        WHEN Race = 'None' THEN 'Unknown'
        WHEN Race = ' ' THEN 'Unknown'
        WHEN Race IS NULL THEN 'Unknown'
        ELSE Race
    END AS Ethnicity
FROM `bright-tv`.data.userprofiles;

-- Counting the number of subscribers per race --
SELECT
    COUNT(DISTINCT UserID) AS Subscribers,
    CASE 
        WHEN Race = 'other' THEN 'unknown'
        WHEN Race = 'None' THEN 'unknown'
        WHEN Race = ' ' THEN 'unknown'
        WHEN Race IS NULL THEN 'unknown'
        ELSE Race
    END AS Ethnicity
FROM `bright-tv`.data.userprofiles
GROUP BY
    CASE 
        WHEN Race = 'other' THEN 'unknown'
        WHEN Race = 'None' THEN 'unknown'
        WHEN Race = ' ' THEN 'unknown'
        WHEN Race IS NULL THEN 'unknown'
        ELSE Race
    END;

-- PROVINCE CHECKS --
SELECT DISTINCT Province
FROM `bright-tv`.data.userprofiles;

-- Cleaning up Province --
SELECT DISTINCT 
    CASE 
        WHEN Province = 'None' THEN 'Unknown'
        WHEN Province = ' ' THEN 'Unknown'
        WHEN Province IS NULL THEN 'Unknown'
        ELSE Province
    END AS Region
FROM `bright-tv`.data.userprofiles;

-- AGE CHECKS --
SELECT DISTINCT Age
FROM `bright-tv`.data.userprofiles;

SELECT MIN(Age) AS min_age,
       MAX(Age) AS max_age,
       AVG(Age) AS mean_age 
FROM `bright-tv`.data.userprofiles;

SELECT 
    CASE
        WHEN Age = 0 THEN 'Infant'
        WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
        WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
        WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
        WHEN Age > 50 AND Age <= 60 THEN 'Elder'
        WHEN Age > 60 THEN 'Pensioner'
    END AS Age_group
FROM `bright-tv`.data.userprofiles;

-- CREATE OR REPLACE TEMPORARY TABLE USING CTE --
CREATE OR REPLACE TEMPORARY TABLE Cleaned_Userprofiles AS
SELECT
    UserID,
    CASE 
        WHEN Email IS NOT NULL AND Email <> ' ' AND Email NOT IN ('None', 'other') THEN 1
        ELSE 0
    END AS Email_flag,
    CASE 
        WHEN `Social Media Handle` IS NOT NULL AND `Social Media Handle` <> ' ' AND `Social Media Handle` NOT IN ('None', 'other') THEN 1
        ELSE 0
    END AS Socialmedia_flag,
    CASE 
        WHEN Gender = 'None' THEN 'unknown' 
        WHEN Gender = ' ' THEN 'unknown' 
        WHEN Gender IS NULL THEN 'unknown' 
        ELSE Gender 
    END AS Sex,
    CASE 
        WHEN Race = 'other' THEN 'unknown'
        WHEN Race = 'None' THEN 'unknown'
        WHEN Race = ' ' THEN 'unknown'
        WHEN Race IS NULL THEN 'unknown'
        ELSE Race
    END AS Ethnicity,
    CASE 
        WHEN Province = 'None' THEN 'Unknown'
        WHEN Province = ' ' THEN 'Unknown'
        WHEN Province IS NULL THEN 'Unknown'
        ELSE Province
    END AS Region,
    CASE
        WHEN Age = 0 THEN 'Infant'
        WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
        WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
        WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
        WHEN Age > 50 AND Age <= 60 THEN 'Elder'
        WHEN Age > 60 THEN 'Pensioner'
    END AS Age_group
FROM `bright-tv`.data.userprofiles;

SELECT * FROM Cleaned_Userprofiles;
