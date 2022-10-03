/*
### 2. Assumptions
Based on research completed prior to launching App Trader as a company, you 
can assume the following:  

a. App Trader will purchase apps for 10,000 times the price of the app, however 
the minimum price to purchase an app is $25,000.  For example, a $3 app would 
cost $30,000 (10,000 x the price) and a free app would cost $25,000 
(The minimum price).  NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.  

b. Apps earn $5000 per month on average from in-app advertising and in-app 
purchases _regardless_ of the price of the app.  

c. App Trader will spend an average of $1000 per month to market an 
app _regardless_ of the price of the app. If App Trader owns rights to the 
app in both stores, it can market the app for both stores for a single cost 
of $1000 per month.  

d. For every quarter-point that an app gains in rating, its projected 
lifespan increases by 6 months, in other words, an app with a rating of 0 
can be expected to be in use for 1 year, an app with a rating of 1.0 can be 
expected to last 3 years, and an app with a rating of 4.0 can be expected to 
last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an 
app's likely longevity.  

e. App Trader would prefer to work with apps that are available in both the 
App Store and the Play Store since they can market both for the same $1000 
per month.
*/

WITH distinct_appstores AS 
	(SELECT 
	 	DISTINCT name, 
	 	app_store_apps.price::money AS app_price, 
	 	app_store_apps.rating AS app_rating,
	 	app_store_apps.primary_genre AS app_genre,
	 	app_store_apps.review_count::integer AS app_review_count,
	 	app_store_apps.content_rating AS app_content_rating,
	 
	 	play_store_apps.price::money AS play_price, 
	 	play_store_apps.rating AS play_rating, 
	 	play_store_apps.category AS play_genre,
	 	play_store_apps.review_count AS play_review_count,
	 	play_store_apps.content_rating AS play_content_rating,
	 
	 	(app_store_apps.price::money + play_store_apps.price::money)/2 AS avg_price,
	 	ROUND(((app_store_apps.rating + play_store_apps.rating)/2)/25,2)*25 AS avg_rating,
	 	(app_store_apps.review_count::integer + play_store_apps.review_count)/2 AS avg_review_count,
	 	2*(ROUND(((app_store_apps.rating + play_store_apps.rating)/2)/25,2)*25)+1 AS lifespan_yrs,
	 
	 	CASE WHEN ((app_store_apps.price::money + play_store_apps.price::money)/2)::numeric >=2.5 THEN 
	 		(((app_store_apps.price::money + play_store_apps.price::money)/2)::numeric *10000)
	 	ELSE 25000 END AS avg_price_to_purchase
FROM app_store_apps INNER JOIN play_store_apps USING(name))

SELECT DISTINCT(name),
	avg_price,
	avg_rating,
	--avg_review_count,
	avg_price_to_purchase,
	(avg_price_to_purchase + (1000*(lifespan_yrs*12)))::money AS gross_cost,
	(5000*(lifespan_yrs*12))::money AS gross_profit,
	(((5000*(lifespan_yrs*12))) - (avg_price_to_purchase + (1000*(lifespan_yrs*12))))::money 
		AS net_profit
FROM distinct_appstores
--Searching for Halloween-themed apps 
/*WHERE ((5000*(lifespan_yrs*12))) - (avg_price_to_purchase + (1000*(lifespan_yrs*12))) > 0
	AND app_genre ILIKE('%game%') AND play_genre ILIKE('%game%')
	ORDER BY net_profit DESC*/
/*
Temple Run, cost:145000, net profit: 455000
Five Nights at Freddy's, cost:149900, net profit: 450100
*/
WHERE avg_price::numeric < 2 AND app_genre ILIKE('%game%') AND play_genre ILIKE('%game%')
	AND app_content_rating = '4+' AND play_content_rating = 'Everyone'
ORDER BY net_profit DESC
LIMIT 10;


--Price range recommendation: <1.99 (top few hundred apps are at most $1.99)
--Genre recommendation: 
--	APP store: Games, Entertainment, Education
--	PLAY store: Games, Family
--Content Rating: 4+, 12+



--APP STORE QUERIES

--CTE to append price to purchase to data tables
WITH app_store_additions AS
	(SELECT *,
		CASE WHEN ((price::money + price::money)/2)::numeric >=2.5 THEN 
	 			(((price::money + price::money)/2)::numeric *10000)
	 		ELSE 25000 END AS app_price_to_purchase
	FROM app_store_apps)

--determining most profitable app store apps (proportional to highest rated)
SELECT *,
	app_price_to_purchase + (1000*(2*rating+1)*12) AS gross_cost,
	(5000*(2*rating+1)*12) AS gross_profit,
	((5000*(2*rating+1)*12)) - (app_price_to_purchase + (1000*(2*rating+1)*12)) AS net_profit
FROM app_store_additions
ORDER BY net_profit DESC;


--determining most frequent content rating apps
SELECT content_rating, COUNT(*)
FROM app_store_apps
GROUP BY content_rating
ORDER BY COUNT(*) DESC;
/*
4+: 4433
12+: 1155
9+: 987
17+: 622
*/

SELECT primary_genre, COUNT(*)
FROM app_store_apps
GROUP BY primary_genre
ORDER BY COUNT(*) DESC;
/* TOP THREE:
1) Games (3862)
2) Entertainment (535)
3) Education (453)
*/

--PLAY STORE QUERIES

--CTE to append price to purchase to data table
WITH play_store_additions AS
	(SELECT *,
		CASE WHEN ((price::money + price::money)/2)::numeric >=2.5 THEN 
	 			(((price::money + price::money)/2)::numeric *10000)
	 		ELSE 25000 END AS play_price_to_purchase
	FROM play_store_apps)

--determining most profitable app store apps (proportional to highest rated)
SELECT *,
	play_price_to_purchase + (1000*(2*rating+1)*12) AS gross_cost,
	(5000*(2*rating+1)*12) AS gross_profit,
	((5000*(2*rating+1)*12)) - (play_price_to_purchase + (1000*(2*rating+1)*12)) AS net_profit
FROM play_store_additions
ORDER BY net_profit DESC NULLS LAST;
--LIMIT 10

--determining most frequent content rating apps
SELECT content_rating, COUNT(*)
FROM play_store_apps
GROUP BY content_rating
ORDER BY COUNT(*) DESC;
/*
Everyone: 8714
Teen: 1208
Mature 17+: 499
Everyone 10+: 414
Adults only 18+: 3
Unrated: 2
*/

SELECT category, COUNT(*)
FROM play_store_apps
GROUP BY category
ORDER BY COUNT(*) DESC;
/* TOP THREE:
1) FAMILY (1972)
2) GAME (1144)
3) TOOLS (843)
*/