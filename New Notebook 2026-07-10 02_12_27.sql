-- Databricks notebook source
WITH user_profiles AS (
  SELECT
    UserID AS userid,
    CASE
      WHEN Age = 0 THEN 'Infant'
      WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
      WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
      WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
      WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
      WHEN Age > 65 THEN 'Pensioner'
      ELSE 'Unknown'
    END AS age_groups,
    CASE
      WHEN Email IS NOT NULL AND Email <> ' ' AND Email NOT IN ('None') THEN 1
      ELSE 0
    END AS email_flag,
    CASE
      WHEN `Social Media Handle` IS NOT NULL AND `Social Media Handle` <> ' ' AND `Social Media Handle` NOT IN ('None') THEN 1
      ELSE 0
    END AS sm_flag,
    CASE
      WHEN Race = 'other' THEN 'None'
      WHEN Race = ' ' THEN 'None'
      ELSE Race
    END AS Race,
    CASE
      WHEN Gender = ' ' THEN 'None'
      ELSE Gender
    END AS Gender,
    Province AS Region
  FROM `bright-tv`.`data`.`userprofiles`
),
viewership AS (
  SELECT
    COALESCE(UserID0, userid4) AS userid,
    date_format(RecordDate2, 'yyyyMM') AS month_id,
    to_date(RecordDate2) AS watch_date,
    date_format(RecordDate2, 'u') AS day_of_week,
    dayname(RecordDate2) AS day_name,
    CASE
      WHEN dayname(RecordDate2) IN ('Sat', 'Sun') THEN 'weekend'
      ELSE 'weekday'
    END AS day_classification,
    monthname(RecordDate2) AS month_name,
    CASE
      WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
      WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
      ELSE Channel2
    END AS Tv_channel,
    date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
    CASE
      WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
      WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
      WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
      WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
    END AS time_of_day,
    hour(RecordDate2) AS hour_of_day,
    `Duration 2` AS duration,
    CASE
      WHEN `Duration 2` BETWEEN interval  '00:05:00' hour to second AND interval '00:30:00' hour to second THEN '01. Low Usage: <30 min'
      WHEN `Duration 2` BETWEEN interval '00:30:01' hour to second AND interval '00:59:59' hour to second THEN '02. Med Usage: <60 min'
      WHEN `Duration 2` > interval '00:59:59' hour to second THEN '03. High Usage: >60 min'
      ELSE '04. No Usage'
    END AS screen_time_bucket
  FROM `bright-tv`.`data`.`viewership`
)

SELECT
  COALESCE(A.userid, B.userid) AS sub_id,
  A.month_id,
  A.watch_date,
  A.day_of_week,
  A.day_name,
  A.day_classification,
  A.month_name,
  A.Tv_channel,
  A.time_of_day,
  A.hour_of_day,
  A.screen_time_bucket,
  A.duration,
  B.Region,
  B.age_groups,
  B.email_flag,
  B.sm_flag,
  B.Race,
  B.Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
  ON A.userid = B.userid
;
