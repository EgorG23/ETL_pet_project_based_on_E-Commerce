INSERT INTO order_payments (
    order_id,
    payment_sequential,
    payment_type_id,
    payment_installments,
    payment_value,
    ingestion_time
)
SELECT DISTINCT ON (t.order_id, t.payment_sequential)
    t.order_id,
    t.payment_sequential,
    d.payment_type_id,
    t.payment_installments,
    t.payment_value,
    t.ingestion_time
FROM order_payments_temp t
JOIN payment_types d
    ON t.payment_type = d.payment_type
ON CONFLICT (order_id, payment_sequential) DO UPDATE SET
    payment_type_id = EXCLUDED.payment_type_id,
    payment_installments = EXCLUDED.payment_installments,
    payment_value = EXCLUDED.payment_value,
    ingestion_time = EXCLUDED.ingestion_time;


INSERT INTO geolocations (
    zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    city_id,
    state_id,
    ingestion_time
)
SELECT DISTINCT ON (g.zip_code_prefix, c.city_id, s.state_id)
    g.zip_code_prefix,
    g.geolocation_lat,
    g.geolocation_lng,
    c.city_id,
    s.state_id,
    g.ingestion_time
FROM geolocations_temp g
JOIN states s
    ON g.state = s.state_name
JOIN cities c
    ON g.city = c.city_name
ON CONFLICT (zip_code_prefix, city_id, state_id) DO UPDATE SET
    geolocation_lat = EXCLUDED.geolocation_lat,
    geolocation_lng = EXCLUDED.geolocation_lng,
    ingestion_time = EXCLUDED.ingestion_time;


INSERT INTO products (
    product_id,
    product_category_id,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    ingestion_time
)
SELECT DISTINCT ON (pt.product_id)
    pt.product_id,
    pc.product_category_id,
    pt.product_name_length,
    pt.product_description_length,
    pt.product_photos_qty,
    pt.product_weight_g,
    pt.product_length_cm,
    pt.product_height_cm,
    pt.product_width_cm,
    pt.ingestion_time
FROM products_temp pt
JOIN product_categories pc
    ON pt.product_category_name = pc.product_category_name
ON CONFLICT (product_id) DO UPDATE SET
    product_category_id = EXCLUDED.product_category_id,
    product_name_length = EXCLUDED.product_name_length,
    product_description_length = EXCLUDED.product_description_length,
    product_photos_qty = EXCLUDED.product_photos_qty,
    product_weight_g = EXCLUDED.product_weight_g,
    product_height_cm = EXCLUDED.product_height_cm,
    product_width_cm = EXCLUDED.product_width_cm,
    ingestion_time = EXCLUDED.ingestion_time;

INSERT INTO customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    city_id,
    state_id,
    ingestion_time
)
SELECT DISTINCT ON (ct.customer_id)
    ct.customer_id,
    ct.customer_unique_id,
    ct.customer_zip_code_prefix,
    c.city_id,
    s.state_id,
    ct.ingestion_time
FROM customers_temp ct
JOIN states s
    ON ct.state = s.state_name
JOIN cities c
    ON ct.city = c.city_name
ON CONFLICT (customer_id) DO UPDATE SET
    customer_unique_id = EXCLUDED.customer_unique_id,
    customer_zip_code_prefix = EXCLUDED.customer_zip_code_prefix,
    city_id = EXCLUDED.city_id,
    state_id = EXCLUDED.state_id,
    ingestion_time = EXCLUDED.ingestion_time;


INSERT INTO orders (
    order_id,
    customer_id,
    order_status_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    ingestion_time
)
SELECT DISTINCT ON (ot.order_id)
    ot.order_id,
    c.customer_id,
    os.order_status_id,
    ot.order_purchase_timestamp,
    ot.order_approved_at,
    ot.order_delivered_carrier_date,
    ot.order_delivered_customer_date,
    ot.order_estimated_delivery_date,
    ot.ingestion_time
FROM orders_temp ot
JOIN order_statuses os
    ON ot.order_status = os.order_status
JOIN customers c
    ON ot.customer_id = c.customer_id
ON CONFLICT (order_id) DO UPDATE SET
    customer_id = EXCLUDED.customer_id,
    order_status_id = EXCLUDED.order_status_id,
    order_purchase_timestamp = EXCLUDED.order_purchase_timestamp,
    order_approved_at = EXCLUDED.order_approved_at,
    order_delivered_carrier_date = EXCLUDED.order_delivered_carrier_date,
    order_delivered_customer_date = EXCLUDED.order_delivered_customer_date,
    order_estimated_delivery_date = EXCLUDED.order_estimated_delivery_date,
    ingestion_time = EXCLUDED.ingestion_time;


INSERT INTO sellers (
    seller_id,
    seller_zip_code_prefix,
    city_id,
    state_id,
    ingestion_time
)
SELECT DISTINCT ON (st.seller_id)
    st.seller_id,
    st.seller_zip_code_prefix,
    c.city_id,
    s.state_id,
    st.ingestion_time
FROM sellers_temp st
JOIN states s
    ON st.state = s.state_name
JOIN cities c
    ON st.city = c.city_name
ON CONFLICT (seller_id) DO UPDATE SET
    seller_zip_code_prefix = EXCLUDED.seller_zip_code_prefix,
    city_id = EXCLUDED.city_id,
    state_id = EXCLUDED.state_id,
    ingestion_time = EXCLUDED.ingestion_time;


INSERT INTO order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    ingestion_time)
SELECT DISTINCT ON (t.order_id, t.order_item_id)
    o.order_id,
    t.order_item_id,
    p.product_id,
    s.seller_id,
    t.shipping_limit_date,
    t.price,
    t.freight_value,
    t.ingestion_time
FROM order_items_temp t
JOIN orders o
  ON o.order_id = t.order_id
JOIN products p
  ON p.product_id = t.product_id
JOIN sellers s
  ON s.seller_id = t.seller_id
ON CONFLICT (order_id, order_item_id) DO UPDATE SET
    product_id = EXCLUDED.product_id,
    seller_id = EXCLUDED.seller_id,
    shipping_limit_date = EXCLUDED.shipping_limit_date,
    price = EXCLUDED.price,
    freight_value = EXCLUDED.freight_value,
    ingestion_time = EXCLUDED.ingestion_time;


INSERT INTO order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    ingestion_time
)
SELECT DISTINCT ON (t.review_id)
    t.review_id,
    o.order_id,
    t.review_score,
    t.review_comment_title,
    t.review_comment_message,
    t.review_creation_date,
    t.review_answer_timestamp,
    t.ingestion_time
FROM order_reviews_temp t
JOIN orders o
  ON o.order_id = t.order_id
ON CONFLICT (review_id) DO UPDATE SET
    order_id = EXCLUDED.order_id,
    review_score = EXCLUDED.review_score,
    review_comment_title = EXCLUDED.review_comment_title,
    review_comment_message = EXCLUDED.review_comment_message,
    review_creation_date = EXCLUDED.review_creation_date,
    review_answer_timestamp = EXCLUDED.review_answer_timestamp,
    ingestion_time = EXCLUDED.ingestion_time;
