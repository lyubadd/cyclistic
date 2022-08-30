# Cyclistic: From Casual Riders to Members
## Google Data Analytics Capstone Project

### 1. Introduction

Cyclistic is a **bike-share company operating in Chicago**. Since its creation in 2016, it has grown its fleet to **5,824 bicycles (classic and electric)** that are geotracked and locked into a **network of 692 stations across the city**. The bikes can be unlocked from any station and returned to any station anytime. The company sets itself apart by offering **alternative bikes for people with disabilities** and **riders who cannot use a standard two-wheeled bike**. 

Cyclistic’s **current marketing strategy** relies on building general awareness and appealing to **broad consumer segments**, including by offering **flexible pricing plans: single-ride passes, full-day passes, and annual memberships**. Customers who purchase **single-ride** or **full-day passes** are referred to as **casual riders**. Customers who purchase **annual memberships** are **Cyclistic members**.

Cyclistic’s finance analysts, however, have concluded that **annual members are much more profitable than casual riders**. Although the pricing flexibility helps Cyclistic attract more customers, the head of marketing believes that **maximizing the number of annual members will be key to future growth**. Thus, the company has decided to **design a new marketing strategy** aimed at **converting casual riders into annual members**.

### 2. Business Task

One of the three questions that will guide the design of the future marketing program is: **How do annual members and casual riders use Cyclistic bikes differently?**

This is the **business question to which this case study is dedicated**. The insights reached will inform the company’s new marketing strategy to convert casual riders into annual members. 

The **key stakeholder** in this project is the Cyclistic marketing team headed by Ms Moreno.

The **main metrics** this project will look at are:
* **Ride length** for casual riders vs annual members
* Preference for **classic or electric bikes** of casual riders vs annual members
* Ridership **trends by month** for casual riders vs annual members
* Ridership **trends by day of the week** for casual riders vs annual members
* Ridership **trends by time of day** for casual riders vs annual members
* **Most popular stations** for casual riders vs annual members

### 3. Prepare Data

This project analyzes the Cyclistic **historical data** on **all bike trips from the past 12 months** covering the period from **May 2021 until April 2022**. 

As such it represents the **full population of Cyclistic riders** - casual and member - in that time period.

The data is made **publicly available** by the company under [this link](https://divvy-tripdata.s3.amazonaws.com/index.html), making it **first-party data**.

The data was analyzed in respect of **applicable data privacy laws**. No riders’ personally identifiable information was used in the analysis as per the [Data License Agreement](https://ride.divvybikes.com/data-license-agreement). 

The data was stored by month on the server and was downloaded in 12 separate .csv files on the data analyst’s personal computer.

The data is **organized by individual trip** and it **covers 13 variables**:

| number| variable | description |
| ----- | --------|------------- |
1 | ride_id | unique ID of each individual ride |
2 | rideable_type | type of bike: classic, electric or docked |
3 | started_at | starting date and time of the ride |
4 | ended_at | end date and time of the ride |
5 | start_station_name | name of the starting station |
6 | start_station_id | unique ID of the starting station |
7 | end_station_name | name of the end station |
8 | end_station_id | unique ID of the end station |
9 | start_lat | latitude of the starting station |
10 | start_lng | longitude of the starting station |
11 | end_lat | latitude of the end station |
12 | end_lng longitude of the end station |
13 | member_casual | type of user: member or casual rider |


The data includes all Cyclistic rides in the 12-month period broken down by member or casual rider. As such it is **comprehensive** enough to allow us to compare trends in behaviour between the two groups of users and answer the business question.

**No bias or credibility issues** were found. The data is updated on a monthly basis, so it is also **current**. 

There are, however, certain **limitations** to the data:
* It does not show the use of **accessible riding options**.
* It is **incomplete for some journeys**.
* It does not break down between day-passes and single passes or one-off and return customers that would have provided **more granular insights**.

### 4. Process Data

Due to the large amount of data required for the analysis, I executed the project in **SQL BigQuery** on the Google Cloud Platform. I uploaded the 12 tables of data (corresponding to the 12 months under analysis) on the Google Cloud and BigQuery handled them without an issue. 

Before merging the 12 tables, I took time to **acquaint myself with the data**:
* I **mapped** the data;
* I checked **if the variables are the same in all 12 files**;
* I took note of the number of rows and columns in all csv. files in order to make sure that **nothing would get lost in the merging process**.

Once I got to know the data, I **merged the 12 tables**.

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

The merged document included **observations about 5,757,551 rides**.  

Next, I double checked that nothing got lost in the merging process. **Nothing had got lost**.

Then, I proceeded with **cleaning the merged data**. I recorded all **cleaning checks and fixes as follows**: 
 
* check for **misspelt words** using a sample of values and counting the expected number of values using COUNT DISTINCT (e.g. only 2 values for member_casual). 
 
No misspelt words were found.

* check for **duplicate rides**

```
SELECT COUNT(DISTINCT ride_id)
FROM  `leafy-star-345020.Cyclistic.202105_202204`
```

There were no duplicate rides.  

* check for any **errors** in all the columns, e.g. more than 3 types of rideable_types, or more than 2 values in member_casual.

```
SELECT
DISTINCT rideable_type
FROM `leafy-star-345020.Cyclistic.202105_202204`;
```

No errors were found.

* check for **missing values**

```
SELECT COUNT (*) AS missing_end_station_id
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE end_station_id IS NULL;
The only fields where data is missing are those specifying the station names (start_station_id, start_station_name, end_station_id, end_station_name).  As the station names and IDs are not central to answer the business question and deleting these would lose valuable data for other observations, I kept the rides with the missing values for these fields.
```

* **clean the empty spaces** from the string fields

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

* deleted **trips with negative values** and **under 60 seconds**

When the clocks went back to standard time on November 7th 2021, the database did not automatically update so for the rides on that day the end time is earlier than the starting time. The data also included some false starts that lasted under 60 seconds.

```
DELETE FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE ride_length_new < 1;
 ```
This statement removed 91,883 rides.
 
* deleted **trips over 24 hours** (which is forbidden by the system)

```
DELETE FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE ride_length_new > 1440;
```

This statement removed 4,184 rides.

As a final step in the Process phase, I **transformed the data** in order to **prepare it for the Analyze phase**.
 
* Created **new column “ride_length”** in order to calculate the average ride length for casual riders vs members.
 
 ```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN ride_length_new integer;
 ```
 
* Subtracted the started_at column from the ended_at to **calculate each ride’s length**.
 
 ```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET ride_length_new = DATETIME_DIFF(ended_at, started_at, MINUTE)
WHERE TRUE;
```

* created **new column “day_of_week”**  in order to investigate the ride patterns of casual riders vs members throughout the week.

```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN day_of_week integer;
```

* **determined the day of the week** that each ride started on (SUNDAY = 1)

```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET day_of_week = EXTRACT(DAYOFWEEK FROM started_at)
WHERE TRUE;
```

I double checked the operation was executed correctly by

```
SELECT DISTINCT day_of_week
FROM `leafy-star-345020.Cyclistic.202105_202204`;
```

And manually checked the first date in the calendar to see if 05/23/2021 was indeed a Sunday. Everything was correct.

* created **new column “hour”** 

```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN hour smallint;
 ```
 
* **extracted the hour** from the “started_at” column into the new column “hour”

```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET hour = EXTRACT(HOUR FROM started_at)
WHERE TRUE;
```

* created **new column “month”**

```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN month integer;
 ```
 
* **extracted the month** from the “started_at” column into the new column “month”
 
 ```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET month = EXTRACT(month FROM started_at)
WHERE TRUE;
```

### 5. Analyze Data
### 6. Recommendations 
