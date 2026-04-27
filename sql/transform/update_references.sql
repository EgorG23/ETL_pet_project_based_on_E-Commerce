INSERT INTO cities (city_name)
SELECT DISTINCT city
FROM geolocations_temp
WHERE city IS NOT NULL
ON CONFLICT (city_name) DO NOTHING;


INSERT INTO states (state_name)
SELECT DISTINCT state
FROM geolocations_temp
WHERE state IS NOT NULL
ON CONFLICT (state_name) DO NOTHING;


INSERT INTO payment_types (payment_type)
SELECT DISTINCT payment_type
FROM order_payments_temp
WHERE payment_type IS NOT NULL
ON CONFLICT (payment_type) DO NOTHING;


INSERT INTO order_statuses (order_status)
SELECT DISTINCT order_status
FROM orders_temp
WHERE order_status IS NOT NULL
ON CONFLICT (order_status) DO NOTHING;


INSERT INTO product_categories (
    product_category_name,
    product_category_name_english,
    ingestion_time
)
SELECT
    product_category_name,
    product_category_name_english,
    NOW()
FROM (
    SELECT DISTINCT
        product_category_name,
        product_category_name_english
    FROM product_categories_temp
    WHERE product_category_name IS NOT NULL
) t
ON CONFLICT (product_category_name)
DO UPDATE SET
    product_category_name_english = EXCLUDED.product_category_name_english,
    ingestion_time = EXCLUDED.ingestion_time;