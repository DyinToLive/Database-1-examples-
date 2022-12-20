/*
* file: asg1.sql, Comp2521, Assignment 1, October 10, Fall 2021
* Jameson Watson
* Comp2521-001
*/


\. rm -f asg1.log

tee asg1.log
/* 1 */
SELECT NOW();
/* 2  - Count the siting times to get the total number of sightings.
Min and Max operations gather the earliest and most recent sighting */
SELECT format(COUNT(sighting_time),0) AS UFOsightings,
MIN(sighting_date) AS earliest_sighting,
MAX(sighting_date) AS most_recent_sighting
FROM fact_ufo;

/* 3 - Count the siting times to get the total number of sightings.
Relate the fact_ufo to the dim_state db to ensure the sightings
are accounted for and make sense*/
SELECT format(COUNT(sighting_time),0) AS UFOsightings
FROM fact_ufo, dim_state
WHERE dim_state.state_id = fact_ufo.state;

/* 4 -Select and count the cities ufo sightings and order them in
descending order limit 20 to get the top 20 city sightings. */
SELECT city,
COUNT(*) AS topCityUFOsightings
FROM fact_ufo
GROUP BY city
ORDER BY COUNT(*) DESC
LIMIT 20;

/* 5 - Repeat the process of question four but group by sightings
being greater than 100 to count all of the cities with more than
100 sightings.*/
SELECT city,
COUNT(*) AS UFOsightings
FROM fact_ufo
GROUP BY city HAVING UFOsightings > 100
ORDER BY COUNT(*) DESC;

/* 6 - The IF statement in the line 46 indicates that if zodiac
is an empty string, we will replace it with the word MISSING,
otherwise we will continue to use zodiac. The where clause ensures
that we limit the data between the two tables so that their dates
are equal to eachother. */
SELECT IF(zodiac = "","MISSING", zodiac) AS zodiac_sign,
(format(COUNT(*),0)) AS sightings
FROM dim_date AS dim, fact_ufo AS fact
WHERE dim.dim_date = fact.sighting_date
GROUP BY zodiac
ORDER BY COUNT(*);

/* 7 - Select the siting months and format the count so that they are
represented with the thousands separator. The result is the sighting 
months from January to December along with their total sitings. */
SELECT dim.dim_month AS sightingMonth,
(format(COUNT(*),0)) AS numSightings
FROM dim_date AS dim, fact_ufo AS fact
WHERE dim.dim_date = fact.sighting_date
GROUP BY dim.dim_month
ORDER BY dim.dim_mon asc;

/* 8 - I tried to use trim with the min length and got the same answer
so i left the code as it is. This query selects all comments from fact_ufo
database and organizes the comments into total comments maximum length, 
minimum length, and average length respectively. The query does not include
comments that are null or empty strings.  */
SELECT COUNT(comments),
MAX(LENGTH(comments)) AS maxCommLen,
MIN(LENGTH(comments)) AS minCommLen,
AVG(LENGTH(comments)) AS avgCommLen
FROM fact_ufo
WHERE comments IS NOT NULL AND COMMENTS != "";

/* 9 - Explored different options of strings to put in the where clause to
 get a more accurate count. Comments like "fireball" or  "fir" seem to
discover all of the comments in an appropriate amount of code.*/
SELECT COUNT(comments) as commentsLikeFireball
FROM fact_ufo
WHERE comments LIKE "%fireball%"
OR comments LIKE "%fir%";



/* 10 - This query collects data from dim_time, dim_state, and fact ufo in
order to analyze the amount of sightings in Vancouver, BC. To ensure data
is not ambiguous we condition dim_time to fact_ufo time of sightings and
fact_ufo.city to make sure that the sightings are in Vancouver.
The data is then organized by the field dim_time from morning to night.*/
SELECT COUNT(*) AS vancouverSightings, dim_time.time_of_day
FROM fact_ufo, dim_time, dim_state
WHERE dim_time.dim_time = fact_ufo.sighting_time
AND (fact_ufo.state = dim_state.state_id)
AND (fact_ufo.city = "Vancouver")
GROUP BY dim_time.time_of_day
ORDER BY FIELD(dim_time.time_of_day, "Morning", "Afternoon", "Evening", "Night");

/* 11 - The database has the latitude and longitude listed in decimal; positive
numbers indicate northern hemisphere and negative numbers indicate the southern
hemisphere. Knowing this we can use an if statement to select the latitude and
count the number of sightings per state */
SELECT IF(latitude < 0, "South", "North") AS directionOfHemisphere,
COUNT(state) AS sightings
FROM fact_ufo
GROUP BY directionOfHemisphere;

/* 12 - It is possible that the reason for lack of ufo sightings recorded in the 
southern hemisphere is due to the lack of technology to report the sightings, 
poverty affecting the interest that they would have if they encountered a UFO, or
an error in collecting and organizing the data in the database. */

/* 13  - This query displays the first 20 characters of a comment followed by (...),
 the decimal, minute, and second coordinates, and the decimal value of those 
coordinates. ABS command negates all of the negative numbers (South and West).
The formula is as follows:
1. Degrees use the whole number part of the decimal.
2. Minutes multiply remainder of the decimal by 60.
3. Seconds multiply the new remaining decimal by 60. 
*/

SELECT fact_ufo.City AS City,
dim_state.state AS State ,dim_state.country AS Country,
IF(LENGTH(comments) < 21, comments,
CONCAT(SUBSTRING(comments, 1,20), '(...)')) AS Comments,
CONCAT(ABS(FLOOR(latitude)),'°',ROUND((latitude - FLOOR(latitude)) * 60),'',
ROUND(((latitude - FLOOR(latitude) * 60)
- FLOOR(latitude - FLOOR(latitude) * 60))) * 60,'” ',
IF(latitude > 0, 'N,', 'S,'),' ',
ABS(FLOOR(longitude)),'°',ROUND((longitude - FLOOR(longitude)) * 60),'',
ROUND(((longitude - FLOOR(longitude) * 60)
- FLOOR(longitude - FLOOR(longitude) * 60))) * 60,'” ',
IF(longitude > 0, 'E', 'W')) AS DMS,
CONCAT(latitude,', ',longitude) AS decimalValue
FROM fact_ufo, dim_state
WHERE fact_ufo.state = dim_state.state_id
LIMIT 100;

notee
