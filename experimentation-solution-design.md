# Solution Design Overview

This document outlines the A/B test design to evaluate whether increasing tradie leads per job from 3 to 4 improves lead utilisation without harming key secondary outcomes.

---

## 1. Test Rationale & Considerations

**Benefits:**
- **Increased Competition:** More tradies can claim a lead, leading to more competitive quotes.
- **Higher Lead Utilisation:** More leads claimed may boost platform revenue.
- **Enhanced Consumer Experience:** More options for consumers.

**Downsides:**
- **Reduced Lead Acceptance:** Too many options may overwhelm consumers.
- **Lower Tradie ROI:** Increased competition might decrease each tradie’s success rate.
- **Potential Churn:** Poor ROI could lead to higher tradie churn over time.

---

## 2. Test Preparation

### Objective
Determine if increasing leads per job from 3 to 4 improves lead utilisation while preserving tradie engagement and conversion rates.

### Hypotheses
- **H₀:** Increasing leads to 4 does not improve utilisation.
- **H₁:** Increasing leads to 4 improves utilisation.

### Primary Metric
**Lead Utilisation Rate:**  
- **Formula:**  
  `Utilisation Rate = (Total Leads Claimed) / (Total Leads Available)`
- **Example:**  
  If 100 leads are posted and 75 are claimed, the utilisation rate is 75%.

### Secondary (Guardrail) Metrics
1. **Lead Acceptance Rate:**  
   - **Formula:**  
     `Lead Acceptance Rate = (Jobs Accepted) / (Leads Claimed)`
   - **Threshold:**  
     A drop of more than 5–10% triggers review.
2. **Tradie Lead ROI:**  
   - **Formula:**  
     `Tradie Lead ROI = (Jobs Won) / (Leads Claimed)`
   - **Threshold:**  
     A drop of more than 5–10% triggers investigation.
3. **Tradie Churn Rate:**  
   - **Formula:**  
     `Tradie Churn Rate = (Subscriptions Cancelled) / (Total Active Subscriptions)`
   - **Threshold:**  
     An increase of more than 5% in monthly churn triggers review.

---

## 3. Test Method

### Bayesian vs. Frequentist

| **Aspect**           | **Bayesian**                                          | **Frequentist**                             |
|----------------------|-------------------------------------------------------|---------------------------------------------|
| **Interpretability** | Direct probability statements (e.g., "96% chance")    | p-values & confidence intervals             |
| **Flexibility**      | Adaptive sampling; supports early stopping            | Fixed sample sizes                           |
| **Prior Data**       | Incorporates historical data                          | No integration of prior data                 |

### Why Bayesian?
- **Continuous Monitoring:** Adaptive, real-time analysis.
- **Intuitive Communication:** Results are expressed as probabilities.
- **Historical Data Integration:** Uses prior performance for informed analysis.

---

## 4. Technical Execution

### Variants
- **Control Group:** 3 leads per job.
- **Treatment Group:** 4 leads per job.

### Tracking Requirements
- **Variant Assignment:** Record which job receives 3 or 4 leads.
- **Job Data:** Capture job ID, consumer ID, category, location, and timestamp.
- **Lead Events:** Log when tradies claim a lead (timestamp, tradie ID).
- **Conversion Events:** Track outcomes (e.g., quote provided, job accepted).

### Sample Data Schema

| Column Name       | Description                                      |
|-------------------|--------------------------------------------------|
| job_id            | Unique job identifier                            |
| user_id           | Consumer posting the job                         |
| variant           | Control (3 leads) / Treatment (4 leads)          |
| leads_offered     | Number of leads offered (3 or 4)                 |
| lead_claimed      | Indicator if a tradie claimed the lead (Yes/No)  |
| claim_timestamp   | Timestamp when the lead was claimed              |
| conversion_status | Outcome (e.g., quote provided, no response)      |
| created_at        | Job posting timestamp                            |

### Additional Recommendations
- Ensure randomized assignment.
- Calculate adequate sample size.
- Use real-time dashboards.
- Conduct regular data quality audits.

---

## 5. Interpretation & Simulated Bayesian Analysis

### Simulated Analysis

**Prior Setup:**  
- Historical utilisation is ~75% (750 out of 1,000 leads claimed).  
- **Prior Distribution:**  
  - Alpha (α) = 750 + 1 = 751  
  - Beta (β) = 250 + 1 = 251  
  - Represented as: `Beta(751, 251)`

**Experimental Data (500 jobs per variant):**
- **Control (3 Leads):**  
  - 375 claimed out of 500 (75%)
- **Treatment (4 Leads):**  
  - 410 claimed out of 500 (82%)

**Posterior Updating:**
- **Control Group:**  
  - New α = 751 + 375 = 1126  
  - New β = 251 + (500 - 375) = 251 + 125 = 376  
  - Posterior: `Beta(1126, 376)`
- **Treatment Group:**  
  - New α = 751 + 410 = 1161  
  - New β = 251 + (500 - 410) = 251 + 90 = 341  
  - Posterior: `Beta(1161, 341)`

**Result:**  
Simulations indicate approximately a **96% probability** that the treatment group's utilisation rate is higher than the control group's.

### Key Takeaways
- **Prior Integration:** Uses 1,000 historical observations to inform analysis.
- **Posterior Interpretation:** A 96% probability strongly supports increasing leads to 4.
- **Actionable Insight:** Supports an adaptive decision-making process.

---

## 6. Next Steps & Commercial Recommendations

### If the Variant Wins
- **Phased Rollout:** Expand gradually in high-value segments.
- **Marketing Leverage:** Use improved metrics for success stories.
- **Pricing Strategy:** Reassess lead pricing based on improved conversion.
- **Optimization:** Focus on segments with the highest uplift for further improvements.

### If the Variant Loses
- **Reassess Hypothesis:** Explore if additional leads dilute lead quality.
- **Feature Tuning:** Consider personalized lead allocation.
- **Stakeholder Communication:** Clearly discuss commercial implications and potential pivots.
- **Further Testing:** Plan supplementary experiments to refine insights.



​




