/* Below is code to remove duplicates from the play_ and app_store_apps tables
   and to render the tables usable for subsequent queries.
*/
WITH pretty_play_table AS
      (SELECT DISTINCT *
       FROM play_store_apps
       ORDER BY name)

/* Analysis for most popular content_rating in the Android Play Store.
   Conclusion: Over 80% of Android Play App Customers are in the 'Everyone' category 
   with 'Teen' constituting about 11%, together these categories make up over 90%
   of Android Play Store's consumer market.
*/
SELECT content_rating,
       count(content_rating) AS count_rating,
       concat(round(count(*) * 100.0 / SUM (COUNT (*)) OVER (), 2), '%') AS percentage_total
FROM pretty_play_table
GROUP BY content_rating
ORDER BY count_rating DESC;

/* Analysis for most popular content_rating in the Apple App Store.
   Conclusion: Over 60% of Apple App Customers are in the '4+' category 
   with '12+' constituting about 16%, together these categories make up almost 80%
   of Android Play Store's consumer market.
*/
WITH pretty_app_table AS
      (SELECT DISTINCT *
       FROM app_store_apps
       ORDER BY name)
       
SELECT content_rating,
       count(content_rating) AS count_rating,
       concat(round(count(*) * 100.0 / SUM (COUNT (*)) OVER (), 2), '%') AS percentage_total
FROM pretty_app_table
GROUP BY content_rating
ORDER BY count_rating DESC;


/* Analysis for most popular category in the Android Play Store.
   Conclusion: Almost 20% of Android Play App apps fall in the 'Family' category 
   with 'Game' constituting about 11%, together these categories make up almost 30%
   of Android Play Store's consumer market.
*/
WITH pretty_play_table AS
      (SELECT DISTINCT *
       FROM play_store_apps
       ORDER BY name)
       
SELECT category,
       count(category) AS category_count,
       concat(round(count(*) * 100.0 / SUM (COUNT (*)) OVER (), 2), '%') AS percentage_total
FROM pretty_play_table
GROUP BY category
ORDER BY category_count DESC
LIMIT 5;


/* Analysis for most popular category in the Apple App Store.
   Conclusion: Over 50% of Apple's App Store apps fall in the 'Games' category 
   with 'Entertainment' constituting about 7% of Android Play Store's consumer market.
*/
WITH pretty_app_table AS
      (SELECT DISTINCT *
       FROM app_store_apps
       ORDER BY name)
       
SELECT primary_genre,
       count(primary_genre) AS genre_count,
       concat(round(count(*) * 100.0 / SUM (COUNT (*)) OVER (), 2), '%') AS percentage_total
FROM pretty_app_table
GROUP BY primary_genre
ORDER BY genre_count DESC
LIMIT 5;


