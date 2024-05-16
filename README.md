# E-commerce Business Performance with SQL


## Overview  
In a company, measuring business performance is crucial for tracking, monitoring, and evaluating the success or failure of various business processes. Therefore, this paper will analyze the business performance of an eCommerce company, taking into account several business metrics such as customer growth, product quality, and payment methods.

## Analysis  
### Data Preparation 
An e-commerce platform has 8 data tables regarding sales. These 8 tables are inserted into a database named eCommerce, taking into account the data types of each column to maintain data integrity. Each column has a primary key used to identify each row of each table. The tables are also linked with foreign keys allowing seamless data integration and consistent updates. Here are the steps taken:  
1. Create table and upload dataset


<details>
  <summary> Click to see query </summary>
    <br>

```sql
--==ORDER_ITEMS_DATASET==--

--create table 
CREATE TABLE order_items_dataset(
    order_id VARCHAR(50),
    order_item_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP WITHOUT TIME ZONE,
    price DOUBLE PRECISION,
    freight_value DOUBLE PRECISION
);

--import table
COPY order_items_dataset(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
FROM 'D:\Study\Rakamin\Porto\Dataset\order_items_dataset.csv'
DELIMITER ','
CSV HEADER;


--==PRODUCT_DATASET==--

---create table
CREATE TABLE product_dataset(
	num INTEGER,
	product_id VARCHAR(50),
	product_category_name CHAR(50),
	product_name_length float4,
	product_description_lenght float4,
    product_photos_qty float4,
    product_weight_g float4,
    product_lenght_cm float4,
    product_height_cm float4,
    product_width_cm float4
);

--import table
COPY product_dataset(
	num,
	product_id,
	product_category_name,
	product_name_length,
	product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_lenght_cm,
    product_height_cm,
    product_width_cm
)
FROM 'D:\Study\Rakamin\Porto\Dataset\product_dataset.csv'
DELIMITER ','
CSV HEADER;


--==ORDERS_DATASET==--

--create table 
CREATE TABLE orders_dataset(
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status CHAR(20),
    order_purchase_timestamp TIMESTAMP WITHOUT TIME ZONE,
    order_approved_at TIMESTAMP WITHOUT TIME ZONE,
    order_delivered_carrier_date TIMESTAMP WITHOUT TIME ZONE,
    order_delivered_customer_date TIMESTAMP WITHOUT TIME ZONE,
    order_estimated_delivery_date TIMESTAMP WITHOUT TIME ZONE
);

--import dataset
COPY orders_dataset(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
FROM 'D:\Study\Rakamin\Porto\Dataset\orders_dataset.csv'
DELIMITER ','
CSV HEADER;


--==REVIEWS_DATASET==--

--create table
CREATE TABLE reviews_dataset(
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title VARCHAR(50),
    review_comment_message VARCHAR(250),
    review_creation_date TIMESTAMP WITHOUT TIME ZONE,
    review_answer_timestamp TIMESTAMP WITHOUT TIME ZONE
);

--import csv
COPY reviews_dataset(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
FROM 'D:\Study\Rakamin\Porto\Dataset\order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;


--==SELLERS_DATASET==--

--create table
CREATE TABLE sellers_dataset(
    seller_id VARCHAR(50),
    seller_zip_code_prefix CHAR(5),
    seller_city CHAR(100),
    seller_state CHAR(10)
);

--import csv
COPY sellers_dataset(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
FROM 'D:\Study\Rakamin\Porto\Dataset\sellers_dataset.csv'
DELIMITER ','
CSV HEADER;


--==PAYMENT_DATASET==--

--create table
CREATE TABLE payments_dataset(
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value DOUBLE PRECISION
);

--import csv
COPY payments_dataset(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
FROM 'D:\Study\Rakamin\Porto\Dataset\order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;


--==GEOLOCATION_DATASET==--

---create table
CREATE TABLE geolocation_dataset(
    geolocation_zip_code_prefix VARCHAR(50),
    geolocation_lat DOUBLE PRECISION,
    geolocation_lng DOUBLE PRECISION,
    geolocation_city VARCHAR(40),
    geolocation_state CHAR(5)
);

--import csv
COPY geolocation_dataset(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
FROM 'D:\Study\Rakamin\Porto\Dataset\geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

--cleaning geolocation_dataset duplicated data to create clean dataset named geolocation
CREATE TABLE geolocation AS
WITH geolocation_cte AS(
	SELECT geolocation_zip_code_prefix, 
	geolocation_lat, geolocation_lng, 
	geolocation_city, geolocation_state
	FROM (SELECT geolocation_zip_code_prefix, geolocation_lat, 
		  geolocation_lng, geolocation_city, geolocation_state,
		  ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix) AS row_num
		  FROM geolocation_dataset
		 ) AS sub
	WHERE row_num = 1
),
cust_cte AS(
	SELECT customer_zip_code_prefix, geolocation_lat, 
	geolocation_lng, customer_city, customer_state
	FROM (
		SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_zip_code_prefix) AS row_num
		FROM (SELECT customer_zip_code_prefix, geolocation_lat, 
			  geolocation_lng, customer_city, customer_state
			  FROM customer_dataset cust
			  LEFT JOIN geolocation_dataset geods
			  ON cust.customer_city = geods.geolocation_city
			  AND cust.customer_state = geods.geolocation_state
			  WHERE cust.customer_zip_code_prefix NOT IN (
				  SELECT geolocation_zip_code_prefix
				  FROM geolocation_cte)
			 ) geo_sub
	) cust_geo
	WHERE row_num = 1
),
seller_cte AS(
	SELECT seller_zip_code_prefix, geolocation_lat, 
	geolocation_lng, seller_city, seller_state
	FROM (
		SELECT *, ROW_NUMBER() OVER(PARTITION BY seller_zip_code_prefix) AS row_num
		FROM (
			SELECT seller_zip_code_prefix, geolocation_lat, 
			geolocation_lng, seller_city, seller_state
			FROM sellers_dataset sell
			LEFT JOIN geolocation_dataset geods
			ON sell.seller_city=geods.geolocation_city
			AND sell.seller_state=geods.geolocation_state
			WHERE sell.seller_zip_code_prefix NOT IN(
				SELECT geolocation_zip_code_prefix
				FROM geolocation_cte
				UNION
				SELECT customer_zip_code_prefix
				FROM cust_cte)
		)geo_seller_sub
	) seller_geo
	WHERE row_num = 1
)
SELECT * 
FROM geolocation_cte
UNION
SELECT * 
FROM cust_cte
UNION
SELECT *
FROM seller_cte;


--==CUSTOMER_DATASET==--

--create table
CREATE TABLE customer_dataset(
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix CHAR(5),
    customer_city VARCHAR(40),
    customer_state CHAR(5)
);

--import csv
COPY customer_dataset(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
FROM 'D:\Study\Rakamin\Porto\Dataset\customers_dataset.csv'
DELIMITER ','
CSV HEADER;
```
<br>
</details>
<br>

2. Set Primary Key and Foreign Key

<details>
  <summary> Click to see query </summary>
    <br>


**Primary key**
```sql
ALTER TABLE product_dataset ADD CONSTRAINT product_dataset_pkey PRIMARY KEY (product_id);
ALTER TABLE orders_dataset ADD CONSTRAINT orders_dataset_pkey PRIMARY KEY (order_id);
ALTER TABLE sellers_dataset ADD CONSTRAINT sellers_dataset_pkey PRIMARY KEY (seller_id);
ALTER TABLE customer_dataset ADD CONSTRAINT customer_dataset_pkey PRIMARY KEY (customer_id);
ALTER TABLE geolocation ADD CONSTRAINT geolocation_pkey PRIMARY KEY (geolocation_zip_code_prefix);
```
**Foreign Key**
```sql
ALTER TABLE order_items_dataset ADD FOREIGN KEY (product_id) REFERENCES product_dataset;
ALTER TABLE order_items_dataset ADD FOREIGN KEY (seller_id) REFERENCES sellers_dataset;
ALTER TABLE order_items_dataset ADD FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE payments_dataset ADD FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE reviews_dataset ADD FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE orders_dataset ADD FOREIGN KEY (customer_id) REFERENCES customer_dataset;
ALTER TABLE sellers_dataset 
	ADD CONSTRAINT zip_code_prefix FOREIGN KEY (seller_zip_code_prefix)
	REFERENCES geolocation (geolocation_zip_code_prefix);
ALTER TABLE customer_dataset
    ADD CONSTRAINT zip_code_prefix FOREIGN KEY (customer_zip_code_prefix)
    REFERENCES geolocation (geolocation_zip_code_prefix);
```

<br>
</details>
<br>

3. Entity Relationship Diagram <br>
![erd](https://github.com/nishrinarawi/ecommerce-business-performance/blob/5a522a7d7769f29ed443142c8f8783e294684914/assets/ERD%20Ecommerce.png)
   
