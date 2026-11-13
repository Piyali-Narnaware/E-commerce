"""Run SQL view smoke tests against the repository database (stdlib only)."""
import sqlite3
from pathlib import Path

root = Path(__file__).resolve().parent
db = root / "e-commerce_final code.db"
sql = (root / "powerbi_queries.sql").read_text(encoding="utf-8")
conn = sqlite3.connect(":memory:")
source = sqlite3.connect(str(db))
tables = source.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
print("Repository database tables:", [x[0] for x in tables])
required = {"olist_orders_dataset", "olist_order_items_dataset", "olist_order_payments_dataset",
            "olist_order_reviews_dataset", "olist_customers_dataset", "olist_products_dataset",
            "olist_sellers_dataset", "product_category_name_translation"}
available = {x[0] for x in tables}
if not required.issubset(available):
    print("The committed SQLite database is not the complete Olist reporting database.")
    print("Missing:", sorted(required - available))
    print("Use the full source CSV files to construct a complete SQLite database before testing views.")
    raise SystemExit(2)
source.backup(conn)
source.close()
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
