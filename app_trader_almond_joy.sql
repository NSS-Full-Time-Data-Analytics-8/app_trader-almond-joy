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
SELECT *,
	avg_price_to_purchase + (1000*(lifespan_yrs*12)) AS gross_cost,
	(5000*(lifespan_yrs*12)) AS gross_profit,
	((5000*(lifespan_yrs*12))) - (avg_price_to_purchase + (1000*(lifespan_yrs*12))) AS net_profit
FROM distinct_appstores
WHERE ((5000*(lifespan_yrs*12))) - (avg_price_to_purchase + (1000*(lifespan_yrs*12))) > 0
AND avg_price::numeric < 2.00
AND play_genre = 'GAME' AND app_genre = 'Games'
AND play_content_rating = 'Everyone' AND app_content_rating = '4+'
ORDER BY net_profit DESC;

