-- Databricks notebook source


WITH User_profile AS (
  SELECT 
    UserID,
    CASE
      WHEN Gender = 'None' THEN 'unknown'
      WHEN Gender = ' ' THEN 'unknown'
      WHEN Gender IS NULL THEN 'unknown'
      ELSE Gender
    END AS Sex,
    CASE
      WHEN Race = 'None' THEN 'unknown'
      WHEN Race = 'other' THEN 'unknown'
      WHEN Race = ' ' THEN 'unknown'
      WHEN Race IS NULL THEN 'unknown'
      ELSE Race
    END AS Ethnicity,
    CASE
      WHEN Province = ' ' THEN 'Unclassified'
      WHEN Province = 'None' THEN 'Unclassified'
      WHEN Province IS NULL THEN 'Unclassified'
      ELSE Province
    END AS Region,
    CASE
      WHEN Age = 0 THEN 'Infant'
      WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
      WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
      WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
      WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
      WHEN Age > 65 THEN 'Pensioner'
      ELSE 'Adults'
    END AS Age_Groups,
    CASE
      WHEN Email IS NOT NULL AND Email <> '' AND Email NOT IN ('None') THEN 1
      ELSE 0
    END AS email_flag,
    CASE
      WHEN `Social Media Handle` IS NULL OR `Social Media Handle` = ' ' OR `Social Media Handle` = 'None' THEN 0
      ELSE 1
    END AS sm_flag
  FROM `bright-tv`.data.userprofiles
),

Base_viewership AS (
  SELECT
    COALESCE(UserID0, userid4) AS User_id,
    FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST,
    Channel2,
    `Duration 2`
  FROM `bright-tv`.`data`.`viewership`
),

viewership AS (
  SELECT
    User_id,
    RecordDate_SAST,
    TO_DATE(RecordDate_SAST) AS watch_date,
    DAYNAME(TO_DATE(RecordDate_SAST)) AS day_name,
    MONTHNAME(RecordDate_SAST) AS month_name,
    YEAR(RecordDate_SAST) AS event_year,
    DAY(RecordDate_SAST) AS event_day,
    HOUR(RecordDate_SAST) AS Hour_of_day,
    CASE 
      WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Saturday', 'Sunday') THEN '02.Weekend'
      ELSE '01.Weekday' 
    END AS day_classification,
    DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') AS watch_time,
    CASE 
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight' 
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning' 
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon' 
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening' 
    END AS time_of_day,
    DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration,
    (HOUR(`Duration 2`) + MINUTE(`Duration 2`)/60.0 + SECOND(`Duration 2`)/3600.0) AS duration_hours,
    (HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`)) AS Duration_seconds,
    CASE  
      WHEN (HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`)) BETWEEN 300 AND 1800 THEN '01. Low Usage: <30 min' 
      WHEN (HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`)) BETWEEN 1801 AND 3599 THEN '02. Med Usage: <60 min' 
      WHEN (HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`)) >= 3600 THEN '03. High Usage (>60 min)'
      ELSE '04. No Usage' 
    END AS Screen_time_bucket, 
    CASE   
      WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee' 
      WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events','DStv Events 1') THEN 'Live Events' 
      ELSE Channel2 
    END AS Tv_Channel
  FROM Base_viewership
)

SELECT 
  COALESCE(A.User_id, B.UserID) AS Sub_ID,
  B.Sex,
  B.Ethnicity,
  B.Region,
  B.Age_Groups,
  B.email_flag,
  B.sm_flag,
  A.RecordDate_SAST,
  A.Hour_of_day,
  A.month_name,
  A.event_year,
  A.event_day,
  A.watch_date, 
  A.day_name, 
  A.day_classification,
  A.watch_time, 
  A.Tv_Channel, 
  A.time_of_day,  
  A.Screen_time_bucket,
  A.Duration,
  A.Duration_seconds,
  A.duration_hours
FROM viewership AS A
LEFT JOIN User_profile AS B
ON A.User_id = B.UserID;
