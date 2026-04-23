# E-Commerce-Sales-Analytics-End-to-End-Project

## Project Overview

This is an end-to-end SQL analytics project built on a custom **E-Commerce dataset (13 tables)** using **Google BigQuery**.  
The goal was to analyze business performance across revenue, profitability, customer behavior, product trends, and logistics — mimicking real-world Data Analyst work.

##  Dataset

| Detail | Info |
|--------|------|
| Source | Custom E-Commerce Dataset |
| Tables | 13 (orders, order_details, customers, products, categories, shippers, shipments, and more) |
| Tool | Google BigQuery |
| Type | Transactional Sales Data |

---

## Analysis Areas & Key Questions Answered

### Revenue & Orders
- Total revenue, net revenue, AOV
- Revenue breakdown by year, month, country, category
- YoY & MoM revenue and order growth

### Profitability
- Gross margin per order, by category, by country
- Top 10 most profitable products
- Bottom 10 loss-making products
- % of orders with negative margin

### Discount Analysis
- Total discount given
- Discount % per order and by category
- At what discount % does margin turn negative?
- Correlation between discount and profit (CORR function)

### Customer Analytics
- Total customers, repeat vs one-time customers
- Customer Lifetime Value (CLV)
- Customer Segmentation — High / Medium / Low
- Retention Rate
- RFM Analysis (Recency, Frequency, Monetary)
- Cohort Analysis (Monthly)
- Customer concentration (top 5 customers % contribution)

### Product & Category
- Top & bottom products by sales volume
- Revenue contribution % per product
- Pareto Analysis — top 20% products driving 80% revenue
- Category-wise revenue and order count

### Logistics & Delivery
- Average delivery time per shipper
- On-time vs Delayed % with window functions
- Shipper performance ranking
- Freight cost per order
- Impact of delivery delays on repeat orders

---

## SQL Concepts Used

| Concept | Used In |
|---------|---------|
| CTEs (`WITH` clause) | Growth analysis, RFM, Cohort, Pareto |
| Window Functions | `LAG()`, `RANK()`, `SUM OVER()`, `ROW_NUMBER()` |
| `CASE WHEN` | Customer segmentation, RFM buckets, delivery status |
| `COUNTIF` | Loss transactions, retention rate |
| `CORR()` | Discount vs profit correlation |
| `DATE_DIFF` | Delivery days, customer active days |
| `NULLIF` | Safe division to avoid divide-by-zero |
| Multi-table JOINs | Most queries (up to 4 tables) |
| Subqueries | Negative margin %, max date for RFM |
| `HAVING` | Filtering aggregated results |

---

## Files in This Repository

| File | Description |
|------|-------------|
| `End_to_end_project.sql` | All 50+ SQL queries with comments |
| `README.md` | Project documentation |

> 🔜 **Coming Soon:** Power BI Dashboard on the same dataset


*If you found this project helpful, feel free to ⭐ star the repo!*
