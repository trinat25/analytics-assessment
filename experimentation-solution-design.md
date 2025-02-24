# Solution Design (Theory)

Small summary of my thinking : 
Mandating 4 leads per job refers to increasing the maximum number of tradies who can claim a lead for a single job from 3 to 4. This change aims to provide consumers with more options while potentially increasing lead utilisation and platform revenue.

- Potential Benefits:
  - Increased Competition: Consumers may receive more competitive quotes, improving the likelihood of finding a suitable tradie.
  - Higher Lead Utilisation: Allowing an additional tradie to claim each job may improve the platform’s lead utilisation rate, generating more revenue per job listing.
  - Better Consumer Experience: Consumers have more choices, potentially leading to higher job completion rates.
- Potential Downsides:
  - Lower Lead Acceptance Rate: With increased competition, each tradie’s probability of securing a job decreases, which may reduce engagement and ROI.
  - Consumer Overload: Receiving too many quotes may overwhelm consumers, making them less likely to respond or proceed with a job booking.
  - Tradie Dissatisfaction: Tradies may become less willing to purchase leads if their success rate declines, negatively impacting long-term retention.

## Preparation 

### Objective of test 
Is to determine if increase the number of leads per job from 3 to 4 will result in higher lead utilisation while maintaining tradie engagement and conversion rates.
### Set Hypothesis 
- Null Hypothesis (H₀): Increasing the number of leads to 4 does not increase lead utilisation.
- Alternative Hypothesis (H₁): Increasing the number of leads to 4 does increase lead utilisation.
### Identify primary metric
Primary Metric 
- lead utilisation rate on Hipages platform  : total leads claimed by tradies / total leads available.
Measures the platform's efficiency in matching leads with tradies.
For example, if 100 leads are posted and 75 are claimed by tradies, the platform-level utilisation rate is 75%.
- Why This Matters:
  - Higher utilisation means fewer unclaimed leads, indicating better matching and lead relevance.
  - Lower utilisation might highlight issues such as:
  - Poor job-tradie fit
  - Competition saturation
### Guardrail / Secondary metric 
This is to make sure an increase in primary metric do not come at the expense of other key business outcomes. 
1.  Lead Acceptance Rate
Definition: Percentage of leads that result in a consumer accepting a quote.
Lead Acceptance Rate=Number of jobs accepted/Number of leads claimed
- Why It Matters:
  - More leads per job might overwhelm consumers, making them less likely to select a tradie.
  - A significant drop in this metric would indicate that the additional lead is diluting consumer interest.
- Threshold:
  - A decrease of more than 5-10% in the Lead Acceptance Rate should trigger a review to determine if the change negatively impacts consumer decision-making.
 
2. Tradie Lead ROI (Return on Investment)
Definition: The percentage of leads claimed that result in a paid job for the tradie.
Lead ROI=Number of jobs won/Number of leads claimed
- Why It Matters:
  - More competition means fewer won jobs per tradie, potentially reducing their ROI and increasing frustration.
  - A decline in ROI might lead to churn if tradies feel their lead credits are yielding fewer returns.
- Threshold:
  - A drop of more than 5-10% in Lead ROI should trigger an investigation into whether additional competition is reducing the value of each lead.
 
3. Tradie Churn Rate (Lagging Indicator)
Definition: Percentage of tradies who cancel their subscription within a given time frame (e.g., within 1 or 3 months).
Tradie Churn Rate=Number of subscriptions cancelled/Total active subscriptions
- Why It Matters:
  - Increased competition may lead to lower ROI, causing tradies to churn after their subscription period ends.
  - Since churn is a lagging indicator, it should be monitored both during and after the experiment.
- Threshold:
  - An increase of more than 5% in monthly churn within 3 months of rolling out the feature would indicate a negative long-term impact.
 
### Choosing a test method 
# Short Comparison of Bayesian vs Frequentist A/B Testing

| **Aspect**           | **Bayesian**                                          | **Frequentist**                             |
|----------------------|-------------------------------------------------------|---------------------------------------------|
| **Interpretability** | Direct probability statements; easier to understand  | p-values and confidence intervals           |
| **Flexibility**      | Adaptive sampling; supports early stopping             | Requires fixed sample sizes                 |
| **Prior Information**| Incorporates historical data for nuanced insights       | Does not integrate prior data               |

## Why Bayesian is Beneficial for the hipages Test

- **Continuous Monitoring & Early Stopping:**  
  The Bayesian framework supports ongoing analysis without the need for pre-determined sample sizes. This is advantageous in the hipages scenario where early detection of significant improvements (or lack thereof) in lead utilisation can help in quicker decision making.

- **Intuitive Communication:**  
  By directly providing the probability of one variant being better than the other, Bayesian results are more easily communicated to product managers and non-technical stakeholders. This clarity helps in building confidence in the decision process.

- **Utilisation of Historical Data:**  
  Bayesian methods allow the integration of past performance data or expert opinions as priors. For hipages, where historical data on lead conversion might exist, this leads to more informed insights even if the new feature’s impact is subtle.

- **Adaptive Experimentation:**  
  Since the Bayesian approach is inherently more flexible, the experiment can adapt based on interim results. This is particularly useful in a dynamic environment like hipages, where consumer behavior and tradie engagement can vary widely.

Overall, for hipages’ goal of optimizing lead utilisation by mandating 4 leads per job, the Bayesian approach not only aligns better with real-world decision making but also provides a robust framework to handle uncertainty and integrate prior insights, leading to more actionable and transparent results.

# Technical Execution for A/B Testing

## Variants Definition
- **Control Group:** Jobs receive 3 leads (current standard).
- **Treatment Group:** Jobs receive 4 leads (new feature).

## Tracking Requirements
- **Variant Assignment:**  
  Track which variant (control or treatment) each job is assigned to.
- **Job Data:**  
  Record key attributes such as job ID, consumer ID, category, location, and timestamp.
- **Lead Tracking:**  
  Log events when tradies claim leads including claim timestamp and tradie ID.
- **Conversion Events:**  
  Capture outcomes like quote provision or lead conversion to assess performance.
- **User Behavior:**  
  Monitor additional interactions, for example, follow-up actions or engagement metrics.

## Sample Data Schema
Below is a sample table structure for analyzing the test results:

| **Column Name**   | **Description**                                       |
|-------------------|-------------------------------------------------------|
| job_id            | Unique identifier for each job                        |
| user_id           | Identifier for the consumer posting the job           |
| variant           | Test group assignment (control: 3 leads, treatment: 4 leads) |
| leads_offered     | Number of leads offered (3 or 4)                       |
| lead_claimed      | Indicator if a tradie claimed the lead (Yes/No)        |
| claim_timestamp   | Timestamp when the lead was claimed                    |
| conversion_status | Outcome of the lead (e.g., quote provided, no response)|
| created_at        | Timestamp when the job was posted                      |

## Additional Recommendations
- **Randomisation:** Ensure unbiased, random assignment to the test groups.
- **Sample Size:** Determine the appropriate sample size to detect the expected impact.
- **Real-Time Monitoring:** Implement dashboards for continuous metric tracking.
- **Data Quality Audits:** Regularly validate data integrity throughout the experiment.
- **Post-Test Analysis:** Plan for both primary and secondary metric evaluation to derive comprehensive insights.


# Interpretation of A/B Test Results

## Primary Outcome Analysis
- **Key Metric Evaluation:**  
  Assess the primary metric (e.g., lead conversion or tradie claim rate) to gauge the impact of offering 4 leads versus 3 leads.
- **Bayesian Analysis:**  
  Calculate the posterior probability that the treatment (4 leads) outperforms the control (3 leads). A probability greater than 95% indicates strong support for the new feature.

## Secondary Outcome Analysis
- **Lead Acceptance Rate:**  
  Compare the rate at which tradies accept leads between the variants.
- **Tradie Lead ROI (Return on Investment):**  
  Evaluate the financial effectiveness by comparing costs and revenues associated with claimed leads.
- **Tradie Churn Rate (Lagging Indicator):**  
  Monitor tradie retention over time to assess long-term engagement and satisfaction.

## Decision Criteria
- **Success Thresholds:**  
  Pre-define a success criterion (e.g., >95% posterior probability) to determine if the treatment is commercially viable.
- **Business Impact Consideration:**  
  Ensure that improvements in key metrics translate into meaningful revenue gains, improved efficiency, and enhanced customer satisfaction.

## Next Steps - Commercial Driven Recommendations

### If the Variant Wins
- **Phased Rollout:**  
  Given strong Bayesian evidence supporting 4 leads, consider a phased rollout across high-traffic or high-value segments to confirm scalability while maximizing revenue.
- **Marketing Leverage:**  
  Use the improved metrics (higher lead acceptance, better ROI, and lower churn) to create compelling success stories for sales and marketing collateral.
- **Pricing and Contract Strategy:**  
  Reassess pricing models for leads with the improved conversion metrics, potentially negotiating better terms with tradies or upselling premium lead packages.
- **Further Optimization:**  
  Identify segments with the highest performance uplift and explore whether fine-tuning the lead allocation (or even testing additional variants) could yield further commercial benefits.

### If the Variant Loses
- **Hypothesis Reassessment:**  
  Investigate whether the additional lead may have diluted lead quality, resulting in lower acceptance rates, reduced ROI, and increased churn. This insight could inform improvements in lead matching or allocation algorithms.
- **Iterative Feature Tuning:**  
  Consider adjustments such as personalized lead counts based on job category or tradie performance. This may involve additional experiments targeting specific segments.
- **Stakeholder Communication:**  
  Clearly communicate the commercial implications of the pilot not meeting expected outcomes. Discuss potential pivot strategies or feature modifications to mitigate negative impacts.
- **Supplementary Experiments:**  
  Plan further tests to isolate variables (e.g., quality vs. quantity of leads) and gather more granular insights, ensuring that future iterations better align with commercial objectives.



​




