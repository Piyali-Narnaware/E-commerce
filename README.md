# E-commerce Database and SQL Reporting

A data-management and SQL reporting project using the Brazilian Olist public e-commerce dataset. The project structures 99,441 orders from nine source tables in SQLite and prepares reusable reporting views.

## Data model and reporting

- Integrated nine Olist source tables into a normalised SQLite database with 12+ related entities and foreign-key relationships
- Created six SQL views for order, customer, product, seller, calendar and delivery analysis
- Documented a proposed Power BI dashboard layout and candidate DAX measures in [POWERBI_DASHBOARD.md](POWERBI_DASHBOARD.md); this is a design guide, not a completed dashboard

## Source data

The project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering orders placed from 2016 to 2018.

## Separate experiment analysis

The repository also includes a secondary analysis of a published landing-page experiment dataset. It is separate from the Olist data and was not implemented or collected by the project author. The analysis deduplicates user records, compares conversion by assigned group, checks assignment balance, and reports a two-proportion test and confidence interval. The dataset contains no revenue, margin, cancellation or customer-value outcomes.

- [Methods, results and limitations](ab_testing/README.md)
- [Analysis script](ab_testing/analyze_landing_page_test.py)
- [Proposed checkout-message test design](experiment_design.md)

## Reproduce

Install dependencies with `pip install -r requirements.txt`. Open `e-commerce_final code.db` with SQLite to inspect the database and use `powerbi_queries.sql` to review the reporting views.

## Repository contents

- `e-commerce_final code.db`: SQLite database
- `powerbi_queries.sql`: six SQL reporting views
- `POWERBI_DASHBOARD.md`: proposed Power BI dashboard design guide, not an implemented dashboard
- `e Commerce DB.drawio`: database diagram
- `ab_testing/`: separate public experiment-data analysis
- Olist CSV files: source data
