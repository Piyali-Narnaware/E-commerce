# E-commerce Data Analysis

Exploratory analysis of the Brazilian e-commerce public dataset by Olist.

## Dataset

This project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). It contains information on 100k orders placed at Olist across multiple marketplaces in Brazil from 2016 to 2018.

Key tables:
- **olist_orders_dataset** – order details, timestamps, delivery status
- **olist_customers_dataset** – customer info and geolocation
- **olist_order_items_dataset** – items per order, prices, freight
- **olist_order_payments_dataset** – payment method and installments
- **olist_order_reviews_dataset** – review scores and comments
- **olist_products_dataset** – product attributes and category
- **olist_sellers_dataset** – seller info
- **olist_geolocation_dataset** – zip code geolocation data
- **product_category_name_translation** – English category translations

## Requirements

- Python 3.9+
- See `requirements.txt` for dependencies

## Setup

```bash
pip install -r requirements.txt
```

## Database

The analysis uses a SQLite database (`e-commerce_final_code.db`) built from the CSV files. The entity-relationship diagram is available in `e Commerce DB.drawio`.
