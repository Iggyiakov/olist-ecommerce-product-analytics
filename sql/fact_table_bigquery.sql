-- ===============================================
--  OLIST E-COMMERCE ANALYSIS (BRAZIL)
--  FINAL FACT TABLE FOR ANALYTICS
--  Author: Igor Iakovenko
-- ===============================================

WITH order_items AS (
    SELECT
        oi.order_id,
        oi.product_id,
        oi.price,
        oi.freight_value,
        (oi.price + oi.freight_value) AS total_item_value
    FROM `olist.order_items` oi
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM `olist.order_payments`
    GROUP BY order_id
),

orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATE_DIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date,
            DAY
        ) AS delay_days
    FROM `olist.orders` o
),

customers AS (
    SELECT
        customer_id,
        customer_city,
        customer_state
    FROM `olist.customers`
),

reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM `olist.order_reviews`
    GROUP BY order_id
),

final_fact AS (
    SELECT
        oi.order_id,
        o.customer_id,
        c.customer_city,
        c.customer_state,
        oi.price,
        oi.freight_value,
        oi.total_item_value,
        p.total_payment_value,
        r.avg_review_score,
        o.delay_days,
        o.order_purchase_timestamp AS purchase_ts,
        o.order_delivered_customer_date AS delivered_ts
    FROM order_items oi
    LEFT JOIN payments p USING(order_id)
    LEFT JOIN orders o USING(order_id)
    LEFT JOIN customers c USING(customer_id)
    LEFT JOIN reviews r USING(order_id)
)

SELECT * 
FROM final_fact;

