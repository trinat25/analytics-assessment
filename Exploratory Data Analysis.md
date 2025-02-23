## EDA Job Acceptance Analysis 

I'd like the focus of this analysis to identify which factors drive a tradie's decision to accept a job inviation. 

### Step 1 Explore and learn about the dataset / columns
I meticulously analyse the dataset by clarifying each column's definition, exploring the subtleties of the collected data, and ensuring I fully understand both the methods and timing behind its collection.

### Step 2 Data Preparation 
- Data cleaning, look at missing values, duplications or outliers. 
In this case, I noticed
  - missing value : some jobs have no impressions, 1.10% (110 of the 9,999 records)
  - some impressions are in negative 
    - 1.29% of impressions are in negative (about 130 of the 9,999 rows impacted)
    - Increase in margin of error. This can widen confidence intervals and increase the margin of error, leading to less precise parameter estimates in your predictive model.
    - Method used , replace with 0 , ignore rows with negative impressions or replace values with median. 
  - estimated_size only contain small and medium, good to check if the dataset should also have large job size before commencing. 

### Step 3 Exploration 
- Target Variable (accepted) 
  - I had  a look at the overall acceptance rate in the data set. 26% of the rows had a job accepted flag. 
- Continuous Variables  
  - Used histogram to identify null values, or potential data problems like negative impressions. 
  - Used boxplot to identify outliers.
- Other exploration
  - acceptance vs estimated job size
  - acceptance vs impressions
  - acceptance vs category

For the above, please refer to this [visualisation](https://public.tableau.com/app/profile/trina6463/viz/EDA-analytics-assessment/ExploratoryDataAnalysisPt1)
 
  - acceptance vs hour or day of week
  - job volume by state
    
For the last 2 points, please refer to this [visualisation](https://public.tableau.com/app/profile/trina6463/viz/EDA-analytics-assessmentPt2/ExploratoryDataAnalysisPt2?publish=yes)

### Step 4 Identify the Features that Best Predict Job Acceptance
Based on the above EDA, I explored the possibility of predicting job acceptance using a Random Forest classifier and KMeans clustering. 
I chose these methods because they handle mixed data types well – they work with numerical (e.g., estimated_size) and categorical features (e.g., category) and are effective at capturing non-linear relationships between predictors and the target variable. 
I also converted 'time_of_post' to a datetime format and extracted time features, as well as applied clustering to the geographical data to enable this analysis.
```
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns

# File path to your CSV file
file_path = '/Users/trinatan/downloads/Data Analytics Case Study - jobs.csv'

# Load the dataset
df = pd.read_csv(file_path)

# Strip extra whitespace from column names
df.columns = df.columns.str.strip()
print("Columns in DataFrame:", df.columns.tolist())

# Convert 'time_of_post' to datetime and extract time features
df['time_of_post'] = pd.to_datetime(df['time_of_post'])
df['post_hour'] = df['time_of_post'].dt.hour
df['post_dayofweek'] = df['time_of_post'].dt.dayofweek  # 0 = Monday, 6 = Sunday

# Clean the 'number_of_impressions' column: replace nulls or negatives with 0
df['number_of_impressions'] = df['number_of_impressions'].apply(lambda x: 0 if pd.isnull(x) or x < 0 else x)

# Handle 'estimated_size': convert strings like 'small', 'medium', 'large' to numeric values
def map_estimated_size(x):
    if isinstance(x, str):
        mapping = {'small': 1, 'medium': 2, 'large': 3}
        return mapping.get(x.lower(), np.nan)
    return x

df['estimated_size'] = df['estimated_size'].apply(map_estimated_size)
# Optionally, fill missing values with the median if needed
df['estimated_size'] = df['estimated_size'].fillna(df['estimated_size'].median())

# Perform KMeans clustering on geographical coordinates (latitude and longitude)
kmeans = KMeans(n_clusters=5, random_state=42)
df['geo_cluster'] = kmeans.fit_predict(df[['latitude', 'longitude']])

# Drop the raw latitude and longitude columns since geo_cluster captures spatial info
df = df.drop(columns=['latitude', 'longitude'])

# Define features and target variable.
# Note: latitude and longitude are no longer included.
features = ['post_hour', 'post_dayofweek', 'geo_cluster', 'category',
            'number_of_tradies', 'estimated_size', 'number_of_impressions']
target = 'accepted'

# Verify that all features exist in the DataFrame
missing_cols = [col for col in features if col not in df.columns]
if missing_cols:
    print("Missing columns detected:", missing_cols)
    features = [col for col in features if col in df.columns]
    print("Updated features list:", features)

# Create feature matrix X and target vector y
X = df[features]
y = df[target]

# Split the data into training and testing sets (70% train, 30% test)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Train a RandomForestClassifier to assess feature importances
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)

# Extract and sort feature importances
importances = rf.feature_importances_
feature_importance = pd.DataFrame({'feature': features, 'importance': importances})
feature_importance.sort_values(by='importance', ascending=False, inplace=True)
print(feature_importance)

# Visualize the feature importances
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

### Step 5 - Recommendations 
1. Boost Job Impressions:
Since number_of_impressions has the highest importance (0.321088), increasing the visibility of job postings is key. Consider:
- Enhancing notification systems or email alerts to reach more tradies.
- Optimising the platform’s UI to feature high-potential jobs more prominently.

2. Optimise Posting Times:
With post_hour (0.291276) and post_dayofweek (0.118245) being influential, the timing of job posts is critical. You could:
- Analyse which hours and days yield the highest acceptance rates and schedule postings accordingly.
- Test different posting times (A/B testing) to identify the best windows for tradie engagement.

3. Increase Outreach:
The number_of_tradies (0.106685) suggests that reaching a broader audience can improve acceptance rates. Strategies might include:
- Expanding the pool of tradies by improving your recruitment or onboarding efforts.
- Using dynamic targeting to ensure jobs are sent to tradies most likely to accept.
- Offering incentives or bonuses for tradies to engage with new job postings.

By focusing on these areas—especially boosting impressions and optimising posting times—you can drive more tradies to view and ultimately accept job invitations, improving overall acceptance rates.
