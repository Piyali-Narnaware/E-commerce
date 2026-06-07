# E-commerce Platform (Musical Instruments)

A database design and analysis project for an e-commerce platform specializing in musical instruments.

## Schema

The database design includes the following entities (see `e Commerce DB.drawio` for the ER diagram):

- **Customers** — CustID, CustName, Address, Phone, Email, Membership, Birthday
- **Orders** — OrderID, CustomerID, OrderDate, OrderStatus, RequireDate, ShippedDate, PayMethod, PayStatus
- **Order Details** — Products per order with pricing, quantity, discount, tax
- **Products** — SKU, ProductName, ProductCategory, UnitPrice
- **Payment** — Supports coupon, debit card, and credit card
- **Delivery** — Delivery number, company, and tracking
- **Warehouses** — WID, Location, Name, Phone, Shelf management
- **Suppliers** — SupplierID, Name, Address, Rating, Category/Department
- **Transactions**, **Categories**, **Ads**, **Scoring**, **Stores**

## Files

| File | Description |
|---|---|
| `e-commerce_final code.db` | SQLite database with the full schema and data |
| `e Commerce DB.drawio` | Entity-relationship diagram (open with [draw.io](https://app.diagrams.net)) |
| `Product attributes copy.xlsx` | Product attribute definitions |
| `*.csv` | Data exports for customers, orders, products, sellers, reviews, etc. |

## Requirements

- Python 3.9+
- See `requirements.txt` for dependencies

```bash
pip install -r requirements.txt
```
