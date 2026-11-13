# Power BI reporting guide

This is a design and implementation guide, not a claim that a Power BI dashboard has already been built. It uses the public Brazilian Olist e-commerce dataset, not a musical-instrument-only store.

## 1. Prepare the reporting views

Open the full Olist SQLite database (or import the nine Olist CSVs into a new SQLite database) and run `powerbi_queries.sql`. The repository's existing `e-commerce_final code.db` is small, so check that it contains all source rows before using it for a complete dashboard.

The script creates seven views:

| View | Grain | Purpose |
| --- | --- | --- |
| `v_FactOrders` | One order item | Product, seller, unit and item-level revenue analysis |
| `v_FactOrderSummary` | One order | Orders, customer spend, payments, reviews and delivery |
| `v_DimCustomer` | One order-specific customer ID | Customer location and unique-customer ID |
| `v_DimProduct` | One product | Product category and attributes |
| `v_DimSeller` | One seller | Seller location |
| `v_DimCalendar` | One date | Calendar filters |
| `v_CalcDeliveryKPIs` | One delivered order | Optional delivery detail; the order summary already includes delivery KPIs |

`v_FactOrders` contains item prices and freight, **not** repeated order payment values or review scores. `v_FactOrderSummary` aggregates those other sources before joining to orders. Never sum an order-level value after joining it to multiple order items.

## 2. Power BI relationships

Import the six main views, excluding `v_CalcDeliveryKPIs` unless needed for separate detail.

Create single-direction, one-to-many relationships from the dimension to the fact:

- `v_DimCalendar[date]` → `v_FactOrders[order_date]`
- `v_DimCalendar[date]` → `v_FactOrderSummary[order_date]`
- `v_DimCustomer[customer_id]` → `v_FactOrders[customer_id]`
- `v_DimCustomer[customer_id]` → `v_FactOrderSummary[customer_id]`
- `v_DimProduct[product_id]` → `v_FactOrders[product_id]`
- `v_DimSeller[seller_id]` → `v_FactOrders[seller_id]`

Set the calendar date field to **Date** and mark `v_DimCalendar` as a date table. Avoid connecting the two fact tables directly. With two fact tables sharing dimensions, test filter propagation and ambiguous relationship paths in the model before publishing.

The order-summary measures below respond to calendar and customer filters. Product and seller slicers do **not** automatically filter order-summary measures. If you need order-level measures by product/seller, use a distinct-order bridge or explicit DAX filter logic and validate totals.

## 3. Suggested DAX measures

Create these measures in Power BI. The SQL views use `DATE(...)` so `order_date` can relate to the calendar date.

```dax
-- Item-grain measures
Product Revenue = SUM(v_FactOrders[price])
Freight Revenue = SUM(v_FactOrders[freight_value])
Item Total Including Freight =
    SUM(v_FactOrders[item_total_including_freight])
Units Sold = COUNTROWS(v_FactOrders)
Orders With Items = DISTINCTCOUNT(v_FactOrders[order_id])

-- Order-grain measures
Total Orders = DISTINCTCOUNT(v_FactOrderSummary[order_id])
Order Product Revenue = SUM(v_FactOrderSummary[product_revenue])
Order Freight Revenue = SUM(v_FactOrderSummary[freight_revenue])
Order Value Including Freight =
    SUM(v_FactOrderSummary[order_total_including_freight])
Average Order Value =
    DIVIDE([Order Value Including Freight], [Total Orders])
Total Payment Value = SUM(v_FactOrderSummary[payment_total])
Unique Customers =
    CALCULATE(
        DISTINCTCOUNT(v_DimCustomer[customer_unique_id]),
        TREATAS(
            VALUES(v_FactOrderSummary[customer_id]),
            v_DimCustomer[customer_id]
        )
    )
Delivered Orders =
    CALCULATE([Total Orders], v_FactOrderSummary[order_status] = "delivered")
On-Time Deliveries =
    CALCULATE(
        COUNTROWS(v_FactOrderSummary),
        v_FactOrderSummary[delivered_on_time] = 1
    )
Delivery Records With Outcome =
    COUNTROWS(
        FILTER(v_FactOrderSummary,
            NOT ISBLANK(v_FactOrderSummary[delivered_on_time]))
    )
On-Time Delivery % =
    DIVIDE([On-Time Deliveries], [Delivery Records With Outcome])
Average Delivery Days =
    AVERAGE(v_FactOrderSummary[delivery_days])
Average Review Score =
    AVERAGE(v_FactOrderSummary[average_review_score])

-- Date intelligence; requires a properly related, marked date table
Revenue MTD =
    TOTALMTD([Order Value Including Freight], v_DimCalendar[date])
Revenue QTD =
    TOTALQTD([Order Value Including Freight], v_DimCalendar[date])
Revenue YTD =
    TOTALYTD([Order Value Including Freight], v_DimCalendar[date])
Revenue Previous Month =
    CALCULATE(
        [Order Value Including Freight],
        PREVIOUSMONTH(v_DimCalendar[date])
    )
Revenue MoM % =
    DIVIDE(
        [Order Value Including Freight] - [Revenue Previous Month],
        [Revenue Previous Month]
    )
```

**Definitions:** Item revenue is the sum of product prices. Order value including freight is product price plus freight. Payment value is tracked separately and should not be assumed equal to item totals. The average review score above is the unweighted mean of order-level average review scores. `Total Orders` includes all order statuses; filter to delivered orders for a delivered-sales view. For a product/seller-filtered AOV, build a separate item-based measure with an explicitly documented definition.

## 4. Proposed dashboard pages

1. **Sales overview:** order count, order value including freight, AOV, monthly trend and customer locations
2. **Products and sellers:** item-level product revenue, units, category and seller contribution
3. **Customers and reviews:** unique customer counts, order-level review scores and geographic distribution
4. **Delivery:** delivered orders, on-time percentage, average delivery days and late deliveries

Do not label these pages as built or published until they exist in a Power BI file.

## 5. Validate before using figures on your CV

Run the checks below against the full source dataset:

```sql
-- One row per order in the order summary
SELECT COUNT(*) AS rows, COUNT(DISTINCT order_id) AS orders
FROM v_FactOrderSummary;

-- One row per order item in the item fact
SELECT COUNT(*) AS item_rows FROM v_FactOrders;
SELECT COUNT(*) AS source_item_rows FROM olist_order_items_dataset;

-- Source versus reporting revenue, without order/payment duplication
SELECT SUM(price) AS source_product_revenue FROM olist_order_items_dataset;
SELECT SUM(price) AS view_product_revenue FROM v_FactOrders;

-- Payment totals are independent of item count
SELECT SUM(payment_value) AS source_payment_total FROM olist_order_payments_dataset;
SELECT SUM(payment_total) AS view_payment_total FROM v_FactOrderSummary;

-- Check for unexpected duplicate dimension keys
SELECT product_id, COUNT(*) AS n FROM v_DimProduct GROUP BY product_id HAVING COUNT(*) > 1;
```

These queries should agree where indicated. If not, investigate the source data and joins before publishing any totals.

## 6. Experiment work remains separate

The `ab_testing/` analysis uses a different public experiment dataset; it is not a live checkout experiment on Olist orders. `experiment_design.md` is a proposed checkout-message test. Neither should be presented as a production A/B test run for this retailer.
