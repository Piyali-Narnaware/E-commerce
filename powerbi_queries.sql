-- ============================================================
-- Power BI - Optimized SQL Views
-- Run these against the SQLite DB to create a star-schema
-- then import each view as a table in Power BI Desktop.
-- ============================================================

-- 1. FactOrders: Core sales fact table
DROP VIEW IF EXISTS v_FactOrders;
CREATE VIEW v_FactOrders AS
SELECT
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.order_purchase_timestamp  AS order_date,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date AS delivered_date,
    o.order_estimated_delivery_date AS estimated_delivery_date,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value  AS total_order_value,
    pp.payment_type,
    pp.payment_installments,
    pp.payment_value,
    r.review_score
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi      ON o.order_id = oi.order_id
LEFT JOIN olist_order_payments_dataset pp ON o.order_id = pp.order_id AND pp.payment_sequential = 1
LEFT JOIN olist_order_reviews_dataset r   ON o.order_id = r.order_id;


-- 2. DimCustomer
DROP VIEW IF EXISTS v_DimCustomer;
CREATE VIEW v_DimCustomer AS
SELECT DISTINCT
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.customer_zip_code_prefix
FROM olist_customers_dataset c;


-- 3. DimProduct (with English category names)
DROP VIEW IF EXISTS v_DimProduct;
CREATE VIEW v_DimProduct AS
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    ROUND(p.product_weight_g / 1000.0, 3) AS product_weight_kg,
    ROUND(p.product_length_cm * p.product_height_cm * p.product_width_cm / 1000.0, 2) AS product_volume_cm3
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name_english
                                              OR p.product_category_name = t.product_category_name;


-- 4. DimSeller
DROP VIEW IF EXISTS v_DimSeller;
CREATE VIEW v_DimSeller AS
SELECT DISTINCT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix
FROM olist_sellers_dataset s;


-- 5. DimCalendar (auto-generated date dimension)
DROP VIEW IF EXISTS v_DimCalendar;
CREATE VIEW v_DimCalendar AS
WITH RECURSIVE dates(d) AS (
    SELECT MIN(DATE(order_purchase_timestamp)) FROM olist_orders_dataset
    UNION ALL
    SELECT DATE(d, '+1 day') FROM dates
    WHERE d < (SELECT MAX(DATE(order_delivered_customer_date)) FROM olist_orders_dataset)
)
SELECT
    d                                                   AS date,
    CAST(strftime('%Y', d) AS INTEGER)                  AS year,
    CAST(strftime('%m', d) AS INTEGER)                  AS month_no,
    CASE CAST(strftime('%m', d) AS INTEGER)
        WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'   WHEN 5 THEN 'May'       WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'    WHEN 8 THEN 'August'     WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END                                                 AS month_name,
    strftime('%Y-%m', d)                                AS year_month,
    CAST(strftime('%d', d) AS INTEGER)                  AS day,
    CASE CAST(strftime('%w', d) AS INTEGER)
        WHEN 0 THEN 'Sunday' WHEN 1 THEN 'Monday' WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday' WHEN 4 THEN 'Thursday' WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END                                                 AS weekday,
    CAST(strftime('%j', d) AS INTEGER)                  AS day_of_year,
    CAST(strftime('%W', d) AS INTEGER)                  AS week_no,
    CASE WHEN CAST(strftime('%w', d) AS INTEGER) IN (0, 6) THEN 0 ELSE 1 END AS is_weekday,
    strftime('%Q', d)                                   AS quarter
FROM dates;


-- 6. v_CalcDeliveryKPIs: Delivery performance metrics
DROP VIEW IF EXISTS v_CalcDeliveryKPIs;
CREATE VIEW v_CalcDeliveryKPIs AS
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp) AS delivery_days,
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
        WHEN order_delivered_customer_date >  order_estimated_delivery_date THEN 0
        ELSE NULL
    END AS delivered_on_time
FROM olist_orders_dataset
WHERE order_status = 'delivered';
