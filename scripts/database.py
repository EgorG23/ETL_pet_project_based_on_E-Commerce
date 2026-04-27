import os

from dotenv import load_dotenv
from sqlalchemy import create_engine

from logs.logger import setup_logger

logger = setup_logger("database.py")


load_dotenv()

engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
