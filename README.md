# E-commerce Reporting | SQLite, SQL & Data Quality

**Aim:** How can raw marketplace tables be turned into reliable, reusable reporting datasets?

This project uses the [Olist Brazilian e-commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) to examine orders, payments, products, customers and delivery performance. I focused on getting the reporting tables and totals right before moving on to dashboard design.

## Work completed

- Explored the relationships between the source tables and documented the database structure in [the schema diagram](e%20Commerce%20DB.drawio)
- Built reporting views in [`powerbi_queries.sql`](powerbi_queries.sql) for order, customer, product, seller, calendar and delivery analysis
- Added [automated SQL checks](validate_sql.py) covering row counts, uniqueness and reconciliation of payment and product-revenue totals
- Documented proposed Power BI measures and pages in [`POWERBI_DASHBOARD.md`](POWERBI_DASHBOARD.md)

**Validation:** The automated reporting-view checks passed against the Olist CSVs loaded into SQLite. The checks cover the queries listed above, not every possible metric.

## Reporting questions

| Question | Evidence to inspect | Why it matters |
|---|---|---|
| How does order volume change over time? | Order and calendar views | Understand trading patterns |
| How much revenue is associated with products and sellers? | Product and seller views | Identify areas for deeper performance analysis |
| Where are delivery delays concentrated? | Delivery view | Investigate fulfilment performance |
| Do payment totals reconcile? | Payment validation checks | Increase confidence in reported figures |

These are analytical questions, not claims that commercial improvements were implemented.

## Reproduce the reporting layer

```bash
pip install -r requirements.txt
python validate_sql.py
```

See [the validation workflow](.github/workflows/validate-sql.yml) for the automated check.

**Two database contexts:** The committed `e-commerce_final code.db` is an earlier database with a different schema. The Olist reporting SQL is validated by loading the source CSVs into its own SQLite schema. Do **not** assume that `powerbi_queries.sql` runs unchanged against the committed database file.

## Power BI status

[`POWERBI_DASHBOARD.md`](POWERBI_DASHBOARD.md) is a **design specification** with suggested measures, not proof of a completed or tested Power BI dashboard. A final report screenshot and refreshed PBIX would be needed to demonstrate the visual reporting layer.

## Separate experiment exercise

The [A/B testing analysis](ab_testing/README.md) uses a separate published landing-page dataset. It was not run on Olist customers, and the experiment was not designed or conducted by the project author. Its results should not be presented as a live e-commerce conversion improvement.

## Limitations

Historical public data cannot establish current trading performance. SQL reconciliation checks support data integrity but do not establish causality, financial impact or production deployment.
