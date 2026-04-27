from pathlib import Path

import pandas as pd

from logs.logger import setup_logger
from scripts.database import engine
from scripts.sql import load_dwh, run_sql_create_scripts

logger = setup_logger("load.py")

BASE_DIR = Path(__file__).resolve().parent.parent
INPUT_DIR = BASE_DIR / "data/clean_json_files"
CSV_DIR = BASE_DIR / "data/csv"

TEMP_TABLES = {
    "customers": (
        "customers_temp",
        ["customer_id", "customer_unique_id", "customer_zip_code_prefix", "city", "state", "ingestion_time"],
    ),
    "orders": (
        "orders_temp",
        [
            "order_id",
            "customer_id",
            "order_status",
            "order_purchase_timestamp",
            "order_approved_at",
            "order_delivered_carrier_date",
            "order_delivered_customer_date",
            "order_estimated_delivery_date",
            "ingestion_time",
        ],
    ),
    "products": (
        "products_temp",
        [
            "product_id",
            "product_category_name",
            "product_name_length",
            "product_description_length",
            "product_photos_qty",
            "product_weight_g",
            "product_length_cm",
            "product_height_cm",
            "product_width_cm",
            "ingestion_time",
        ],
    ),
    "geolocations": (
        "geolocations_temp",
        ["zip_code_prefix", "geolocation_lat", "geolocation_lng", "city", "state", "ingestion_time"],
    ),
    "sellers": ("sellers_temp", ["seller_id", "seller_zip_code_prefix", "city", "state", "ingestion_time"]),
    "order_payments": (
        "order_payments_temp",
        ["order_id", "payment_sequential", "payment_type", "payment_installments", "payment_value", "ingestion_time"],
    ),
    "order_items": (
        "order_items_temp",
        [
            "order_id",
            "order_item_id",
            "product_id",
            "seller_id",
            "shipping_limit_date",
            "price",
            "freight_value",
            "ingestion_time",
        ],
    ),
    "order_reviews": (
        "order_reviews_temp",
        [
            "review_id",
            "order_id",
            "review_score",
            "review_comment_title",
            "review_comment_message",
            "review_creation_date",
            "review_answer_timestamp",
            "ingestion_time",
        ],
    ),
    "product_categories": (
        "product_categories_temp",
        ["product_category_name", "product_category_name_english", "ingestion_time"],
    ),
}
COLS = [
    "orders",
    "customers",
    "sellers",
    "order_items",
    "order_payments",
    "order_reviews",
    "geolocations",
    "product_categories",
    "states",
    "cities",
    "payment_types",
    "order_statuses"
]


def load():
    logger.info("Загрузка данных в БД началась")

    with engine.begin() as conn:
        run_sql_create_scripts()
        load_temp_tables()

        before = get_count(conn, COLS)

        load_dwh()

        after = get_count(conn, COLS)

        for t in COLS:
            conn.exec_driver_sql(
                """
                INSERT INTO etl_logs(table_name, rows_before, rows_after, diff)
                VALUES (%s, %s, %s, %s)
                """,
                (t, before[t], after[t], after[t] - before[t]),
            )

    logger.info("Загрузка данных в БД завершилась с успехом")


def load_temp_tables():
    with engine.begin() as conn:
        for file in INPUT_DIR.glob("*.json"):
            df = pd.read_json(file, lines=True)

            if df.empty:
                logger.warning(f"{file.stem} is empty")
                continue

            csv_path = CSV_DIR / f"{file.stem}.csv"
            df.to_csv(csv_path, index=False)

            if file.stem in TEMP_TABLES:
                table, cols = TEMP_TABLES[file.stem]
                copy_csv(conn, csv_path, table, cols)
                logger.info(f"{file.stem} загружено в таблицу {table}")


def copy_csv(conn, path, table, columns):
    cols_str = ", ".join(columns)
    sql = f"COPY {table} ({cols_str}) FROM STDIN WITH CSV HEADER"

    with conn.connection.cursor() as cur:
        with open(path, "r", encoding="utf-8") as f:
            cur.copy_expert(sql, f)


def get_count(conn, tables):
    return {t: conn.exec_driver_sql(f"SELECT COUNT(*) FROM {t}").scalar() for t in tables}
