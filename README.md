🛒 Superstore Sales & Profitability Analysis

End-to-end data analytics project: Python (cleaning + EDA) → SQL Server (analysis) → Power BI (interactive dashboard)

Which products, regions and customer segments make money, which lose it, and why?

📌 Table of Contents
Project Overview
Business Questions
Tech Stack
Dataset
Project Workflow
Key Insights
Dashboard Preview
Repository Structure
How to Run
Skills Demonstrated
Author
📖 Project Overview

This project analyses the Sample Superstore retail dataset (~10,000 order line items across 3 sheets: Orders, Returns, People) from raw Excel file to a 5-page interactive Power BI dashboard.

The goal is to go beyond "what happened" and explain why, especially where discounts, returns and product mix are hurting profit.

Pipeline:

Excel (raw) → Python: clean + EDA → SQL Server: analysis queries → Power BI: dashboard + AI insights
❓ Business Questions
Are we profitable overall, and is it improving over time?
Which categories and sub-categories make money, and which lose money?
Which regions and states perform best and worst?
Which customer segments are the most valuable?
What drives returns and loss-making orders?
🛠 Tech Stack
Stage	Tools
Data cleaning & EDA	Python, Pandas, NumPy, Matplotlib, Seaborn, Jupyter Notebook
Data storage & analysis	Microsoft SQL Server, SSMS, SQLAlchemy, pyodbc
Dashboard	Power BI Desktop, DAX
Version control	Git, GitHub
📂 Dataset
Source: Sample Superstore (sample_superstore.xlsm)
Sheets:
Orders: ~9,994 rows × 21 columns (sales, profit, discount, category, region, dates, etc.)
Returns: list of returned Order IDs
People: regional managers
Period: [add order date range, e.g. Jan 2014 – Dec 2017]
🔄 Project Workflow
1️⃣ Data Cleaning (Python)
Notebook: notebooks/superstore_cleaning_eda.ipynb

Step	What was checked / done	Why
Load	Read all 3 sheets from the workbook	Data was split across sheets
Structure	shape, info(), head()	Understand columns and types
Nulls & duplicates	isnull().sum(), duplicated()	Confirm data quality (no nulls or exact duplicates found)
Data types	Postal Code converted to text; date columns validated (Ship Date never before Order Date)	IDs are labels, not numbers
Category consistency	Checked unique values of Ship Mode, Segment, Region, Category	Prevent duplicate groups from spelling variants
Outliers	describe() + IQR check on Sales; investigated negative Profit	Negative profit is a real business loss (heavy discounting), so it was kept, not removed
Merge	Left-joined Returns and People onto Orders; missing return match → "No"	An order absent from Returns was not returned
Validate & save	assert checks, saved to data/cleaned/	Prove the data meets the rules

2️⃣ Exploratory Data Analysis (Python)
Univariate: Sales distribution (right-skewed), orders per category
Bivariate: Profit by category (box plot), Discount vs Profit (scatter), Region vs return rate (crosstab)
Correlation: heatmap of Sales, Quantity, Discount, Profit
Time trend: monthly sales

3️⃣ SQL Analysis (SQL Server)

The cleaned data was loaded into SQL Server (Orders_data table) using SQLAlchemy + pyodbc, then analysed with SQL.

Queries live in sql/analysis_queries.sql. Examples:

**sql
-- Profit and margin by category
SELECT
    Category,
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS profit_margin_pct
FROM Orders_data
GROUP BY Category
ORDER BY total_profit DESC;
sql
-- Loss-making orders and how heavily they were discounted
SELECT
    COUNT(*)              AS loss_making_rows,
    ROUND(AVG(Discount), 3) AS avg_discount,
    ROUND(SUM(Profit), 2) AS total_loss
FROM Orders_data
WHERE Profit < 0;
sql
-- Rank sub-categories by profit within each category
SELECT
    Category,
    [Sub-Category],
    ROUND(SUM(Profit), 2) AS total_profit,
    RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS profit_rank
FROM Orders_data
GROUP BY Category, [Sub-Category];
sql
-- Monthly sales and profit trend
SELECT
    FORMAT(CAST([Order Date] AS DATE), 'yyyy-MM') AS order_month,
    ROUND(SUM(Sales), 2)  AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM Orders_data
GROUP BY FORMAT(CAST([Order Date] AS DATE), 'yyyy-MM')
ORDER BY order_month;

Replace or extend these with the exact queries you ran.**

4️⃣ Power BI Dashboard

A 5-page interactive report built on the cleaned data, with a dedicated Date table and DAX measures.

Page	Purpose	Highlights
**📊 Executive Overview	Are we profitable and improving?**	KPI cards, Sales vs last-year KPI, monthly trend with Anomaly Detection, Smart Narrative
**💰 Profitability Deep-Dive	Which products make or lose money, and why?**	Profit by sub-category, Discount vs Profit scatter, Key Influencers on loss-making orders, best/worst category cards
**🌍 Regional & Category Performance	Where are we strong or weak?	**Filled map (profit, red-to-green scale), Decomposition Tree with AI splits, best/worst region cards
**👥 Customer & Segment Insights	Who are our best customers?**	Segment × Category profit matrix, Region × Segment sales matrix, Avg Order Value, top segment
**📦 Returns & Risk	What drives returns?**	Return rate (by orders and by sales), profit lost to returns, Key Influencers on returns

**Example DAX measures**

**dax
Profit Margin % = DIVIDE([Total Profit], [Total Sales], 0)

Avg Order Value = DIVIDE([Total Sales], [Total Orders], 0)

Return Rate % =
DIVIDE(
    CALCULATE(COUNTROWS(Orders), Orders[Returned] = "Yes"),
    COUNTROWS(Orders), 0
)

Loss Making Orders =
CALCULATE(COUNTROWS(Orders), Orders[Profit] < 0)

Best Region by Profit =
VAR RegionProfit = SUMMARIZE(Orders, Orders[Region], "P", [Total Profit])
VAR TopRegion = TOPN(1, RegionProfit, [P], DESC)
RETURN MAXX(TopRegion, Orders[Region])**



💡 Key Insights

(Verify each number against your final dashboard before publishing, and delete anything you cannot support.)

💵 Overall profit margin is about 12.5%, meaning roughly 12 of every 100 sold ends up as profit.
🛍️ Technology is the most profitable category, while Furniture earns the least profit despite similar sales, since its margin is thin.
🏷️ Higher discounts go with lower profit (Discount–Profit correlation ≈ -0.22); heavily discounted orders are where most losses occur.
📉 Negative profit is concentrated in a few sub-categories [name yours, e.g. Tables, Bookcases], so the problem is specific products rather than whole categories.
📦 About 8% of orders are returned; [add whether return rate by sales value differs from by order count, and any factor Key Influencers flagged].
📅 [Add your monthly finding, e.g. "October was the most profitable month at $12,748 while July was the only loss-making month" if that matches your selected year filter.]
✅ Recommendations
Cap discounts on the loss-making sub-categories, or review their pricing.
Investigate the worst-performing region and sub-category combinations shown in the Decomposition Tree.
Track return rate against a target (e.g. 5%) and monitor it monthly.

🖼 Dashboard Preview
Overview	
  <img width="605" height="340" alt="image" src="https://github.com/user-attachments/assets/29f3157e-c5c6-4309-bca4-aefb37f494d6" />

Profitability
<img width="608" height="347" alt="image" src="https://github.com/user-attachments/assets/437b9140-5381-4d36-acb6-18d8c0983bea" />

Regional	
<img width="609" height="344" alt="image" src="https://github.com/user-attachments/assets/fbb91a60-2255-4875-8e05-ff9e20ee7224" />

Customers
<img width="605" height="344" alt="image" src="https://github.com/user-attachments/assets/8261abbc-d16f-4438-b318-6872a5eb617b" />

Returns
<img width="612" height="347" alt="image" src="https://github.com/user-attachments/assets/d1f1756a-6d0d-4e5a-83c9-b3356feca600" />

🎯 Skills Demonstrated
Python: Pandas, NumPy, data cleaning, outlier handling, multi-table merge, EDA with Matplotlib/Seaborn
SQL: aggregation, GROUP BY, filtering, window functions (RANK), loading data through SQLAlchemy
Power BI: data modelling, Date table, DAX measures, KPI visuals, Key Influencers, Decomposition Tree, Smart Narrative, Anomaly Detection, conditional formatting
Analytical thinking: turning business questions into metrics, investigating outliers instead of deleting them, documenting decisions
👤 Author

Sakshi Dhobale 📧 dhobalesakshi5102@gmai.com 🔗 LinkedIn | GitHub

⭐ If you found this project useful, consider giving the repo a star.

