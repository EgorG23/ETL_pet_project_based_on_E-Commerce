#  "LOOKER THERE. LOOKER IN MY HAND!"

---

##  Описание

Проект реализует ETL-пайплайн для загрузки, обработки и хранения данных в PostgreSQL.

---

## Перед использованием

1. Скачать данные: https://www.kaggle.com/datasets/jayeshsalunke101/brazilian-ecommerce-public-dataset
2. Заполнить CSV-файлами папку data/datasets
3. Установить зависимости requirements.txt
```bash
pip install -r requirements.txt
```
4. Создать БД в PostgreSQL (таблицы создутся сами!)
5. Настроить соединение с БД: создать в корневой папке проекта файл .env и указать переменные DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

---

##  Архитектура

- Extract: чтение JSON-файлов
- Transform: очистка и нормализация данных
- Load: загрузка в PostgreSQL через COPY

---

## Особенности

- имитация получения json-данных из стороннего источника (их генерация из CSV)
- логирование всех ETL этапов
- SQL-based трансформации
- Analytics-скрипты, которые можно использовать в дальнейшем при анализе

---

##  Структура данных

### Temps-таблицы (временные таблицы)
- customers_temp
- orders_temp
- products_temp
- geolocations_temp
- sellers_temp
- order_items_temp
- order_payments_temp
- order_reviews_temp

### Основные таблицы
- customers
- orders
- order_items
- products
- sellers
- payments
- geolocations

### Таблицы-справочники
- states
- cities
- payment_types
- order_statuses
- product_categories

---

## SQL-скрипты

- создание таблиц (проверка на наличие)
- заполнение промежуточных таблицы
- построение справочников и нормализованных таблиц по промежуточным
- удаление записей в промежуточных
- сохранение истории изменений в объемах таблиц

---

## Технологический стек

- Python 3.12
- PostgreSQL
- SQLAlchemy
- psycopg2
- Pandas
 

---

## Запуск

```bash
python pipeline/pipeline.py
```

---

## Удачного использования и спасибо за внимание к моему проекту!
