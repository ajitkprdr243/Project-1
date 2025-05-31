create database olistStore;
USE OlistStore;
SHOW Tables;

SELECT * FROM olist_customers_dataset;
SELECT * FROM olist_geolocation_dataset;
SELECT * FROM olist_order_items_dataset;
SELECT * FROM olist_order_payments_dataset;
SELECT * FROM olist_order_reviews_dataset;
SELECT * FROM olist_orders_dataset;
SELECT * FROM olist_products_dataset;
SELECT * FROM olist_sellers_dataset;
SELECT * FROM product_category_name_translation;

## 1 ##
-- 1). WEEKDAY VS WEEKEND PAYMENT STATISTICS:
select order_id,order_purchase_timestamp,
CASE 
WHEN DAYOFWEEK( order_purchase_timestamp)IN(1,7)THEN'Weekend'
ELSE'Weekday'
END AS day_type FROM olist_orders_dataset
LIMIT 0,1000;


-- DATETIME IS CONVERTED TO DATE FORMAT
SELECT DATE(order_purchase_timestamp) AS purchase_date, 
       CASE WHEN DAYOFWEEK(order_purchase_timestamp) IN (1, 7) 
            THEN 'weekend'
            ELSE 'weekday' 
       END AS day_type 
FROM olist_orders_dataset ;


## 2 ##
-- 2).Number of Orders with review score 5 and payment type as credit card
SELECT COUNT(*) AS num_orders
FROM olist_order_reviews_dataset 
INNER JOIN olist_order_payments_dataset 
ON olist_order_reviews_dataset.order_id = olist_order_payments_dataset.order_id 
WHERE olist_order_reviews_dataset.review_score = 5 
AND olist_order_payments_dataset.payment_type = "credit_card" ;


## 3 ##
-- 3) Average number of days taken for order_delivered_customer_date for pet_shop

SELECT 
AVG(DATEDIFF(o.order_delivered_customer_date,o.order_approved_at)) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_order_items_dataset  oi ON o.order_id=oi.order_id
JOIN olist_products_dataset p ON oi.product_id=p.product_id
WHERE product_category_name='pet_shop';



## 4 ##
-- 4) Average price and payment values from customers of sao paulo city
select concat('R$',format(avg(price),2)) as avg_price,concat('R$',format(avg(payment_value),2)) as avg_payment_value from olist_order_payments_dataset 
inner join olist_order_items_dataset 
on olist_order_payments_dataset.order_id = olist_order_items_dataset.order_id
inner join olist_orders_dataset 
on olist_order_items_dataset.order_id = olist_orders_dataset.order_id
inner join olist_customers_dataset 
on olist_orders_dataset.customer_id = olist_customers_dataset.customer_id 
where customer_city="sao paulo";

## 5 ##
-- 5) Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
 SELECT
r.review_score,
AVG(DATEDIFF(o.order_delivered_customer_date,o.order_purchase_timestamp))AS avg_shipping_days,
COUNT(o.order_id)AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id=r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

## Average number of days taken for order_delivered_customer_date for pet_shop ---
SELECT CONCAT(ROUND(avg(no_of_days_for_delivery),2),"DAYS") AS
 AVG_number_of_days_taken_for_pet_shop FROM olist_orders_dataset
JOIN olist_order_items_dataset USING(order_id)
JOIN olist_products_dataset USING (product_id)
WHERE product_category_name IN ("pet_shop");

## Average price and payment values from customers of sao paulo city ##
SELECT ROUND(avg(price),2) AS AVERAGE_PRICE , ROUND(avg(payment_value),2)AS PAYMENT_VALUE from olist_order_items_dataset
join olist_order_payments_dataset using (order_id)
join olist_orders_dataset using (order_id)
join olist_customers_dataset using(customer_id)
where customer_city in ("sao paulo");

## Relationship between shipping days VS review scores##
SELECT no_of_days_for_delivery as NO_OF_DAYS_TAKEN_FOR_DELIVERY,round(avg(review_score),2) asreview_scores from olist_orders_dataset
JOIN olist_order_reviews_dataset USING (order_id)
group by no_of_days_for_delivery
order by no_of_days_for_delivery asc;

## CITY WISE ORDERS ##
SELECT distinct customer_city ,CONCAT(ROUND(COUNT(order_id)/1000,1),"K")
as TOTAL_ORDERS FROM olist_customers_dataset
JOIN olist_orders_dataset using (customer_id)
group by customer_city
order by COUNT(order_id) DESC;

## PRODUCT CATEGORY NAME VS NO OF ORDERS ## 
SELECT product_category_name_english AS PRODUCT_CATEGORY_NAME,
concat(round(COUNT(ORDER_ID)/1000,1),"K" )AS NO_OF_ORDERS FROM olist_order_items_dataset
JOIN olist_products_dataset USING (product_id)
JOIN product_category_name_translation using (product_category_name)
group by product_category_name_english
order by COUNT(ORDER_ID)DESC;

## YEAR WISE NO OF ORDERS VS TOTAL PAYMENT ##
SELECT order_purchase_year,concat(round(COUNT(order_id)/1000),2,"K")AS NO_OF_ORDERS,
CONCAT(ROUND(SUM(payment_value)/1000),"K") AS TOTAL_PAYMENT from olist_orders_dataset
JOIN olist_order_payments_dataset USING (order_id)
group by order_purchase_year
ORDER BY concat(round(count(order_id)/1000),2,"K") DESC,CONCAT(ROUND(SUM(payment_value)/1000),"K")DESC;

SELECT PAYMENT_TYPE,concat(ROUND(COUNT(ORDER_ID)/1000,1),"K") AS NO_OF_ORDERS,REVIEW_SCORE
WHERE REVIEW_SCORE=5
GROUP BY PAYMENT_TYPE
HAVING PAYMENT_TYPE="CREDIT_CARD";







