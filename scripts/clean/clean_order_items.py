from pathlib import Path

import pandas as pd
from tabulate import tabulate

from logs.logger import setup_logger

logger = setup_logger("clean_order_items.py")

BASE_DIR = Path(__file__).resolve().parent.parent.parent
OUTPUT_DIR = BASE_DIR / "data/clean_json_files"

file_name = "olist_order_items_dataset.json"
file_path = BASE_DIR / ("data/json_files/" + file_name)


def clean_order_items():
    df = pd.read_json(file_path, lines=True)

    if df.empty:
        logger.error(f"Нет данных в {file_name}")
        raise ValueError("Данные не найдены")

    try:
        df = df.drop_duplicates()
        df = df.dropna(subset=["order_id", "order_item_id", "product_id", "seller_id"])

        cols_to_time = ["shipping_limit_date"]
        for col in cols_to_time:
            df[col] = pd.to_datetime(df[col], utc=True)

        print(df.dtypes)
        print(tabulate(df.head(4), headers="keys", tablefmt="psql"))
    except Exception as e:
        logger.error(f"Ошибка обработки в {file_name}: {e}")
        raise

    try:
        output_file = OUTPUT_DIR / "order_items.json"
        df.to_json(output_file, orient="records", lines=True, date_format="iso")
    except Exception as e:
        logger.error(f"Ошибка записи очищенного {file_name}: {e}")
        raise

    logger.info("clean_order_items успешно отработал")
