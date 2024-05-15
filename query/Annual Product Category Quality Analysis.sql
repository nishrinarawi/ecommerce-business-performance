--===Annual Product Category Quality Analysis===---
Name 		: Nishrina Rawi
LinkedIn 	: linkedin.com/in/nishrina-rawi
E-mail 		: nishrinarawi@gmail.com

---total_revenue by year
CREATE TABLE total_revenue AS(
	SELECT date_part('year', order_purchase_timestamp) AS year, 
		ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue
	FROM (
		SELECT oi.order_id, o.order_status, o.order_purchase_timestamp ,
		oi.price+oi.freight_value AS total_revenue
		FROM order_items_dataset AS oi 
		JOIN orders_dataset AS o ON oi.order_id = o.order_id
		WHERE o.order_status='delivered') subq
	GROUP BY 1
	ORDER BY 1);
	

---canceled order by year
CREATE TABLE total_canceled AS (
	SELECT year, COUNT(*) AS total_canceled
	FROM (
		SELECT date_part('year', order_purchase_timestamp) AS year, order_id, order_status
		FROM orders_dataset
		WHERE order_status='canceled'
		GROUP BY order_id) subq
	GROUP BY 1
	ORDER BY 1);

---product with highest revenue by year
CREATE TABLE top_highest_revenue AS (
	WITH highest_revenue_prod AS (
		SELECT date_part('year', o.order_purchase_timestamp) AS year,
        	prod.product_category_name AS category,
        	ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        	ROW_NUMBER() OVER(PARTITION BY date_part('year', o.order_purchase_timestamp) ORDER BY SUM(oi.price + oi.freight_value) DESC) AS rank
		FROM product_dataset AS prod
		JOIN order_items_dataset AS oi ON prod.product_id = oi.product_id
		JOIN orders_dataset AS o ON o.order_id = oi.order_id
		WHERE o.order_status='delivered'
		GROUP BY date_part('year', o.order_purchase_timestamp), prod.product_category_name
	)
	SELECT year, category AS top_highest_revenue, revenue
	FROM highest_revenue_prod
	WHERE rank = 1);

---most canceled product
CREATE TABLE most_canceled_prod AS (
	SELECT year, top_canceled_cat, canceled_num
	FROM (
		SELECT date_part('year', o.order_purchase_timestamp) AS year, 
		prod.product_category_name AS top_canceled_cat, COUNT(*) AS canceled_num,
		ROW_NUMBER () OVER(PARTITION BY date_part('year', o.order_purchase_timestamp) ORDER BY COUNT(*) DESC) AS rank
		FROM orders_dataset AS o
		JOIN order_items_dataset AS oi ON oi.order_id = o.order_id
		JOIN product_dataset AS prod ON prod.product_id=oi.product_id
		WHERE o.order_status='canceled'
		GROUP BY 1,2) subq
	WHERE rank=1);

---join table
SELECT tr.year, thr.top_highest_revenue, thr.revenue, tr.total_revenue,
		mcp.top_canceled_cat, mcp.canceled_num, tc.total_canceled
FROM total_revenue AS tr 
JOIN total_canceled AS tc ON tr.year=tc.year
JOIN top_highest_revenue AS thr ON thr.year=tr.year
JOIN most_canceled_prod AS mcp ON mcp.year=tr.year;






