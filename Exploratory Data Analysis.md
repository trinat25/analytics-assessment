# EDA: Job Acceptance Analysis

This analysis explores the factors that drive a tradie's decision to accept a job invitation. The focus is on understanding the data, cleaning/preparing it, exploring key relationships, and identifying important features using machine learning.

---

## 1. Data Exploration & Observations

- **Dataset Overview:**  
  Reviewed column definitions, data collection methods, and timings.
  
- **Key Observations:**
  - **Missing Values:**  
    ~1.10% of jobs have no impressions (110 of 9,999 records).
  - **Negative Impressions:**  
    1.29% of records have negative values (~130 rows), increasing the margin of error.
  - **Estimated Size:**  
    Contains only "small" and "medium" – check for missing "large" job sizes.
  - **Time of Post:**  
    No data for the 23:00 time slot.

---

## 2. Data Preparation

- **Cleaning:**  
  - Replace null/negative `number_of_impressions` with 0.
  - Map `estimated_size` ("small", "medium", "large") to numeric values.
  
- **Feature Engineering:**  
  - Convert `time_of_post` to datetime; extract `post_hour` and `post_dayofweek`.
  - Apply KMeans clustering on geographical coordinates to create a `geo_cluster` feature, then drop raw latitude and longitude.

---

## 3. Exploratory Analysis

- **Target Variable:**  
  Overall acceptance rate is 26%.
  
- **Analyses Conducted:**  
  - Histograms and boxplots for continuous variables (e.g., impressions).
  - Comparison plots for acceptance vs. estimated job size, impressions per tradie, category, and posting time.
  - Scatter plots for impressions per tradie vs. acceptance rate.

- **Visualization:**  
  [View interactive visualization](https://public.tableau.com/app/profile/trina6463/viz/analytics-assessment/analyticsassessment?publish=yes)

---

## 4. Feature Selection & Modeling

- **Approach:**  
  Utilized a Random Forest classifier to assess feature importances and KMeans clustering to segment geographical data.
  
- **Selected Features:**  
  - `post_hour`, `post_dayofweek`, `geo_cluster`, `category`, `number_of_tradies`, `estimated_size`, `number_of_impressions`

---

## 5. Code Implementation

```python
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns

# Load and clean the dataset
file_path = '/Users/trinatan/downloads/Data Analytics Case Study - jobs.csv'
df = pd.read_csv(file_path)
df.columns = df.columns.str.strip()

# Convert 'time_of_post' to datetime and extract features
df['time_of_post'] = pd.to_datetime(df['time_of_post'])
df['post_hour'] = df['time_of_post'].dt.hour
df['post_dayofweek'] = df['time_of_post'].dt.dayofweek

# Clean 'number_of_impressions'
df['number_of_impressions'] = df['number_of_impressions'].apply(lambda x: 0 if pd.isnull(x) or x < 0 else x)

# Map 'estimated_size' to numeric values
size_mapping = {'small': 1, 'medium': 2, 'large': 3}
df['estimated_size'] = df['estimated_size'].apply(lambda x: size_mapping.get(x.lower(), np.nan) if isinstance(x, str) else x)
df['estimated_size'] = df['estimated_size'].fillna(df['estimated_size'].median())

# Geographical clustering using KMeans
kmeans = KMeans(n_clusters=5, random_state=42)
df['geo_cluster'] = kmeans.fit_predict(df[['latitude', 'longitude']])
df.drop(columns=['latitude', 'longitude'], inplace=True)

# Define features and target
features = ['post_hour', 'post_dayofweek', 'geo_cluster', 'category',
            'number_of_tradies', 'estimated_size', 'number_of_impressions']
target = 'accepted'

# Validate feature existence
missing_cols = [col for col in features if col not in df.columns]
if missing_cols:
    print("Missing columns:", missing_cols)
    features = [col for col in features if col in df.columns]

X = df[features]
y = df[target]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Train RandomForestClassifier and compute feature importances
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)
importances = rf.feature_importances_
feature_importance = pd.DataFrame({'feature': features, 'importance': importances}).sort_values(by='importance', ascending=False)
print(feature_importance)

# Plot feature importances
plt.figure(figsize=(10, 6))
sns.barplot(x='importance', y='feature', data=feature_importance)
plt.title('Feature Importances in Predicting Job Acceptance')
plt.xlabel('Importance')
plt.ylabel('Feature')
plt.show()
```
| Feature                | Importance |
|------------------------|------------|
| number_of_impressions  | 0.321088   |
| post_hour              | 0.291276   |
| post_dayofweek         | 0.118245   |
| number_of_tradies      | 0.106685   |
| estimated_size         | 0.065823   |
| geo_cluster            | 0.049925   |
| category               | 0.046958   |


With this plot 
![Screenshot 2025-02-24 at 1 05 54 am](https://github.com/user-attachments/assets/25504ebd-e269-497f-bc1d-9bd6241b30d7)

## 6. Recommendations

### Optimise Job Impressions
- **Targeted Impressions:**  
  Focus on targeted, relevant impressions rather than increasing them indiscriminately.
- **Personalised Notifications:**  
  Consider personalised notifications and frequency capping to avoid oversaturation.

### Optimise Posting Times
- **Optimal Timing:**  
  Identify optimal hours and days for job posts based on acceptance rates.
- **A/B Testing:**  
  Experiment with A/B testing different posting times to enhance engagement.

### Increase Outreach
- **Expand Tradie Pool:**  
  Improve recruitment and onboarding to expand the tradie pool.
- **Dynamic Targeting & Incentives:**  
  Use dynamic targeting and incentives to boost engagement with job postings.
