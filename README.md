# E-commerce Platform — Musical Instruments

Database design and data analysis for an e-commerce platform specializing in musical instruments.

## Purpose

Build a complete relational database model for an online musical instrument store, populate it with realistic e-commerce data, and enable analytical queries on sales, inventory, customers, and suppliers.

## Schema

```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDER : places
    CUSTOMERS {
        int CustID PK
        string CustName
        string Fname
        string Lname
        string Street
        string City
        string Zipcode
        string Country
        string Phone
        string Email
        date RegistrationDate
        date BirthDate
        string Membership
    }

    ORDER ||--|{ "ORDER DETAILS" : contains
    ORDER {
        int OrderID PK
        int CustomerID FK
        float Amount
        date OrderDate
    }

    "ORDER DETAILS" ||--|| PRODUCTS : includes
    "ORDER DETAILS" {
        int OrderID FK
        int ProductsID FK
        float UnitPrice
        int Quantity
        float Subtotal
        string SKU
        float Discount
        float TaxRate
        float TaxAmount
        string ProductDescription
    }

    PRODUCTS ||--o{ "ORDER DETAILS" : referenced_in
    PRODUCTS {
        string SKU PK
        string ProductName
        string ProductCategory
        float UnitPrice
    }

    WAREHOUSES ||--o{ PRODUCTS : stocks
    WAREHOUSES {
        int WID PK
        string WLocation
        string WName
        string WPhone
        string Shelf_ID
        int Shelf_Current_occupancy
        int Shelf_total_capacity
    }

    SUPPLIER ||--o{ PRODUCTS : supplies
    SUPPLIER {
        int SupplierID PK
        string SName
        string SAddress
        float Rating
        string Category
    }

    DELIVERY ||--o{ ORDER : fulfills
    DELIVERY {
        int DeliveryNumber PK
        string DeliveryCompanyName
        string DeliveryCompanyID
    }

    CUSTOMERS ||--o{ SCORING : evaluated
    SCORING {
        int ScoreID PK
        int CustomerID FK
        int Score
    }
```

**Entities:** Customers, Orders, Order Details, Products, Payment (Coupon, Debit Card, Credit Card), Delivery, Warehouses (with shelf management), Suppliers, Stores, Transactions, Categories, Ads, Scoring.

## Tools Used

- **SQLite** — relational database engine
- **draw.io / diagrams.net** — ER diagram
- **Python** (pandas, numpy, matplotlib, seaborn, plotly) — data processing and analysis
- **Jupyter** — interactive exploration

## Results

- Normalized database schema with 12+ entities and defined relationships (PK/FK)
- SQLite database (`e-commerce_final code.db`) populated with order, customer, product, and seller data
- Product attribute catalog (`Product attributes copy.xlsx`)
- Full ER diagram in `e Commerce DB.drawio` (open with [draw.io](https://app.diagrams.net))

## Setup

```bash
pip install -r requirements.txt
```
