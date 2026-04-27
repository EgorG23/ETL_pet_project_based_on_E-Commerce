import unicodedata
from pathlib import Path

import pandas as pd
from tabulate import tabulate

from logs.logger import setup_logger

logger = setup_logger("clean_sellers.py")

BASE_DIR = Path(__file__).resolve().parent.parent.parent
OUTPUT_DIR = BASE_DIR / "data/clean_json_files"


file_name = "olist_sellers_dataset.json"
file_path = BASE_DIR / ("data/json_files/" + file_name)


def clean_sellers():
    df = pd.read_json(file_path, lines=True)

    if df.empty:
        logger.error(f"Нет данных в {file_name}")
        raise ValueError("Данные не найдены")

    try:
        df = df.drop_duplicates()
        df = df.dropna(subset=["seller_id", "seller_zip_code_prefix"])
        df = df.rename(columns={"seller_state": "state"})
        df = df.rename(columns={"seller_city": "city"})

        cols = ["state", "city"]

        for col in cols:
            df[col] = df[col].str.lower().str.strip()
            df[col] = df[col].apply(remove_diacritics)

        print(df.dtypes)
        print(tabulate(df.head(4), headers="keys", tablefmt="psql"))
    except Exception as e:
        logger.error(f"Ошибка обработки в {file_name}: {e}")
        raise

    try:
        output_file = OUTPUT_DIR / "sellers.json"
        df.to_json(output_file, orient="records", lines=True, date_format="iso")
    except Exception as e:
        logger.error(f"Ошибка записи очищенного {file_name}: {e}")
        raise

    logger.info("clean_customers успешно отработал")


def remove_diacritics(text):
    if pd.isna(text):
        return text

    return "".join(c for c in unicodedata.normalize("NFKD", str(text)) if not unicodedata.combining(c))
