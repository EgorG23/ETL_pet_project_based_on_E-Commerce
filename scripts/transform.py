from pathlib import Path

import pandas as pd

from logs.logger import setup_logger
from scripts.clean.clean_category_name_translation import clean_category_name_translation
from scripts.clean.clean_customers import clean_customers
from scripts.clean.clean_geolocation import clean_geolocation
from scripts.clean.clean_order_items import clean_order_items
from scripts.clean.clean_order_payments import clean_payments
from scripts.clean.clean_order_reviews import clean_order_reviews
from scripts.clean.clean_orders import clean_orders
from scripts.clean.clean_products import clean_products
from scripts.clean.clean_sellers import clean_sellers

BASE_DIR = Path(__file__).resolve().parent.parent
DIR = BASE_DIR / "data/json_files"
OUTPUT_DIR = BASE_DIR / "data/clean_json_files"

logger = setup_logger("transform.py")


def transform():
    for file in DIR.glob("*.json"):
        df = pd.read_json(file, lines=True)
        if df.empty:
            logger.error(f"Нет данных в {file.stem}")
            raise ValueError("Данные не найдены")
        try:
            df = df.drop_duplicates()
        except Exception as e:
            logger.error(f"Ошибка обработки в {file.stem}: {e}")
            raise
        try:
            output_file = DIR / f"{file.stem}.json"
            df.to_json(output_file, orient="records", lines=True, date_format="iso")
        except Exception as e:
            logger.error(f"Ошибка записи очищенного {file.stem}: {e}")
            raise
    try:
        clean()
    except Exception as e:
        logger.error(f"Ошибка обработки при очистке данных: {e}")
        raise

    logger.info("Данные успешно обработаны и отправлены на загрузку в базу данных")


def clean():
    clean_payments()
    clean_geolocation()
    clean_category_name_translation()
    clean_products()
    clean_orders()
    clean_customers()
    clean_sellers()
    clean_order_items()
    clean_order_reviews()
