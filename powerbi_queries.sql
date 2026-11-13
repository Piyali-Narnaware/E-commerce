-- Reporting views for the public Olist e-commerce dataset
-- Grain: v_FactOrders = one order item; v_FactOrderSummary = one order
-- Run with SQLite against the full Olist source tables.

DROP VIEW IF EXISTS v_FactOrders;
CREATE VIEW v_FactOrders AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    DATE(o.order_purchase_timestamp) AS order_date,
    o.order_purchase_timestamp,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS item_total_including_freight
FROM olist_order_items_dataset AS oi
JOIN olist_orders_dataset AS o ON o.order_id = oi.order_id;

-- Aggregate payments, reviews and order items separately before joining.
-- Payment values can include installments and may differ from item totals.
DROP VIEW IF EXISTS v_FactOrderSummary;
CREATE VIEW v_FactOrderSummary AS
WITH item_totals AS (
    SELECT order_id, COUNT(*) AS units_sold,
           SUM(price) AS product_revenue,
           SUM(freight_value) AS freight_revenue
    FROM olist_order_items_dataset GROUP BY order_id
),
payment_totals AS (
    SELECT order_id, SUM(payment_value) AS payment_total,
           COUNT(*) AS payment_records
    FROM olist_order_payments_dataset GROUP BY order_id
),
review_totals AS (
    SELECT order_id, AVG(review_score) AS average_review_score,
           COUNT(*) AS review_records
    FROM olist_order_reviews_dataset GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    DATE(o.order_purchase_timestamp) AS order_date,
    o.order_purchase_timestamp,
    DATE(o.order_delivered_customer_date) AS delivered_date,
    DATE(o.order_estimated_delivery_date) AS estimated_delivery_date,
    COALESCE(i.units_sold, 0) AS units_sold,
    COALESCE(i.product_revenue, 0) AS product_revenue,
    COALESCE(i.freight_revenue, 0) AS freight_revenue,
    COALESCE(i.product_revenue, 0) + COALESCE(i.freight_revenue, 0) AS order_total_including_freight,
    p.payment_total,
    p.payment_records,
    r.average_review_score,
    r.review_records,
    CASE WHEN o.order_status = 'delivered'
              AND o.order_delivered_customer_date IS NOT NULL
              AND o.order_estimated_delivery_date IS NOT NULL
         THEN CASE WHEN DATE(o.order_delivered_customer_date) <= DATE(o.order_estimated_delivery_date)
                   THEN 1 ELSE 0 END
         ELSE NULL END AS delivered_on_time,
    CASE WHEN o.order_status = 'delivered'
              AND o.order_delivered_customer_date IS NOT NULL
         THEN julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp)
         ELSE NULL END AS delivery_days
FROM olist_orders_dataset AS o
LEFT JOIN item_totals AS i ON i.order_id = o.order_id
LEFT JOIN payment_totals AS p ON p.order_id = o.order_id
LEFT JOIN review_totals AS r ON r.order_id = o.order_id;

DROP VIEW IF EXISTS v_DimCustomer;
CREATE VIEW v_DimCustomer AS
SELECT customer_id, customer_unique_id, customer_city, customer_state,
       customer_zip_code_prefix
FROM olist_customers_dataset;

DROP VIEW IF EXISTS v_DimProduct;
CREATE VIEW v_DimProduct AS
SELECT p.product_id,
       COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
       p.product_name_lenght, p.product_description_lenght, p.product_photos_qty,
       p.product_weight_g, p.product_length_cm, p.product_height_cm,
       p.product_width_cm,
       ROUND(p.product_weight_g / 1000.0, 3) AS product_weight_kg,
       ROUND(p.product_length_cm * p.product_height_cm * p.product_width_cm, 2) AS product_volume_cm3
FROM olist_products_dataset AS p
LEFT JOIN product_category_name_translation AS t
  ON p.product_category_name = t.product_category_name;

DROP VIEW IF EXISTS v_DimSeller;
CREATE VIEW v_DimSeller AS
SELECT seller_id, seller_city, seller_state, seller_zip_code_prefix
FROM olist_sellers_dataset;

DROP VIEW IF EXISTS v_DimCalendar;
CREATE VIEW v_DimCalendar AS
WITH RECURSIVE dates(d) AS (
    SELECT MIN(DATE(order_purchase_timestamp)) FROM olist_orders_dataset
    UNION ALL
    SELECT DATE(d, '+1 day') FROM dates
    WHERE d < (SELECT MAX(DATE(order_purchase_timestamp)) FROM olist_orders_dataset)
)
SELECT d AS date,
       CAST(strftime('%Y', d) AS INTEGER) AS year,
       CAST(strftime('%m', d) AS INTEGER) AS month_no,
       strftime('%Y-%m', d) AS year_month,
       CAST((CAST(strftime('%m', d) AS INTEGER) + 2) / 3 AS INTEGER) AS quarter,
       CAST(strftime('%d', d) AS INTEGER) AS day,
       CAST(strftime('%w', d) AS INTEGER) AS weekday_no,
       CASE WHEN CAST(strftime('%w', d) AS INTEGER) IN (0, 6) THEN 0 ELSE 1 END AS is_weekday
FROM dates;

-- Kept as a separate one-row-per-delivered-order delivery reporting view.
DROP VIEW IF EXISTS v_CalcDeliveryKPIs;
CREATE VIEW v_CalcDeliveryKPIs AS
SELECT order_id, order_purchase_timestamp,
       order_delivered_customer_date, order_estimated_delivery_date,
       julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp) AS delivery_days,
       CASE WHEN order_delivered_customer_date IS NULL
                 OR order_estimated_delivery_date IS NULL THEN NULL
            WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN 1
            ELSE 0 END AS delivered_on_time
FROM olist_orders_dataset
WHERE order_status = 'delivered';
