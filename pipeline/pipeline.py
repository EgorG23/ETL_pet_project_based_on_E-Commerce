from logs.logger import setup_logger
from scripts.load import load

logger = setup_logger("pipeline.py")


def pipeline():
    extract()
    transform()
    load()


pipeline()
logger.info("ETL закончил работу")
