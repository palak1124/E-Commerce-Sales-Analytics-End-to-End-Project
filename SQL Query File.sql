--EASY (1–15)

--Revenue & Orders

--1. What is the total revenue?

select 
round(
sum(LineSalesAmount),0)
from `dataset.order_details`;

--2. What is net revenue recieved?
select 
round(sum(LineSalesAmount) -sum(DiscountedAmount),0)
from `dataset.order_details`;

-- 3. Total number of orders
select count(distinct orderID) from `dataset.order_details`;

--4. Total quantity sold
select sum(Quantity) from `dataset.order_details`;

--5. Average order value (AOV)
select round(sum(LineSalesAmount)/count(orderID),2) from `dataset.order_details`;

--6. Revenue by year

select EXTRACT(YEAR FROM o.orderdate) AS year,
round(
sum(d.LineSalesAmount),0) 
from `dataset.order_details` as d
join `dataset.orders` as o on d.orderID = o.orderID
group by year
order by year asc;

-- 7. Revenue by month


SELECT 
  EXTRACT(MONTH FROM o.OrderDate) AS mon_num,
  FORMAT_TIMESTAMP('%b', o.OrderDate) AS month,
  ROUND(SUM(d.LineSalesAmount), 0) AS revenue
FROM `dataset.order_details` AS d
JOIN `dataset.orders` AS o ON d.orderID = o.orderID
GROUP BY mon_num, month
ORDER BY mon_num ASC;

--8. Orders by month

select EXTRACT(month FROM o.orderdate) AS month,
count(distinct d.orderID)
from `dataset.order_details` as d
join `dataset.orders` as o on d.orderID = o.orderID
group by month
order by month asc;

-- 9. Revenue by country

select c.Country,
round(
sum(LineSalesAmount),0) as revenue
from `dataset.order_details` as d join `dataset.orders` as o 
on d.OrderID = o.OrderID
join `dataset.customers` as c on o.CustomerID = c.CustomerID
group by c.Country
order by revenue desc; 

-- 10. Revenue by category

select ca.CategoryName,
round(
sum(LineSalesAmount),0) as revenue
from `dataset.order_details` as d join `dataset.products` as p
on d.ProductID = p.ProductID
join `dataset.categories`as ca
on p.CategoryID = ca.CategoryID
group by ca.CategoryName;

--11. Total Customer Count
select count(distinct customerID)
from `dataset.orders` ;

--12. Top 10 customers by revenue
select  o.customerID,round(sum(d.LineSalesAmount),0) as revenue
from `dataset.orders` as o
join `dataset.order_details`  as d
on o.OrderID = d.OrderID
group by o.customerID 
order by revenue desc
limit 10;

--13. Average revenue per customer
select  o.customerID,round(avg(d.LineSalesAmount),0) as avg_revenue
from `dataset.orders` as o
join `dataset.order_details`  as d
on o.OrderID = d.OrderID
group by o.customerID 
order by avg_revenue desc;

--14. Customers with zero orders

select c.customerID,count(distinct d.OrderID) as orders from `dataset.customers` as c
left join `dataset.orders` as o 
on c.customerID = o.customerID
left join `dataset.order_details` as d
on o.orderID = d.orderID
group by c.CustomerID
having count(distinct d.OrderID) = 0 ;

-- 15. Repeat vs one-time customers count

with customer_orders as (select c.customerID, count(distinct d.OrderID) as order_count
from `dataset.customers` as c
inner join `dataset.orders` as o 
on c.customerID = o.customerID
inner join `dataset.order_details` as d
on o.orderID = d.orderID
group by c.CustomerID)

select
case when customer_orders.order_count = 1 Then "One Time Customer" else "Repeat Customer"
end as customer_type,
count(*) as customers
from customer_orders
group by customer_type;

-- 16. Order by Customers
select c.customerID, count(distinct d.OrderID) as order_count
from `dataset.customers` as c
inner join `dataset.orders` as o 
on c.customerID = o.customerID
inner join `dataset.order_details` as d
on o.orderID = d.orderID
group by c.CustomerID
order by order_count;

-- MEDIUM (16–35) → Analytical thinking + joins + window functions

--- Growth Analysis

--17. Year-over-Year (YoY) revenue growth

with yearly_data as (
select EXTRACT(YEAR FROM o.orderdate) AS year,
  round(sum(d.LineSalesAmount),0) as current_revenue
  from `dataset.order_details` as d
  join `dataset.orders` as o on d.orderID = o.orderID
  group by year)
  
  select year, current_revenue,
  round(lag(current_revenue) over (order by year),0) as pre_revenue, 
  round(
    (current_revenue - lag(current_revenue) over (order by year))/
    lag(current_revenue) over (order by year),2
  ) as yoy_growth
  from yearly_data
  order by year;

  -- 18. Month-over-Month (MoM) growth

  with monthly_data as (
select
Extract (month from o.OrderDate) as mon_num,
  round(sum(d.LineSalesAmount),0) as current_revenue
  from `dataset.order_details` as d
  join `dataset.orders` as o on d.orderID = o.orderID
  group by mon_num)
  
  select mon_num, current_revenue,
  round(lag(current_revenue) over (order by mon_num),0) as pre_revenue, 
  round(
    (current_revenue - lag(current_revenue) over (order by mon_num))/
    lag(current_revenue) over (order by mon_num),2)*100 as yoy_growth
  from monthly_data
  order by mon_num;

  -- 19. YoY growth in total orders

with yearly_data as (
select EXTRACT(YEAR FROM o.orderdate) AS year,
  count(distinct d.OrderID) as current_orders
  from `dataset.order_details` as d
  join `dataset.orders` as o on d.orderID = o.orderID
  group by year)
  
  select year, current_orders,
  round(lag(current_orders) over (order by year),0) as pre_orders, 
  round(
    (current_orders - lag(current_orders) over (order by year))/
    lag(current_orders) over (order by year),2
  ) as yoy_growth
  from yearly_data
  order by year;

--20. YoY growth in AOV

with yearly_data as (
select EXTRACT(YEAR FROM o.orderdate) AS year,
  round(sum(d.LineSalesAmount)/count(d.orderID),2) as current_Aov
  from `dataset.order_details` as d
  join `dataset.orders` as o on d.orderID = o.orderID
  group by year)
  
  select year, current_Aov,
  round(lag(current_Aov) over (order by year),0) as pre_Aov, 
  round(
    (current_Aov - lag(current_Aov) over (order by year))/
    lag(current_Aov) over (order by year),2
  ) as yoy_growth
  from yearly_data
  order by year;

--  Profitability Analysis

  --21. Gross margin per order
  select OrderID, 
  round(sum(LineSalesAmount),2),
  round(sum(Margin),2),
  round(sum(Margin)/sum(LineSalesAmount),2)*100 as margin_pct
  from `dataset.order_details`
  group by OrderID
  order by margin_pct;

--22. Gross margin % by category
select c.CategoryName, 
  round(sum(LineSalesAmount),2),
  round(sum(Margin),2),
  round(sum(Margin)/sum(LineSalesAmount),2)*100 as margin_pct
  from `dataset.order_details` as d
  join `dataset.products` as p
  on d.ProductID = p.ProductID
  join `dataset.categories` as c
   on p.CategoryID = c.CategoryID
  group by c.CategoryName
  order by margin_pct;

  --23. Profit by country
  select c.Country, 
  round(sum(LineSalesAmount),2),
  round(sum(d.Margin),2),
  round(sum(d.Margin)/sum(d.LineSalesAmount),2)*100 as margin_pct,
  ROUND(SUM(d.Margin) * 100 / SUM(SUM(d.Margin)) OVER(), 2) as profit_contri
  from `dataset.order_details` as d
  join `dataset.orders` as o
  on d.OrderID = o.OrderID
  join `dataset.customers` as c
  on o.CustomerID = c.CustomerID
  group by c.Country;

-- 24 Top 10 most profitable products
SELECT 
  p.ProductName, 
  ROUND(SUM(d.LineSalesAmount), 2) AS sales,
  ROUND(SUM(d.Margin), 2) AS margin,
  ROUND(SUM(d.Margin) / SUM(d.LineSalesAmount), 2) * 100 AS margin_pct
FROM `dataset.order_details` AS d
JOIN `dataset.products` AS p ON d.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY margin DESC
LIMIT 10;

  --Bottom 10 loss-making products

  select p.ProductName, 
  round(sum(d.LineSalesAmount),2) as sales,
  round(sum(d.Margin),2) as margin,
  round(sum(d.Margin)/sum(d.LineSalesAmount),2)*100 as margin_pct
  from `dataset.order_details` as d
  join `dataset.products` as p
  on d.ProductID = p.ProductID
  group by p.ProductName
  having sum(d.Margin) < 0;

-- 26. % of orders with negative margin

select round(countif(order_margin <0)*100/count(*),2)
from(
select orderID, sum(Margin) as order_margin
from `dataset.order_details`
group by orderID
order by order_margin);

-- DISCOUNT

--27. Total discount amount

select sum(DiscountedAmount)
from `dataset.order_details`;

-- 28. Discount % per order

SELECT  orderID,
Sum(DiscountedAmount),
Sum(Quantity*UnitPrice) as sales,
round(Sum(DiscountedAmount)*100/Sum(Quantity*UnitPrice),2) as pct
from `dataset.order_details`
group by orderID;

--29 Avg discount by category
select c.CategoryName as Category,
round(avg(d.DiscountedAmount),2)
from `dataset.order_details` as d
inner join `dataset.products` as p
on d.ProductID = p.ProductID
inner join `dataset.categories` as c
on p.CategoryID = c.CategoryID
group by Category;

--30. High discount orders (>20%)

SELECT  orderID,
Sum(DiscountedAmount),
Sum(Quantity*UnitPrice) as sales,
round(Sum(DiscountedAmount)*100/Sum(Quantity*UnitPrice),2) as pct
from `dataset.order_details`
group by orderID
having pct >20
order by pct desc;


-- 31 Correlation: discount vs profit
with order_level as (
  select orderID,
  avg(DiscountedAmount) as avg_dis,
  sum(Margin),
  sum(Margin)/SUM(LineSalesAmount) as margin_pct
  from `dataset.order_details`
  group by OrderID
)
select corr(avg_dis,margin_pct) as correlation_discount_profit
from order_level;

-- PRODUCTS & CATEGORIES

--32 Top 5 categories contributing revenue

select c.CategoryName as Category,
round(sum(LineSalesAmount),2) as revenue
from `dataset.order_details` as d
inner join `dataset.products` as p
on d.ProductID = p.ProductID
inner join `dataset.categories` as c
on p.CategoryID = c.CategoryID
group by Category
order by revenue desc
limit 5;

-- 33. Category-wise order count

select c.CategoryName as Category,
count(distinct orderID) as orders
from `dataset.order_details` as d
inner join `dataset.products` as p
on d.ProductID = p.ProductID
inner join `dataset.categories` as c
on p.CategoryID = c.CategoryID
group by Category
order by orders desc;

-- 34. Product with highest sales volume

select p.ProductName as Product,
Sum(d.Quantity) as Sales
from `dataset.order_details` as d
inner join `dataset.products` as p
on d.ProductID = p.ProductID
group by Product
order by Sales Desc
limit 15;

-- 35. Slow-moving products (low sales)

select p.ProductName as Product,
Sum(d.Quantity) as Sales
from `dataset.order_details` as d
inner join `dataset.products` as p
on d.ProductID = p.ProductID
group by Product
order by Sales 
limit 15;

--36. Revenue contribution % per product
select p.ProductName as product,
round(Sum(LineSalesAmount),2) as revenue,
round(Sum(LineSalesAmount)*100/sum(sum(LineSalesAmount)) OVER (),2) as revenue_share
from `dataset.order_details` as d
inner join `dataset.products` as p
on d.ProductID = p.ProductID
group by product
order by revenue_share desc;

-- HARD (37–55) → Advanced

--37.Identify loss-making transactions and their patterns

-- A Loss Making Transactions 

SELECT
  COUNT(*) AS total_transactions,
  COUNTIF(Margin < 0) AS loss_transactions,
  ROUND(COUNTIF(Margin < 0) * 100 / COUNT(*), 2) AS loss_pct
FROM `dataset.order_details`;

-- B. Transaction level Product Details
SELECT
  d.ProductID,
  p.ProductName,
  d.orderID,
  d.Margin
FROM `dataset.order_details` d
JOIN `dataset.products` p
  ON d.ProductID = p.ProductID
WHERE d.Margin < 0
ORDER BY d.Margin;

-- C. What is the main reason of Loss?
SELECT
  CASE
    WHEN DiscountedAmount / NULLIF(Quantity * UnitPrice, 0) <= 0.10 THEN '0-10%'
    WHEN DiscountedAmount / NULLIF(Quantity * UnitPrice, 0) <= 0.20 THEN '10-20%'
    WHEN DiscountedAmount / NULLIF(Quantity * UnitPrice, 0) <= 0.30 THEN '20-30%'
    ELSE '30%+'
  END AS discount_bucket,
  COUNT(*) AS total,
  COUNTIF(Margin < 0) AS loss_orders,
  ROUND(COUNTIF(Margin < 0) * 100 / COUNT(*), 2) AS pct
FROM `dataset.order_details`
GROUP BY discount_bucket
ORDER BY discount_bucket;


-- Which Products are loosing? 
SELECT
  p.ProductName,
  COUNTIF(d.Margin < 0) AS loss_transactions,
  COUNT(*) AS total_transactions,
  ROUND(COUNTIF(d.Margin < 0) * 100 / COUNT(*), 2) AS loss_pct
FROM `dataset.order_details` d
JOIN `dataset.products` p
  ON d.ProductID = p.ProductID
GROUP BY p.ProductName
HAVING loss_transactions > 0
ORDER BY loss_pct DESC;

-- 38. At what discount % margin becomes negative?
select
case
when DiscountedAmount <= 0.05 then '0-5%'
when DiscountedAmount <= 0.10 then '5-10%'
when DiscountedAmount <= 0.15  then '10-15%'
when DiscountedAmount <= 0.20 then '15-20%'
when DiscountedAmount <= 0.25 then '20-25%'
when DiscountedAmount <= 0.30 then '25-30%'
when DiscountedAmount <= 0.35 then '30-35%'
else '35%+'
end as discount_bucket,
count(*) as total_transactions,
round(avg(Margin/LineSalesAmount)*100,2) as avg_margin_pct,
countif(margin<0) as loss_orders,
round(countif(margin<0)*100/count(*),2) as loss_pct
from `dataset.order_details`
group by  discount_bucket
order by discount_bucket;

-- 39. Pareto analysis (top 20% products contributing % revenue)

with product_sales as (
  select p.ProductName,
  round(sum(d.LineSalesAmount),2) as revenue
  From `dataset.order_details` as d
  join `dataset.products` as p
  on d.ProductID = p.ProductID
  group by p.ProductName
),

ranked as(
  select *,
  sum(revenue) over() as total_revenue,
  sum(revenue) over (order by revenue desc) as cumulative_revenue
  from product_sales
)
select *,
round(cumulative_revenue*100/total_revenue,2) as cumulative_pct
from ranked
where cumulative_revenue*100/total_revenue <=80
order by cumulative_pct;

-- 40. Customer concentration (top 5 customers % contribution)

WITH customer_sales AS (
  SELECT 
    c.CompanyName,
    ROUND(SUM(d.LineSalesAmount), 2) AS revenue
  FROM `dataset.order_details` AS d
  JOIN `dataset.orders` AS o
    ON d.OrderID = o.OrderID
  JOIN `dataset.customers` AS c
    ON o.CustomerID = c.CustomerID
  GROUP BY c.CompanyName
),

ranked AS (
  SELECT 
    CompanyName,
    revenue,
    SUM(revenue) OVER() AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn
  FROM customer_sales
)

SELECT 
  ROUND(SUM(revenue) * 100 / MAX(total_revenue), 2) AS top5_customer_pct
FROM ranked
WHERE rn <= 5;

-- 41. Customer Lifetime Value (CLV)

select
c.CustomerID,
c.CompanyName,
round(sum(LineSalesAmount),2) as lifetime_revenue
from `dataset.order_details`  as d
join `dataset.orders` as o
on d.orderID = o.orderID
join `dataset.customers` as c
on o.CustomerID = c.CustomerID
group by c.CustomerID, C.CompanyName
order by lifetime_revenue desc;

-- 42. Customer Segmentation (High / Medium / Low)
with clv as(
select
c.CompanyName,
round(sum(LineSalesAmount),2) as revenue
from `dataset.order_details`  as d
join `dataset.orders` as o
on d.orderID = o.orderID
join `dataset.customers` as c
on o.CustomerID = c.CustomerID
group by c.CompanyName
order by revenue desc 
)

select *,
case 
when revenue > 100000 then 'High'
when revenue >50000 then 'Medium'
else 'low'
end as segment
from  clv;

-- 43. Retention Rate

with customer_orders as(
select c.CustomerID,
count(distinct o.orderID) AS orders
from `dataset.orders` o
join `dataset.customers` c
on o.CustomerID = c.CustomerID
group by c.CustomerID )

select 
round(countif(orders>1)*100/count(*),1) as retention_rate
from customer_orders;

--44. First vs Last Purchase Gap by Customer

select c.CustomerID,
date_diff(max(o.orderDate), min(o.orderDate), day) as active_days
from `dataset.order_details` as d
join `dataset.orders` as o
on d.orderID = o.orderID
join `dataset.customers` as c
on o.CustomerID = c.CustomerID
group by c.CustomerID;

--45.  Cohort Analysis (monthly)
WITH first_purchase AS (
  SELECT 
    o.CustomerID,
    FORMAT_TIMESTAMP('%Y-%m', MIN(o.OrderDate)) AS cohort_month
  FROM `dataset.orders` AS o
  GROUP BY o.CustomerID
),

customer_activity AS (
  SELECT 
    o.CustomerID,
    FORMAT_TIMESTAMP('%Y-%m', o.OrderDate) AS order_month
  FROM `dataset.orders` AS o
),

joined AS (
  SELECT 
    f.cohort_month,
    c.order_month,
    COUNT(DISTINCT c.CustomerID) AS customers
  FROM first_purchase AS f
  JOIN customer_activity AS c ON f.CustomerID = c.CustomerID
  GROUP BY f.cohort_month, c.order_month
)

SELECT 
  cohort_month,
  order_month,
  customers
FROM joined
ORDER BY cohort_month, order_month;

--46.Avg Delivery Time per Shipper

with order_data as(
select o.OrderID, 
s.ShipperID,
p.CompanyName as shipper,
Date_diff(max(s.shipmentDate),min(o.OrderDate),DAY) as days
from `dataset.orders` o
join `dataset.shipments` as s
on o.OrderID = s.OrderID
join `dataset.shippers` as p
on s.shipperID = p.ShipperID
group by o.OrderID, s.ShipperID,p.CompanyName
)
select shipper, round(avg(days),0) as days
from order_data
group by shipper;

--47. On-time vs Delayed %

select case 
when Date_diff(s.shipmentDate,o.OrderDate,DAY) <=20 then 'On Time'
else 'Delayed'
end as status, 
count(*) as orders,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
from `dataset.orders` as o
join `dataset.shipments`as s
on o.OrderID = s.orderID
group by status
order by orders desc;


-- 48. Freight Cost per Order

SELECT
  round(AVG(Freight),2) AS avg_freight_per_order
FROM `dataset.orders`;

--49. Shipper Performance Ranking

WITH order_data AS (
  SELECT 
    o.OrderID, 
    p.CompanyName AS shipper,
    DATE_DIFF(s.shipmentDate, o.OrderDate, DAY) AS days
  FROM `dataset.orders` o
  JOIN `dataset.shipments` s
    ON o.OrderID = s.OrderID
  JOIN `dataset.shippers` p
    ON s.shipperID = p.ShipperID
)

SELECT 
  shipper, 
  ROUND(AVG(days), 2) AS avg_delivery_days,
  RANK() OVER (ORDER BY AVG(days)) AS rank
FROM order_data
GROUP BY shipper
ORDER BY rank;

--50. . Delivery Delay vs Repeat Orders

WITH delivery AS (
  SELECT
    c.customerID,
    CASE 
      WHEN DATE_DIFF(s.ShipmentDate, o.OrderDate, day) <= 20 THEN 'On Time'
      ELSE 'Delayed'
    END AS delivery_status
  FROM `dataset.orders` o
  join `dataset.customers` c 
  on o.customerID = c.customerID
  join `dataset.shipments` s
  on o.orderID = s.OrderID

),

cust_orders AS (
  SELECT
    customerID,
    COUNT(*) AS total_orders
  FROM `dataset.orders`
  GROUP BY customerID
)

SELECT
  d.delivery_status,
  round(AVG(c.total_orders),2) AS avg_orders
FROM delivery d
JOIN cust_orders c USING(customerID)
GROUP BY d.delivery_status;
