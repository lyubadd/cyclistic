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
