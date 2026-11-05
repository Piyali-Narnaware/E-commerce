# Proposed A/B Test Design: Checkout Delivery Messaging

## Question

Would showing a clearer delivery-date range at checkout increase the proportion of eligible checkout sessions that become completed orders?

## Design

- **Control:** Current delivery information
- **Variant:** A clearer estimated delivery-date range
- **Assignment:** Randomly assign eligible checkout sessions 50/50 and keep returning users in the same group
- **Primary metric:** Completed orders divided by eligible checkout sessions
- **Guardrail metrics:** Cancellation rate, late-delivery rate, average order value and post-delivery review score
- **Analysis:** Compare conversion between groups after a pre-calculated sample size and test period; report the effect size and confidence interval

## Data required

The Olist order dataset contains order records but does not contain checkout sessions, exposure records or experiment assignments. It cannot measure conversion or estimate a treatment effect for this test. A live evaluation would require session-level tracking linked to randomized group assignment, followed by outcome data from order and delivery systems.
