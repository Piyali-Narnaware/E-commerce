# Landing-page A/B test analysis

## Scope

This module analyses a published landing-page experiment using user-level assignment and conversion records. It is a secondary analysis of an experiment conducted by others. It is not a test implemented by this project, and it is separate from the Olist e-commerce order dataset.

## Result

| Measure | Control: old page | Treatment: new page |
|---|---:|---:|
| Unique users | 145,274 | 145,310 |
| Conversions | 17,489 | 17,264 |
| Conversion rate | 12.04% | 11.88% |

The estimated treatment effect was **−0.158 percentage points** in absolute conversion, or **−1.31% relative to control**. The two-sided two-proportion test returned **p = 0.1899**. The 95% Newcombe-Wilson confidence interval for the absolute difference was **−0.394 to +0.078 percentage points**.

The 50:50 sample-ratio check returned **p = 0.9482**, with no evidence of an assignment imbalance. At the 5% significance level, the results do not establish a conversion difference. The confidence interval includes zero, so this is not evidence that the pages are equivalent. Conversion is the only available outcome; the dataset does not support conclusions about revenue, margin, cancellations or customer value.

## Analysis method

- Validated required fields and accepted values, parsed timestamps and removed invalid records
- Kept the earliest record per user so each user contributed one outcome
- Measured assignment-to-page mismatches and retained those users in the primary comparison by assigned group
- Checked the treatment-to-control allocation against the expected 50:50 split
- Calculated control and treatment conversion rates, absolute and relative lift, and a two-sided pooled two-proportion z-test
- Calculated a 95% Newcombe-Wilson confidence interval for the difference in conversion rates

The primary estimate follows an **intention-to-treat** approach: users are analysed by assigned group, even when the recorded page differs. Assignment-to-page mismatches are reported as a data-quality issue rather than excluded from the primary estimate.

## Reproduce

The raw dataset is not included in this repository. Download the public dataset from [Kaggle](https://www.kaggle.com/datasets/zhangluyuan/ab-testing) and place `ab_data.csv` at `data/ab_data.csv`. The dataset page lists its licence as unknown, so review its terms before redistributing the file.

From the repository root, install the dependencies and run:

```bash
pip install -r requirements.txt
python ab_testing/analyze_landing_page_test.py --data data/ab_data.csv --output ab_testing/outputs/ab_test_summary.csv
```

The script writes a one-row CSV with group sizes, conversion counts and rates, lift, test statistics, confidence limits, sample-ratio results and data-quality checks.

## Limits

This analysis estimates conversion difference for the published landing-page experiment only. It does not establish that the treatment caused a change in revenue or business value, and it does not evaluate pricing. The project author did not assign users, implement the pages or collect the experiment data.

## Source

- [Kaggle: A/B testing dataset by Luyuan Zhang](https://www.kaggle.com/datasets/zhangluyuan/ab-testing)
- [Analysis script](analyze_landing_page_test.py)
