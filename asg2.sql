/*
File: asg2.sql 
Jameson Watson
Fall 2021, Assignment 2
*/

\. rm -f asg2.log

tee asg2.log

SELECT NOW();

/* 1 - Subquery creates a table to select the month, and count the 
sighting date to get the number of sightings  for our outer query to
 run the aggregate functions on. Could not figure out why the aggregate
functions were not running a query the way that I intended. I could get
the min, max, avg, and std for one month at a time but could not get the
complete table in the output. */
use ufodb;

SELECT month AS results,MIN(Sightings) AS minSightings,
MAX(Sightings) AS maxSightings,
AVG(Sightings) AS avgSightings,
STD(Sightings) AS standardDev
FROM (SELECT dim_month AS month,
COUNT(sighting_date) AS Sightings
FROM fact_ufo JOIN dim_date ON(fact_ufo.sighting_date = dim_date.dim_date)
GROUP BY month ORDER BY month)
AS sightingMonth;

/* 2 - The inner query creates a table using the date, zodiac sign, and 
count of the date for the outer query to count the maximum sighting
for that day as per zodiac sign with the maximum sighting. */
SELECT dim_date, zodiac, MAX(Sightings) AS maxSightings
FROM (SELECT dim_date, zodiac, COUNT(dim_date)
AS Sightings
FROM dim_date
JOIN fact_ufo
ON(dim_date = fact_ufo.sighting_date)
GROUP BY dim_date)
AS days;

/* 1 - Join clause gives us all of the mountain ranges with a 
value in the field for the query to look for. */
use mountain;

SELECT mountain_range.range_name, nranges.name,
COUNT(mountain.mountain_name) AS numMountains
FROM mountain
JOIN mountain_range USING (range_id)
JOIN nranges USING(range_name)
GROUP BY mountain_range.range_name
ORDER BY numMountains DESC,
range_name ASC;

/* 2 - Left join clause allows us to care about the values in A
but not B, we join B only worrying about the values in A. 
We are specifically looking for no mountains in the mountain
range so the where clause is added to look for null values.*/
SELECT mountain_range.range_name, nranges.name,
COUNT(mountain.mountain_name) AS numMountains
FROM mountain_range
LEFT JOIN mountain USING(range_id)
JOIN nranges USING(range_name)
WHERE ISNULL(mountain.range_id)
GROUP BY mountain_range.range_name
ORDER BY numMountains DESC,
range_name ASC;

/* 3 - Take out the where clause from question 2 to give us the 
list of mountain ranges with 0 or more mountain ranges.*/
SELECT mountain_range.range_name, nranges.name,
COUNT(mountain.mountain_name) AS numMountains
FROM mountain_range
LEFT JOIN mountain USING(range_id)
JOIN nranges USING(range_name)
GROUP BY mountain_range.range_name
ORDER BY numMountains DESC,
range_name ASC;

/* 4 - Join the tables using a union, a union select must have the same
number of columns and data types. We used a union to connect two
queries that would derive the same output using the same input. */
SELECT mountain_range.range_name, nranges.name,
COUNT(mountain.mountain_name) AS numMountains
FROM mountain
JOIN mountain_range USING(range_id)
JOIN nranges USING(range_name)
GROUP BY mountain_range.range_name
UNION
SELECT mountain_range.range_name, nranges.name,
COUNT(mountain.mountain_name) AS numMountains
FROM mountain_range
LEFT JOIN mountain USING(range_id)
JOIN nranges USING(range_name)
GROUP BY mountain_range.range_name
ORDER BY numMountains DESC,
range_name ASC;

/* 5 - The subquery temporarily gets the average elevation of mountain ranges per 
continent. The outer query gets the max of the average elevation as per continent,
then returns the continent name and average continent elevation of the mountain ranges
on the continent with the highest average. */
SELECT MAX(avgE) AS avgContElevation, continentName
FROM (SELECT AVG(elevation) AS avgE,
name AS continentName
FROM mountain JOIN mountain_range USING(range_id)
JOIN continent ON(continent.cont_id = mountain_range.range_continent)
GROUP BY range_id ORDER BY MAX(elevation) DESC) AS nameCont;

/* 6 - mountain.elevation * 3.28 is not returning a value, therefor the output for this
query is wrong but the logic seems right. I could not figure out how to get the syntax to
work properly.
We use unions for this question because the queries have the same rows, columns, and data 
types. Each select statement grabs the sum of the elevation times feet, checks if it is 
above the appropriate threshold, and adds to the final count as per category and continent
respectively.
*/
SELECT 'High' AS Category,
SUM(IF(continent.name = 'North America' AND ((mountain.elevation * 3.28) > 20000),1,0)) AS 'North America',
SUM(IF(continent.name = 'Europe' AND ((mountain.elevation * 3.28) > 20000),1,0)) AS 'Europe',
SUM(IF(continent.name = 'Asia' AND ((mountain.elevation * 3.28) > 20000),1,0)) AS 'Asia'
FROM mountain JOIN mountain_range USING(range_id)
JOIN continent ON(continent.cont_id = mountain_range.range_id)

UNION

SELECT 'Medium' AS Category,
SUM(IF(continent.name = 'North America' AND ((mountain.elevation * 3.28) > 10000),1,0)) AS 'North America',
SUM(IF(continent.name = 'Europe' AND ((mountain.elevation * 3.28) > 10000),1,0)) AS 'Europe',
SUM(IF(continent.name = 'Asia' AND ((mountain.elevation * 3.28) > 10000),1,0)) AS 'Asia'
FROM mountain JOIN mountain_range USING(range_id)
JOIN continent ON(continent.cont_id = mountain_range.range_id)

UNION

SELECT 'Low' AS Category,
SUM(IF(continent.name = 'North America' AND ((mountain.elevation * 3.28) < 10000),1,0)) AS 'North America',
SUM(IF(continent.name = 'Europe' AND ((mountain.elevation * 3.28) < 10000),1,0)) AS 'Europe',
SUM(IF(continent.name = 'Asia' AND ((mountain.elevation * 3.28) < 10000),1,0)) AS 'Asia'
FROM mountain JOIN mountain_range USING(range_id)
JOIN continent ON(continent.cont_id = mountain_range.range_id);

/*

*/

notee
