CREATE TABLE IF NOT EXISTS payment_types (
    payment_type_id SERIAL PRIMARY KEY,
    payment_type TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS cities (
    city_id SERIAL PRIMARY KEY,
    city_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS states (
    state_id SERIAL PRIMARY KEY,
    state_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS order_statuses (
    order_status_id SERIAL PRIMARY KEY,
    order_status TEXT NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS product_categories_temp (
    product_category_name TEXT,
    product_category_name_english TEXT,
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS product_categories (
    product_category_id SERIAL PRIMARY KEY,
    product_category_name TEXT NOT NULL UNIQUE,
    product_category_name_english TEXT,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL
);


CREATE TABLE IF NOT EXISTS order_payments_temp (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC(10, 2),
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS order_payments (
    payment_id SERIAL PRIMARY KEY,
    order_id TEXT NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type_id INT NOT NULL,
    payment_installments INT,
    payment_value NUMERIC(10, 2),
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_payments_type
        FOREIGN KEY (payment_type_id)
        REFERENCES payment_types (payment_type_id)
        ON DELETE CASCADE,

    CONSTRAINT payments_u
        UNIQUE (order_id, payment_sequential)
);


CREATE TABLE IF NOT EXISTS geolocations_temp (
    zip_code_prefix INT,
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    city TEXT,
    state TEXT,
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS geolocations (
    geolocation_id SERIAL PRIMARY KEY,
    zip_code_prefix INT,
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    city_id INT,
    state_id INT,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_geo_city
        FOREIGN KEY (city_id)
        REFERENCES cities (city_id),

    CONSTRAINT fk_geo_state
        FOREIGN KEY (state_id)
        REFERENCES states (state_id),

    CONSTRAINT geolocations_u
        UNIQUE (zip_code_prefix, city_id, state_id)
);


CREATE TABLE IF NOT EXISTS products_temp (
    product_id TEXT,
    product_category_name TEXT,
    product_name_length FLOAT,
    product_description_length FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS products (
    product_id TEXT PRIMARY KEY,
    product_category_id INT,
    product_name_length FLOAT,
    product_description_length FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_products_category
        FOREIGN KEY (product_category_id)
        REFERENCES product_categories (product_category_id)
);


CREATE TABLE IF NOT EXISTS customers_temp (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INT,
    city TEXT,
    state TEXT,
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id TEXT NOT NULL PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    customer_zip_code_prefix INT NOT NULL,
    city_id INT,
    state_id INT,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_customers_city
        FOREIGN KEY (city_id)
        REFERENCES cities (city_id),

    CONSTRAINT fk_customers_state
        FOREIGN KEY (state_id)
        REFERENCES states (state_id)
);


CREATE TABLE IF NOT EXISTS orders_temp (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP WITH TIME ZONE,
    order_approved_at TIMESTAMP WITH TIME ZONE,
    order_delivered_carrier_date TIMESTAMP WITH TIME ZONE,
    order_delivered_customer_date TIMESTAMP WITH TIME ZONE,
    order_estimated_delivery_date TIMESTAMP WITH TIME ZONE,
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS orders (
    order_id TEXT NOT NULL PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_status_id INT NOT NULL,
    order_purchase_timestamp TIMESTAMP WITH TIME ZONE,
    order_approved_at TIMESTAMP WITH TIME ZONE,
    order_delivered_carrier_date TIMESTAMP WITH TIME ZONE,
    order_delivered_customer_date TIMESTAMP WITH TIME ZONE,
    order_estimated_delivery_date TIMESTAMP WITH TIME ZONE,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),

    CONSTRAINT fk_orders_status
        FOREIGN KEY (order_status_id)
        REFERENCES order_statuses (order_status_id)
);


CREATE TABLE IF NOT EXISTS sellers_temp (
    seller_id TEXT,
    seller_zip_code_prefix INT,
    city TEXT,
    state TEXT,
    ingestion_time TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS sellers (
    seller_id TEXT NOT NULL PRIMARY KEY,
    seller_zip_code_prefix INT NOT NULL,
    city_id INT,
    state_id INT,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_sellers_city
        FOREIGN KEY (city_id)
        REFERENCES cities (city_id),

    CONSTRAINT fk_sellers_state
        FOREIGN KEY (state_id)
        REFERENCES states (state_id)
);


CREATE TABLE IF NOT EXISTS order_items (
    order_id TEXT NOT NULL,
    order_item_id INT NOT NULL,
    product_id TEXT NOT NULL,
    seller_id TEXT NOT NULL,
    shipping_limit_date TIMESTAMP WITH TIME ZONE,
    price FLOAT,
    freight_value FLOAT,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    PRIMARY KEY(order_id, order_item_id),

    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),

    CONSTRAINT fk_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers (seller_id)
);


CREATE TABLE IF NOT EXISTS order_items_temp (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP WITH TIME ZONE,
    price FLOAT,
    freight_value FLOAT,
    ingestion_time TIMESTAMP WITH TIME ZONE
);


CREATE TABLE IF NOT EXISTS order_reviews (
    review_id TEXT NOT NULL PRIMARY KEY,
    order_id TEXT NOT NULL,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP WITH TIME ZONE,
    review_answer_timestamp TIMESTAMP WITH TIME ZONE,
    ingestion_time TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);


CREATE TABLE IF NOT EXISTS order_reviews_temp (
    review_id TEXT,
    order_id TEXT,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP WITH TIME ZONE,
    review_answer_timestamp TIMESTAMP WITH TIME ZONE,
    ingestion_time TIMESTAMP WITH TIME ZONE
);


CREATE TABLE IF NOT EXISTS etl_logs (
    table_name TEXT,
    rows_before INT,
    rows_after INT,
    diff INT,
    loaded_at TIMESTAMP DEFAULT NOW()
);