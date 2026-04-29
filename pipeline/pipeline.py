from logs.logger import setup_logger
from scripts.extract import extract
from scripts.load import load
from scripts.transform import transform

logger = setup_logger("pipeline.py")


def pipeline():
    extract()
    transform()
    load()


pipeline()
logger.info("ETL закончил работу")
