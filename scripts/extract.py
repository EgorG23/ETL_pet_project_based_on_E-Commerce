from datetime import UTC, datetime
from pathlib import Path

import pandas as pd

from logs.logger import setup_logger

logger = setup_logger("extract.py")

BASE_DIR = Path(__file__).resolve().parent.parent
INPUT_DIR = BASE_DIR / "data/datasets"
OUTPUT_DIR = BASE_DIR / "data/json_files"


def extract():
    for file in INPUT_DIR.glob("*.csv"):
        try:
            df = pd.read_csv(file)
        except Exception as e:
            logger.error(f"Ошибка чтения {file.stem}: {e}")
            raise

        if df.empty:
            logger.error(f"Нет данных в {file.stem}")
            raise ValueError("Данные не найдены")

        try:
            df["ingestion_time"] = datetime.now(UTC).isoformat()
            print(df.columns)
        except Exception as e:
            logger.error(f"Ошибка обработки в {file.stem}: {e}")
            raise

        try:
            output_file = OUTPUT_DIR / f"{file.stem}.json"
            df.to_json(output_file, orient="records", lines=True, date_format="iso")
        except Exception as e:
            logger.error(f"Ошибка записи {file.stem} в JSON-формат: {e}")
            raise

        logger.info(f"Данные успешно получены из {file.stem}")
