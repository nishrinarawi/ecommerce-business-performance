--===Annual Customer Activity Growth Analysis===---
Name 		: Nishrina Rawi
LinkedIn 	: linkedin.com/in/nishrina-rawi
E-mail 		: nishrinarawi@gmail.com

-----monthly average active user per year
WITH monthly_active_user AS(
	SELECT date_part('month', o.order_purchase_timestamp) AS month, 
			date_part('year', o.order_purchase_timestamp) AS year,
	        COUNT(DISTINCT cd.customer_unique_id) AS active_user
	FROM orders_dataset AS o
	JOIN customer_dataset AS cd ON o.customer_id = cd.customer_id
	GROUP BY year, month)
SELECT year, FLOOR(AVG(active_user)) AS avg_mau
FROM monthly_active_user
GROUP BY year;

-----new customer per year
SELECT date_part('year', new_customer.first_order) AS year, COUNT(*) AS number_of_new_customer
FROM (SELECT cd.customer_unique_id, MIN(order_purchase_timestamp) AS first_order, COUNT(*)
	FROM orders_dataset AS o
	JOIN customer_dataset cd
	ON o.customer_id=cd.customer_id
	GROUP BY cd.customer_unique_id) AS new_customer
GROUP BY year
ORDER BY year;

-----repeat customer (customer order > 1 per year)
SELECT repeat_order.year, COUNT(repeat_order.total_order) repeat_customer
FROM (SELECT date_part('year', order_purchase_timestamp) AS year, customer_unique_id, COUNT(order_id) AS total_order
	  FROM orders_dataset AS o
	  JOIN customer_dataset cd
	  ON o.customer_id=cd.customer_id
	  GROUP BY 1,2
	  HAVING COUNT(order_id) > 1) AS repeat_order
GROUP BY 1;

-----customer average order per year
WITH avg_cust_order AS(
	SELECT date_part('year', o.order_purchase_timestamp) AS year, 
	cd.customer_unique_id AS cust, 
	COUNT(o.order_id) AS freq_of_order
	FROM orders_dataset AS o
	JOIN customer_dataset AS cd
	ON cd.customer_id = o.customer_id
	GROUP BY year, cust
	ORDER BY 3 DESC)
SELECT year, ROUND(AVG(freq_of_order),2) AS avg_customer_order
FROM avg_cust_order
GROUP BY year
ORDER BY year;

-----join metrics
WITH monthly_active_user AS(
	SELECT year, FLOOR(AVG(active_user)) AS avg_mau
	FROM (
		SELECT date_part('month', o.order_purchase_timestamp) AS month, 
		date_part('year', o.order_purchase_timestamp) AS year,
		COUNT(DISTINCT cd.customer_unique_id) AS active_user
		FROM orders_dataset AS o
		JOIN customer_dataset AS cd ON o.customer_id = cd.customer_id
		GROUP BY year, month) subq
	GROUP BY year
), new_customer AS(
	SELECT date_part('year', first_order) AS year, COUNT(*) AS number_of_new_customer
	FROM (
		SELECT cd.customer_unique_id, MIN(order_purchase_timestamp) AS first_order, COUNT(*)
		FROM orders_dataset AS o
		JOIN customer_dataset cd
		ON o.customer_id=cd.customer_id
		GROUP BY cd.customer_unique_id) AS subq
	GROUP BY year
	ORDER BY year
), repeat_order AS(
	SELECT year, COUNT(total_order) AS repeat_customer
	FROM (
		SELECT date_part('year', order_purchase_timestamp) AS year, 
		customer_unique_id, COUNT(order_id) AS total_order
		FROM orders_dataset AS o
		JOIN customer_dataset cd
		ON o.customer_id=cd.customer_id
		GROUP BY 1,2
		HAVING COUNT(order_id) > 1) AS subq
	GROUP BY 1
), cust_avg_order AS(
	SELECT year, ROUND(AVG(freq_of_order),2) AS avg_customer_order
	FROM (
		SELECT date_part('year', o.order_purchase_timestamp) AS year, 
		cd.customer_unique_id AS cust, COUNT(o.order_id) AS freq_of_order
		FROM orders_dataset AS o
		JOIN customer_dataset AS cd
		ON cd.customer_id = o.customer_id
		GROUP BY year, cust
		ORDER BY 3 DESC) subq
	GROUP BY year
	ORDER BY year)
SELECT m.year, avg_mau, number_of_new_customer, repeat_customer, avg_customer_order
FROM monthly_active_user AS m
JOIN new_customer AS n ON m.year=n.year
JOIN repeat_order AS r ON m.year=r.year
JOIN cust_avg_order AS cao ON m.year=cao.year
GROUP BY 1,2,3,4,5;
