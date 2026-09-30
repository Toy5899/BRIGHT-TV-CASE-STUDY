-- Databricks notebook source
WITH userprofiles AS (
  SELECT 
     UserID,
     CASE
       WHEN Province = '' THEN 'Uncategorised'
       WHEN Province = 'NONE' THEN 'Uncategorised'
       ELSE Province
     END AS Regions,  
     Age,
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
       WHEN `Social Media Handle` IS NULL OR `Social Media Handle` = ' ' OR `Social Media Handle` NOT IN ('None') THEN 1
       ELSE 0
     END AS sm_flag, 
     CASE 
       WHEN Race = 'other' THEN 'None' 
       WHEN Race = ' ' THEN 'None' 
       ELSE Race 
     END AS Race,
     CASE 
       WHEN gender = ' ' THEN 'None' 
       ELSE gender 
     END AS Gender 
  FROM `bright-tv`.data.userprofiles
),

viewership AS (
SELECT 
    Coalesce(userID0,userid4)AS userid,
    TO_CHAR(RecordDate2, 'yyyyMM') AS month_id, 
    TO_DATE(RecordDate2) AS watch_date, 
    --TIME(RecordDate2) AS watch_time, 
    TO_CHAR(RecordDate2, 'DD') AS day_of_week, 
    DAYNAME(RecordDate2) AS day_name, 
    CASE 
        WHEN day_name IN ('Sat', 'Sun') THEN 'weekend' 
        ELSE 'weekday' 
    END AS day_classification, 
    MONTHNAME(RecordDate2) AS month_name, 
    CASE   
        WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee' 
        WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events','DStv Events 1') THEN 'Live Events' 
        ELSE Channel2 
    END AS Tv_channel, 
    date_format(RecordDate2, 'HH:mm:ss') AS watch_time,    
    CASE 
        WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight' 
        WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning' 
        WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon' 
        WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening' 
    END AS time_of_day, 
    date_format(`Duration 2`,'HH:mm:ss') AS Duration, 
    CASE  
        WHEN date_format(`Duration 2`, 'HH:mm:ss') BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min' 
        WHEN date_format(`Duration 2`, 'HH:mm:ss') BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min' 
        WHEN date_format(`Duration 2`, 'HH:mm:ss') >'00:59:59' THEN '03. High Usage: >60 min' 
        ELSE '04. No Usage' 
    END AS screen_time_bucket, 
    HOUR(RecordDate2) AS hour_of_day 
    FROM `bright-tv`.data.viewership
)
SELECT Coalesce(A.userid,B.userid) AS sub_id, 
       month_id, 
       watch_date, 
       day_of_week, 
       day_name, 
       day_classification, 
       month_name, 
       Tv_channel, 
       time_of_day, 
       hour_of_day, 
       screen_time_bucket,
       duration,
       Regions,
       Age_Groups,
       email_flag, 
       sm_flag, 
       Race, 
       Gender 
FROM viewership AS A 
LEFT JOIN userprofiles AS B 
ON A.userid=B.userid;
 



