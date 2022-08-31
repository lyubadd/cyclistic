# Cyclistic: From Casual Riders to Members
## Google Data Analytics Capstone Project

Author: Lyubomira Derelieva

Date: June 2022

Tableau data visualization here

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

As such, it represents the **entire population of Cyclistic riders** - casual and member - in that period.

The data is made **publicly available** by the company under [this link](https://divvy-tripdata.s3.amazonaws.com/index.html), making it **first-party data**.

The data was analyzed in respect of **applicable data privacy laws**. The analysis used no riders’ personally identifiable information as per the [Data License Agreement](https://ride.divvybikes.com/data-license-agreement). 

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
12 | end_lng | longitude of the end station |
13 | member_casual | type of user: member or casual rider |


The data includes all Cyclistic rides in the 12-month period broken down by member or casual rider. As it is **comprehensive** enough to allow us to compare trends in behavior between the two groups of users and answer the business question.

**No bias or credibility issues** were found. The company updates the data monthly, so it is also **current**. 

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
FROM  `leafy-star-345020.Cyclistic.202105_202204`;
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
```

The only fields where data is missing are those specifying the station names (start_station_id, start_station_name, end_station_id, end_station_name).  As the station names and IDs are not central to answer the business question and deleting these would lose valuable data for other observations, I kept the rides with the missing values for these fields.

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

* delete **trips with negative values** and **under 60 seconds**

When the clocks went back to standard time on November 7th 2021, the database did not automatically update so for the rides on that day the end time is earlier than the starting time. The data also included some false starts that lasted under 60 seconds.

```
DELETE FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE ride_length_new < 1;
 ```
This statement removed 91,883 rides.
 
* delete **trips over 24 hours** (which is forbidden by the system)

```
DELETE FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE ride_length_new > 1440;
```

This statement removed 4,184 rides.

As a final step in the Process phase, I **transformed the data** in order to **prepare it for the Analyze phase**.
 
* create a **new column “ride_length”** in order to calculate the average ride length for casual riders vs members.
 
 ```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN ride_length_new integer;
 ```
 
* subtract the started_at column from the ended_at to **calculate each ride’s length**.
 
 ```
UPDATE `leafy-star-345020.Cyclistic.202105_202204`
SET ride_length_new = DATETIME_DIFF(ended_at, started_at, MINUTE)
WHERE TRUE;
```

* create a **new column “day_of_week”**  in order to investigate the ride patterns of casual riders vs members throughout the week.

```
ALTER TABLE `leafy-star-345020.Cyclistic.202105_202204`
ADD COLUMN day_of_week integer;
```

* **determine the day of the week** that each ride started on (SUNDAY = 1)

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

In the “Analyze” phase, I structured my work according to 7 questions:

1. What **proportion of all Cyclistic rides** in the given time period do casual rides represent?
2. Do casual and annual member rides differ in terms of average **ride length**?
3. Do casual riders prefer **classic or electric bikes**? Does their preference differ from members’?
4. Does the use of Cyclistic bikes vary **throughout the year** for casual users compared to members? 
5. Does the use of Cyclistic bikes vary **throughout the week** for casual users comapred to members? 
6. Does the use of Cyclistic bikes vary **throughout the day** for casual users compared to members? 
7. What are the **most popular stations** for casual users compared to those of members? 

I believe that answering these would **make the most of the available data**, giving us an **insight into casual riders’ use of Cyclistic bikes and how it differs from members’. 

This insight would allow the marketing team to **tailor the new strategy to casual users’ behaviors and preferences**.

Let’s look into each question in more detail and find the answer.

1. What **proportion of all Cyclistic rides** in the given time period do casual rides represent?

As the new marketing strategy would focus on converting casual riders into members, it is important to be aware of what proportion of all users are casual riders as the target group of the marketing campaign.

* calculate the number of rides by type of rider

```
SELECT member_casual, COUNT(ride_id) AS number_rides
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY member_casual;
```
We find out that In the past 12 months **members were the main users** but **casual rides come close at 44% of all Cyclistic rides** - holding **big potential for converting casual riders into members**.
 
2. Do casual and annual member rides differ in terms of average **ride length**?

As the pricing depends on a ride’s length (e.g. a single ride costs $0.16 a minute for non-members, while for member rides under 45 minutes are free), we should investigate the average ride length of both types of users. It is important that annual membership makes financial sense to casual riders.

* calculate the average length of ride by user type
 
```
SELECT member_casual, AVG(ride_length_new) AS avg_ride_length_min
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY member_casual;
```
**Casual rides last twice as long as member ones**. This is important to keep in mind when the marketing team looks into **membership pricing**.
 
3. Do casual riders prefer **classic or electric bikes**? Does their preference differ from members’?

Knowing the preferred bike type of casual riders, can inform the marketing strategy's appeal to potential preferences.

* calculate the number of rides by type of rider by type of bike (classic vs electric) 
 
```
SELECT member_casual, rideable_type, COUNT(*) AS number_rideabletype
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY rideable_type, member_casual
ORDER BY number_rideabletype;
```
**Casual riders tend to have a slight preference for electric bikes**, while **two-thirds of members choose classic bikes**.

* check if there’s been an increase in the use of electric bikes among casual riders over time suggesting an increase in popularity

```
SELECT COUNT(ride_id) AS number_rides_electric_casual, month
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE member_casual = "casual" AND rideable_type IN ('docked_bike', 'electric_bike')
GROUP BY month
ORDER BY number_rides_electric_casual;
```

We find out that there hasn’t been and that the use of electric bikes follows the general seasonal pattern (see question 4 below).

4. Does the use of Cyclistic bikes vary **throughout the year** for casual users compared to members? 

It is important to be aware of month-to-month differences in order to make sure that annual membership makes financial sense for casual riders and they do not only use Cyclistic bikes in the summer months.

* calculate the number of rides by type of rider by month

```
SELECT month, member_casual, COUNT(*) AS trips_per_month
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY month, member_casual
ORDER BY month;
```

Trips peak in the summer and drop in winter for both types of users. Importantly, casual riders overtake members from mid-May until mid-August.
  
5. Does the use of Cyclistic bikes vary **throughout the week** for casual users comapred to members? 

This analysis will help us understand riding patterns better and may offer an insight into potential customizing of the annual membership product.

* calculate the number of rides by type of rider by day of the week

```
SELECT day_of_week, member_casual, COUNT(*) AS trips_per_dayweek
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;
```
Casual riders are most active at the weekend, members - during the working week:

6. Does the use of Cyclistic bikes vary **throughout the day** for casual users compared to members? 

As above, this analysis will help us understand riding patterns better and may offer an insight into potential customizing of the annual membership product.

* calculate the number of rides by type of rider by hour of day

```
SELECT hour, member_casual, COUNT(*) AS number_rides_hour
FROM `leafy-star-345020.Cyclistic.202105_202204`
GROUP BY hour, member_casual
ORDER BY hour ASC;
```

Casual rides increase steadily as the day goes by peaking at 5pm. They are also more active at night. Member rides peak during rush hours - both morning and evening - but like casual members the highest peak is at 5pm.

7. What are the **most popular stations** for casual users compared to those of members? 

It would be useful to know at which stations we can reach the most casual riders with our marketing campaign. 

* find the top 20 most popular start stations for casual riders

```
SELECT count(*) as num_rides, start_station_name, AVG(start_lat), AVG(start_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE start_station_name IS NOT NULL AND member_casual = 'casual'
GROUP BY start_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

* find the top 20 most popular end stations for casual riders

```
SELECT count(*) as num_rides, end_station_name, AVG(end_lat), AVG(end_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE end_station_name IS NOT NULL AND member_casual = 'casual'
GROUP BY end_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

* find the top 20 most popular start stations for members

```
SELECT count(*) as num_rides, start_station_name, AVG(start_lat), AVG(start_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE start_station_name IS NOT NULL AND member_casual = 'member'
GROUP BY start_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

* find the top 20 most popular end stations for members

```
SELECT count(*) as num_rides, end_station_name, AVG(end_lat), AVG(end_lng)
FROM `leafy-star-345020.Cyclistic.202105_202204`
WHERE end_station_name IS NOT NULL AND member_casual = 'member'
GROUP BY end_station_name
ORDER BY num_rides DESC
LIMIT 20;
```

**Complete interactive map available on Tableau Public** uder this link.
 
### 6. Recommendations 

The data analysis reveals that in the past 12 months between May 2021 and April 2022 casual rides made up 44% of all Cyclistic rides - holding **big potential for converting casual riders into members**.

To convert casual riders, the company should offer an **annual membership product customized to their specific mobility needs** characterized by: 
* Longer rides.
* Slight preference for electric bikes.
* Seasonal: casual rides peak and overtake member rides from mid-May till mid-August. 
* Casual riders are most active at the weekend, members - during the working week.
* Higher level of activity on weekends and in the evening and night, peak at 5pm.

Consider also:

* How will casual riders **save time, money or effort** with an annual membership? Annual membership should ideally be financially advantageous to casual riders.

* How does annual membership fit into a casual members' **lifestyle and value system**? Annual membership can also be linked to users' lifestyle and values, e.g. health benefits, or cycling as a **'green' transportation method**, or a way of getting around that gives **freedom to move** at any time of day without depending on cars, public transport and avoiding traffic jams.

* Collecting **additional feedback to deepen our insight into casual riders** (e.g. age group, frequency of use, return or one-off customers, tourists?) and any disincentives or obstacles to purchasing annual membership they experience (e.g. high initial purchasing cost, cheaper to buy occasional ticket if use is only occasional). Consider also collecting additional feedback from members to understand Chicagoans' reasons for purchasing annual memebrship.

* Looking further into the **impact of the Covid-19 pandemic** on casual riders’ motivation to use Cyclistic bikes. 

* **Launching the marketing strategy in February - March** when people go back to biking to get around town.
