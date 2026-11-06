# Checkout Delivery Messaging A/B Test Plan

## Question

Would showing a clearer delivery-date range at checkout increase the proportion of eligible checkout sessions that become completed orders?

## Experiment design

- **Control:** Current delivery information
- **Variant:** A clearer estimated delivery-date range
- **Assignment:** Randomly assign eligible checkout sessions 50/50 and keep returning users in the same group
- **Primary metric:** Completed orders divided by eligible checkout sessions
- **Guardrail metrics:** Cancellation rate, late-delivery rate, average order value and post-delivery review score

## Test workflow

1. **Implement the test:** Apply the control and variant at checkout and assign eligible sessions randomly, keeping each returning user in the same group
2. **Collect results:** Record assignment, variant exposure, eligible checkout sessions, completed orders and guardrail outcomes
3. **Calculate treatment effects:** Compare conversion rates between variant and control; report the absolute percentage-point difference and relative lift
4. **Assess statistical significance:** Set the sample size and test duration in advance, then use a two-proportion test and confidence interval to assess whether the observed difference is distinguishable from chance
5. **Evaluate conversion improvement:** Report observed conversions, absolute and relative lift, uncertainty and guardrail outcomes before recommending a rollout

## Data requirements

The Olist order dataset contains order records but does not contain checkout sessions, exposure records or experiment assignments. It cannot measure conversion or estimate a treatment effect for this test. A live evaluation would require session-level tracking linked to randomized group assignment, followed by outcome data from order and delivery systems. No conversion improvement can be calculated from the current Olist data.
