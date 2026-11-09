"""Analyse the public Udacity/Kaggle landing-page experiment dataset.

This is a secondary analysis of published experiment records, not an experiment
run by this project author. The primary estimate is intention-to-treat by the
recorded assignment group. The dataset has no revenue, margin, cancellation or
customer-value outcomes, so those guardrails are not estimated here.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.stats import binomtest, norm

REQUIRED_COLUMNS = {"user_id", "timestamp", "group", "landing_page", "converted"}


def wilson_interval(successes: int, total: int, z_value: float) -> tuple[float, float]:
    """Return a Wilson score interval for a binomial proportion."""
    rate = successes / total
    denominator = 1 + z_value**2 / total
    center = (rate + z_value**2 / (2 * total)) / denominator
    margin = (
        z_value
        * np.sqrt(rate * (1 - rate) / total + z_value**2 / (4 * total**2))
        / denominator
    )
    return center - margin, center + margin


def newcombe_difference_interval(
    treatment_successes: int,
    treatment_total: int,
    control_successes: int,
    control_total: int,
    confidence: float = 0.95,
) -> tuple[float, float]:
    """Newcombe-Wilson confidence interval for treatment minus control."""
    z_value = norm.ppf(1 - (1 - confidence) / 2)
    treatment_rate = treatment_successes / treatment_total
    control_rate = control_successes / control_total
    treatment_low, treatment_high = wilson_interval(
        treatment_successes, treatment_total, z_value
    )
    control_low, control_high = wilson_interval(
        control_successes, control_total, z_value
    )
    difference = treatment_rate - control_rate
    lower = difference - np.sqrt(
        (treatment_rate - treatment_low) ** 2
        + (control_high - control_rate) ** 2
    )
    upper = difference + np.sqrt(
        (treatment_high - treatment_rate) ** 2
        + (control_rate - control_low) ** 2
    )
    return lower, upper


def analyse(csv_path: Path, output_path: Path) -> pd.DataFrame:
    data = pd.read_csv(csv_path)
    missing = REQUIRED_COLUMNS - set(data.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    raw_rows = len(data)
    data = data.dropna(subset=list(REQUIRED_COLUMNS)).copy()
    data["timestamp"] = pd.to_datetime(data["timestamp"], errors="coerce")
    data["converted"] = pd.to_numeric(data["converted"], errors="coerce")
    data = data.dropna(subset=["timestamp", "converted"])
    data = data[data["converted"].isin([0, 1])]
    data = data[data["group"].isin(["control", "treatment"])]
    data = data[data["landing_page"].isin(["old_page", "new_page"])]

    # The assignment unit is the user. Keep the earliest recorded row per user.
    data = data.sort_values("timestamp").drop_duplicates("user_id", keep="first")
    if set(data["group"].unique()) != {"control", "treatment"}:
        raise ValueError("Both control and treatment groups must remain after cleaning.")

    mismatch_rate = (
        ((data["group"] == "treatment") != (data["landing_page"] == "new_page")).mean()
    )
    counts = data.groupby("group")["converted"].agg(["sum", "count"])
    control_successes = int(counts.loc["control", "sum"])
    control_total = int(counts.loc["control", "count"])
    treatment_successes = int(counts.loc["treatment", "sum"])
    treatment_total = int(counts.loc["treatment", "count"])
    control_rate = control_successes / control_total
    treatment_rate = treatment_successes / treatment_total
    absolute_lift = treatment_rate - control_rate
    relative_lift = absolute_lift / control_rate

    pooled_rate = (control_successes + treatment_successes) / (
        control_total + treatment_total
    )
    standard_error = np.sqrt(
        pooled_rate * (1 - pooled_rate) * (1 / control_total + 1 / treatment_total)
    )
    z_statistic = absolute_lift / standard_error
    p_value = 2 * norm.sf(abs(z_statistic))
    ci_low, ci_high = newcombe_difference_interval(
        treatment_successes, treatment_total, control_successes, control_total
    )

    srm = binomtest(
        treatment_total,
        n=treatment_total + control_total,
        p=0.5,
        alternative="two-sided",
    )

    output = pd.DataFrame(
        [
            {
                "raw_rows": raw_rows,
                "unique_users_analysed": treatment_total + control_total,
                "control_users": control_total,
                "treatment_users": treatment_total,
                "duplicate_user_rows_removed": raw_rows - len(data),
                "assignment_exposure_mismatch_rate": mismatch_rate,
                "control_conversions": control_successes,
                "treatment_conversions": treatment_successes,
                "control_conversion_rate": control_rate,
                "treatment_conversion_rate": treatment_rate,
                "absolute_lift_percentage_points": absolute_lift * 100,
                "relative_lift_percent": relative_lift * 100,
                "z_statistic": z_statistic,
                "p_value_two_sided": p_value,
                "difference_ci95_low_percentage_points": ci_low * 100,
                "difference_ci95_high_percentage_points": ci_high * 100,
                "sample_ratio_mismatch_p_value": srm.pvalue,
                "statistically_significant_at_5_percent": p_value < 0.05,
                "guardrail_data_available": False,
            }
        ]
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output.to_csv(output_path, index=False)

    print(f"Rows read: {raw_rows:,}")
    print(f"Unique users analysed: {len(data):,}")
    print(f"Assignment/exposure mismatch: {mismatch_rate:.2%}")
    print(f"Control conversion: {control_rate:.2%} ({control_successes:,}/{control_total:,})")
    print(
        f"Treatment conversion: {treatment_rate:.2%} "
        f"({treatment_successes:,}/{treatment_total:,})"
    )
    print(f"Absolute lift: {absolute_lift * 100:.3f} percentage points")
    print(f"Relative lift: {relative_lift * 100:.2f}%")
    print(f"95% CI for absolute lift: [{ci_low * 100:.3f}, {ci_high * 100:.3f}] pp")
    print(f"Two-sided p-value: {p_value:.4f}")
    print(f"50/50 sample-ratio check p-value: {srm.pvalue:.4f}")
    print("Guardrails: unavailable in this dataset; no margin or customer-quality claim.")
    print(f"Summary saved to: {output_path}")
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data",
        type=Path,
        default=Path("data/ab_data.csv"),
        help="Path to the downloaded ab_data.csv",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("outputs/ab_test_summary.csv"),
        help="Path for the one-row results CSV",
    )
    args = parser.parse_args()
    analyse(args.data, args.output)


if __name__ == "__main__":
    main()
