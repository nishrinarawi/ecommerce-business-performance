--===Annual Payment Type Usage Analysis===---
Name 		: Nishrina Rawi
LinkedIn 	: linkedin.com/in/nishrina-rawi
E-mail 		: nishrinarawi@gmail.com


---Payment Type Usage
SELECT payment_type, COUNT(*) AS total_payment_type_usage
FROM payments_dataset
GROUP BY 1
ORDER BY 2 DESC;


---Payment Type Usage by Year
SELECT payment_type, 
		SUM(CASE WHEN year=2016 THEN total ELSE 0 END) AS "2016",
		SUM(CASE WHEN year=2017 THEN total ELSE 0 END) AS "2017",
		SUM(CASE WHEN year=2018 THEN total ELSE 0 END) AS "2018",
		SUM(total) AS total_payment_type_usage
FROM(
	SELECT date_part('year',o.order_purchase_timestamp) AS year, 
			pay.payment_type AS payment_type, COUNT(*) AS total
	FROM payments_dataset AS pay
	JOIN orders_dataset AS o ON o.order_id = pay.order_id
	GROUP BY 1,2
	ORDER BY 2 DESC) subq
GROUP BY 1
ORDER BY 5 DESC;
