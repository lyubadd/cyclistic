-- merge the 12 tables covering the 12 months of the past year.

```
INSERT INTO `leafy-star-345020.Cyclistic.202105_202204`
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_05`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_06`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_07`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_08`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_09`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_10`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_11`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2021_12`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2022_01`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2022_02`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2022_03`
UNION ALL
SELECT *
FROM `leafy-star-345020.Cyclistic.2022_04`;
```

-- check for duplicate rides

```
SELECT COUNT(DISTINCT ride_id)
FROM  `leafy-star-345020.Cyclistic.202105_202204`;
```
-- check for any errors in all the columns, e.g. more than 3 types of rideable_types, or more than 2 values in member_casual.
```
SELECT
DISTINCT rideable_type
FROM `leafy-star-345020.Cyclistic.202105_202204`;
```
-- check for missing values
```
SELECT COUNT (*) AS missing_end_station_id
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE end_station_id IS NULL;
```

-- clean the empty spaces from the string fields
```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET
ride_id = TRIM (ride_id),
rideable_type = TRIM(rideable_type),
start_station_name = TRIM (start_station_name),
start_station_id = TRIM (start_station_id),
end_station_name = TRIM (end_station_name),
end_station_id = TRIM (end_station_id),
member_casual = TRIM (member_casual)
WHERE TRUE;
```

-- delete trips with negative values and under 60 seconds
-- When the clocks went back to standard time on November 7th 2021, the database did not automatically update so for the rides on that day the end time is earlier than the starting time. The data also included some false starts that lasted under 60 seconds.
```
DELETE FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE ride_length_new < 1;
```

-- delete trips over 24 hours (which is forbidden by the system)
```
DELETE FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE ride_length_new > 1440;
```

-- create a new column “ride_length” in order to calculate the average ride length for casual riders vs members.
```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN ride_length_new integer;
```

-- subtract the started_at column from the ended_at to calculate each ride’s length.
```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET ride_length_new = DATETIME_DIFF(ended_at, started_at, MINUTE)
WHERE TRUE;
```
-- create a new column “day_of_week” in order to investigate the ride patterns of casual riders vs members throughout the week.
```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN day_of_week integer;
```
-- determine the day of the week that each ride started on (SUNDAY = 1)
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET day_of_week = EXTRACT(DAYOFWEEK FROM started_at)
WHERE TRUE;

-- I double checked the operation was executed correctly by
```
SELECT DISTINCT day_of_week
FROM `leafy-star-345020.Cyclistic.202105_202204`;
```

-- manually checked the first date in the calendar to see if 05/23/2021 was indeed a Sunday. Everything was correct.

-- created new column “hour”
```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN hour smallint;
```

-- extracted the hour from the “started_at” column into the new column “hour”
```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET hour = EXTRACT(HOUR FROM started_at)
WHERE TRUE;
```
-- created new column “month”
```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN month integer;
```
-- extracted the month from the “started_at” column into the new column “month”
```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET month = EXTRACT(month FROM started_at)
WHERE TRUE;
```
--calculate the number of rides by type of rider
```
SELECT member_casual, COUNT(ride_id) AS number_rides
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY member_casual;
```
-- calculate the average length of ride by user type
```
SELECT member_casual, AVG(ride_length_new) AS avg_ride_length_min
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY member_casual;
```
-- calculate the number of rides by type of rider by type of bike (classic vs electric)
```
SELECT member_casual, rideable_type, COUNT(*) AS number_rideabletype
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY rideable_type, member_casual
ORDER BY number_rideabletype;
```
-- check if there’s been an increase in the use of electric bikes among casual riders over time suggesting an increase in popularity
```
SELECT COUNT(ride_id) AS number_rides_electric_casual, month
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE member_casual = "casual" AND rideable_type IN ('docked_bike', 'electric_bike')
GROUP BY month
ORDER BY number_rides_electric_casual;
```
-- calculate the number of rides by type of rider by month
```
SELECT month, member_casual, COUNT(*) AS trips_per_month
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY month, member_casual
ORDER BY month;
```
-- calculate the number of rides by type of rider by day of the week
```
SELECT day_of_week, member_casual, COUNT(*) AS trips_per_dayweek
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;
```

-- calculate the number of rides by type of rider by hour of day
```
SELECT hour, member_casual, COUNT(*) AS number_rides_hour
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY hour, member_casual
ORDER BY hour ASC;
```

-- find the top 20 most popular start stations for casual riders
```
SELECT count(*) as num_rides, start_station_name, AVG(start_lat), AVG(start_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE start_station_name IS NOT NULL AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

-- find the top 20 most popular end stations for casual riders
```
SELECT count(*) as num_rides, end_station_name, AVG(end_lat), AVG(end_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE end_station_name IS NOT NULL AND member_casual = 'casual'
GROUP BY end_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

-- find the top 20 most popular start stations for members
```
SELECT count(*) as num_rides, start_station_name, AVG(start_lat), AVG(start_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE start_station_name IS NOT NULL AND member_casual = 'member'
GROUP BY start_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

-- find the top 20 most popular end stations for members
```
SELECT count(*) as num_rides, end_station_name, AVG(end_lat), AVG(end_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE end_station_name IS NOT NULL AND member_casual = 'member'
GROUP BY end_station_name
ORDER BY num_rides DESC
LIMIT 20;
```
