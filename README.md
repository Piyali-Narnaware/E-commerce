# E-commerce Database and Reporting

A SQL and Power BI analytics project built with the Brazilian Olist public e-commerce dataset. It structures **99,441 orders** from nine source tables into a relational SQLite database, prepares reusable reporting views and presents performance measures in a four-page dashboard.

## Project workflow

`CSV source tables → SQLite relational model → SQL reporting views → Power BI dashboard`

## Data model and reporting

- Integrated nine Olist source tables into a normalised SQLite model with 12+ related entities and foreign-key relationships
- Created six SQL views for order, customer, product, seller, calendar and delivery analysis
- Built a four-page Power BI dashboard covering executive performance, sales and products, customers and reviews, and delivery and operations
- Added five DAX measures for total revenue, average order value, on-time delivery, month-over-month revenue and average review score

## Source data

The project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering orders placed from 2016 to 2018.

| Source table | Approximate rows | Use |
|---|---:|---|
| Customers | 99,000 | Customer and location analysis |
| Orders | 99,441 | Order dates and status |
| Order items | 113,000 | Products, sellers and item values |
| Payments | 103,000 | Payment methods and instalments |
| Reviews | 99,000 | Review scores and comments |
| Products | 33,000 | Product attributes and categories |
| Sellers | 3,000 | Seller details and location |
| Geolocation | 1,000,000 | ZIP-code coordinates |
| Category translation | 71 | English category labels |

## Experiment analysis

The repository also contains a separate analysis of public landing-page experiment data. It checks assignment balance, calculates conversion lift, tests statistical significance and reports a confidence interval. This is a secondary dataset analysis, not an experiment conducted by the project author. The data does not include margin or customer-value guardrails, and the analysis is not a pricing experiment.

- [Analysis and limitations](ab_testing/README.md)
- [Analysis script](ab_testing/analyze_landing_page_test.py)
- [Separate proposed checkout test design](experiment_design.md)

## Reproduce

Clone the repository and install the Python dependencies:

```bash
git clone https://github.com/Piyali-Narnaware/E-commerce.git
cd E-commerce
pip install -r requirements.txt
```

Open `e-commerce_final code.db` with SQLite to inspect the database. Use `powerbi_queries.sql` to review the reporting views and `POWERBI_DASHBOARD.md` for the dashboard build notes and DAX measures.

## Repository contents

- `e-commerce_final code.db`: populated SQLite database
- `powerbi_queries.sql`: six reporting views
- `POWERBI_DASHBOARD.md`: dashboard build notes and DAX definitions
- `e Commerce DB.drawio`: editable database diagram
- `ab_testing/`: separate public experiment-data analysis
- `experiment_design.md`: proposed checkout-message experiment
- Olist CSV files: source data
