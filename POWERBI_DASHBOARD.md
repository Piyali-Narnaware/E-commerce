# Power BI Dashboard Guide

## Overview

This guide walks you through building a Power BI dashboard for the musical-instrument e-commerce platform using the SQLite database and CSV files in this repository.

---

## 1. Data Import

### Option A — Connect to SQLite DB (Recommended)

1. Open **Power BI Desktop**
2. **Get Data** → **ODBC** or **Other** → **SQLite** (or install the [SQLite ODBC driver](http://www.ch-werner.de/sqliteodbc/))
3. Select `e-commerce_final code.db`
4. Import the tables:
   - `olist_orders_dataset`
   - `olist_order_items_dataset`
   - `olist_order_payments_dataset`
   - `olist_order_reviews_dataset`
   - `olist_customers_dataset`
   - `olist_products_dataset`
   - `olist_sellers_dataset`
   - `product_category_name_translation`

### Option B — Import CSVs Directly

**Get Data** → **Text/CSV** and select each `.csv` file.

### Option C — Use Prepared SQL Views

Run `powerbi_queries.sql` against the SQLite DB first, then import:
- `v_FactOrders`
- `v_DimCustomer`
- `v_DimProduct`
- `v_DimSeller`
- `v_DimCalendar`
- `v_CalcDeliveryKPIs`

---

## 2. Data Model (Star Schema)

Build this relationship model in the **Model** view:

```
DimCalendar ───── FactOrders (order_date)
DimCustomer ───── FactOrders (customer_id)
DimProduct  ───── FactOrders (product_id)
DimSeller   ───── FactOrders (seller_id)
```

| Table | Join to | Column |
|---|---|---|
| `v_DimCalendar` | `v_FactOrders` | `date` → `order_date` |
| `v_DimCustomer` | `v_FactOrders` | `customer_id` |
| `v_DimProduct` | `v_FactOrders` | `product_id` |
| `v_DimSeller` | `v_FactOrders` | `seller_id` |

---

## 3. DAX Measures

Create these **measures** in the `v_FactOrders` table:

```dax
-- Revenue
Total Revenue = SUM(v_FactOrders[total_order_value])

-- Orders Count
Total Orders = DISTINCTCOUNT(v_FactOrders[order_id])

-- Average Order Value (AOV)
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])

-- Freight Cost
Total Freight = SUM(v_FactOrders[freight_value])

-- Freight % of Revenue
Freight % of Revenue = DIVIDE([Total Freight], [Total Revenue])

-- Customers
Total Customers = DISTINCTCOUNT(v_FactOrders[customer_id])

-- Products Sold
Products Sold = SUM(v_FactOrders[price])

-- Units Sold
Units Sold = COUNTROWS(v_FactOrders)

-- Review Score Avg
Avg Review Score = AVERAGE(v_FactOrders[review_score])

-- On-Time Delivery Rate (requires v_CalcDeliveryKPIs joined)
On-Time Delivery % = DIVIDE(
    COUNTROWS(FILTER(v_FactOrders, v_FactOrders[delivered_on_time] = 1)),
    COUNTROWS(FILTER(v_FactOrders, v_FactOrders[delivered_on_time] <> BLANK()))
)

-- Monthly Revenue (time-intelligence)
Revenue MTD = TOTALMTD([Total Revenue], v_DimCalendar[date])
Revenue QTD = TOTALQTD([Total Revenue], v_DimCalendar[date])
Revenue YTD = TOTALYTD([Total Revenue], v_DimCalendar[date])

-- Revenue vs Previous Period
Revenue Prev Month = CALCULATE([Total Revenue], PREVIOUSMONTH(v_DimCalendar[date]))
Revenue MoM % = DIVIDE([Total Revenue] - [Revenue Prev Month], [Revenue Prev Month])

-- Payment method breakdown
Credit Card Revenue = CALCULATE([Total Revenue], v_FactOrders[payment_type] = "credit_card")
Boleto Revenue     = CALCULATE([Total Revenue], v_FactOrders[payment_type] = "boleto")
Debit Card Revenue = CALCULATE([Total Revenue], v_FactOrders[payment_type] = "debit_card")
Voucher Revenue    = CALCULATE([Total Revenue], v_FactOrders[payment_type] = "voucher")

-- Delivery performance
Avg Delivery Days = AVERAGE(v_CalcDeliveryKPIs[delivery_days])
```

---

## 4. Suggested Dashboard Layout

### Page 1 — Executive Summary

| Visual | Data |
|---|---|
| **KPI Cards** (top row) | Total Revenue, Total Orders, Avg Order Value, Avg Review Score, On-Time Delivery % |
| **Line Chart** | Revenue & Orders over time (year-month on X-axis, dual axis) |
| **Treemap** | Revenue by Product Category |
| **Map** | Orders by Customer State |
| **Table** | Top 10 Products by Revenue |

### Page 2 — Sales & Products

| Visual | Data |
|---|---|
| **Bar Chart** | Revenue by Product Category |
| **Scatter Plot** | Product Weight vs. Freight Cost (colored by category) |
| **Matrix** | Product Category × Month with Revenue |
| **Gauge** | Revenue vs Target (can set a goal) |
| **Slicers** | Year, Quarter, Product Category |

### Page 3 — Customers & Reviews

| Visual | Data |
|---|---|
| **KPI Cards** | Total Customers, Avg Review Score, repeat customers |
| **Bar Chart** | Review Score Distribution (1-5) |
| **Stacked Bar** | Orders by Customer State |
| **Donut** | Payment Type breakdown |
| **Table** | Customers by City with Order Count & Revenue |

### Page 4 — Delivery & Operations

| Visual | Data |
|---|---|
| **KPI Cards** | Avg Delivery Days, On-Time %, Late Orders |
| **Line Chart** | Delivery Days over time |
| **Histogram** | Distribution of Delivery Days (bucketed) |
| **Bar Chart** | Avg Freight by Seller State |
| **Slicers** | Year, Month, Seller State |

---

## 5. Filters & Slicers (Global)

Add these to a **slicer pane** or top banner across all pages:

- Year / Quarter (from `v_DimCalendar`)
- Product Category (from `v_DimProduct`)
- Customer State (from `v_DimCustomer`)
- Payment Type (from `v_FactOrders`)
- Order Status (from `v_FactOrders`)

---

## 6. Color Palette (Recommended)

Use a consistent musical-instrument theme:

- Primary: `#1E3A5F` (deep blue)
- Secondary: `#F5A623` (amber/gold)
- Accent: `#7ED321` (green for positive metrics)
- Alert: `#D0021B` (red for issues)
- Background: `#F8F9FA` (light grey)

---

## 7. Publishing

1. **File** → **Publish** → **Publish to Power BI Service**
2. Select a workspace
3. Set up scheduled refresh using the **On-premises data gateway** (SQLite ODBC driver must be installed on the gateway machine)
