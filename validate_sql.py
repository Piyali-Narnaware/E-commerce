"""Run SQL view smoke tests against the repository database (stdlib only)."""
import sqlite3
from pathlib import Path

root = Path(__file__).resolve().parent
db = root / "e-commerce_final code.db"
sql = (root / "powerbi_queries.sql").read_text(encoding="utf-8")
conn = sqlite3.connect(":memory:")
import csv
required = [
    "olist_orders_dataset", "olist_order_items_dataset", "olist_order_payments_dataset",
    "olist_order_reviews_dataset", "olist_customers_dataset", "olist_products_dataset",
    "olist_sellers_dataset", "product_category_name_translation"
]
# The committed .db is a separate schema. Load Olist CSVs into a temporary
# in-memory SQLite database without altering the existing database file.
for table in required:
    csv_path = root / (table + ".csv")
    if not csv_path.exists():
        raise SystemExit(f"Missing source CSV: {csv_path.name}")
    with csv_path.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.reader(f)
        columns = next(reader)
        quoted = [chr(34) + col.replace(chr(34), chr(34) * 2) + chr(34) for col in columns]
        conn.execute(f'CREATE TABLE "{table}" (' + ", ".join(c + " TEXT" for c in quoted) + ")")
        placeholders = ", ".join("?" for _ in columns)
        insert = f'INSERT INTO "{table}" VALUES ({placeholders})'
        batch = []
        count = 0
        for row in reader:
            batch.append([value if value != "" else None for value in row])
            if len(batch) >= 5000:
                conn.executemany(insert, batch)
                count += len(batch)
                batch.clear()
        if batch:
            conn.executemany(insert, batch)
            count += len(batch)
        print(f"Loaded {table}: {count} rows")
conn.commit()
conn.executescript(sql)
checks = [
    ("Order summary one row per order",
     "SELECT COUNT(*) = COUNT(DISTINCT order_id) FROM v_FactOrderSummary"),
    ("Order item row count",
     "SELECT (SELECT COUNT(*) FROM v_FactOrders) = (SELECT COUNT(*) FROM olist_order_items_dataset)"),
    ("Product revenue",
     "SELECT ABS((SELECT SUM(price) FROM v_FactOrders) - (SELECT SUM(price) FROM olist_order_items_dataset)) < 0.01"),
    ("Payment value",
     "SELECT ABS((SELECT SUM(payment_total) FROM v_FactOrderSummary) - (SELECT SUM(payment_value) FROM olist_order_payments_dataset)) < 0.01"),
    ("Product dimension unique",
     "SELECT COUNT(*) = COUNT(DISTINCT product_id) FROM v_DimProduct"),
]
for label, query in checks:
    passed = conn.execute(query).fetchone()[0] == 1
    print(("PASS" if passed else "FAIL") + ": " + label)
    if not passed:
        raise SystemExit(1)
print("All view checks passed.")
