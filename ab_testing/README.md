# A/B Test Analysis

This folder analyses the public landing-page experiment dataset linked below. It demonstrates experiment data checks, conversion analysis, treatment-effect estimation, significance testing and a decision against a conversion rollout when evidence does not support improvement.

This is a secondary analysis of published experiment records. It was not an experiment implemented or collected by this project author, and it is not a pricing test.

## Run

1. Download `ab_data.csv` from the [Kaggle A/B testing dataset](https://www.kaggle.com/datasets/zhangluyuan/ab-testing)
2. Place the file at `data/ab_data.csv`
3. Install project dependencies with `pip install -r requirements.txt`
4. Run `python ab_testing/analyze_landing_page_test.py`

The script checks required fields, removes repeat user records, reports assignment-to-page mismatches, checks the 50/50 sample split and compares conversion rates by assigned group. It reports absolute and relative lift, a two-sided two-proportion test and a 95% Newcombe-Wilson confidence interval. Results are written to `outputs/ab_test_summary.csv`.

## Interpretation

The primary comparison is intention-to-treat by assigned group. Assignment/page mismatches are reported as a data-quality and implementation issue; the script does not silently remove these users from the primary estimate.

The dataset contains conversion outcomes only. It does not include booking value, revenue, margin, cancellations or customer-value guardrails. The analysis therefore cannot establish commercial profitability or the effect of pricing changes. The dataset page lists its licence as unknown; obtain and review its terms before redistribution. The raw data is not included in this repository.

## Source

- [Kaggle: A/B testing dataset by Luyuan Zhang](https://www.kaggle.com/datasets/zhangluyuan/ab-testing)
