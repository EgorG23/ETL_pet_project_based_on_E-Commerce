from pathlib import Path

from logs.logger import setup_logger
from scripts.database import engine

logger = setup_logger("sql.py")


def run_sql_file(path):
    with open(path, "r") as f:
        sql = f.read()

    with engine.begin() as conn:
        conn.exec_driver_sql(sql)


def run_sql_create_scripts():
    BASE_DIR = Path(__file__).resolve().parent.parent
    create_script_path = BASE_DIR / "sql/tables/create_tables.sql"
    run_sql_file(create_script_path)

    logger.info("Таблицы успешно созданы (проверены на существование)")


def run_sql_update_tables_scripts():
    BASE_DIR = Path(__file__).resolve().parent.parent
    update_script_path = BASE_DIR / "sql/transform/update_tables.sql"
    run_sql_file(update_script_path)

    logger.info("Данные в таблицах приведены к корректному виду")


def run_sql_update_ref_scripts():
    BASE_DIR = Path(__file__).resolve().parent.parent
    update_script_path = BASE_DIR / "sql/transform/update_references.sql"
    run_sql_file(update_script_path)

    logger.info("Таблицы-справочники обновлены")


def truncate_temps():
    BASE_DIR = Path(__file__).resolve().parent.parent
    update_script_path = BASE_DIR / "sql/tables/truncate_temps.sql"
    run_sql_file(update_script_path)

    logger.info("Промежуточные таблицы полностью очищены (пусты)")


def load_dwh():
    with engine.begin():
        run_sql_update_ref_scripts()
        run_sql_update_tables_scripts()
        truncate_temps()
