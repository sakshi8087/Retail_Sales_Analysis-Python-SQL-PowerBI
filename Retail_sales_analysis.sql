SELECT top 5 * from dbo.['sample_-_superstore$']

select * from People$;

select * from Returns$;


--1what is the total sales and profit by category 

select category, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit
from ['sample_-_superstore$']
group by category;

--2.Which sub-category is generating most loss?

select [sub-category],
       sum(profit) as Total_profit
from ['sample_-_superstore$']
group by [sub-category]
order by Total_profit;

--3.What is the sales and profit performance by region?

select region, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit
from ['sample_-_superstore$']
group by region
order by total_profit DESC;
       
--4.what does the month-wise sales trend look like?
select month([order date]) as mn,
       year([order date]) as yr,
       sum(sales) as total_sales
from ['sample_-_superstore$']
group by month([order date]),
       year([order date])
order by mn,yr DESC;

-- 5. What are the top 10 best-selling products?

select top 10 [product id],
              [product name],
              sum(quantity) as total_quantity,
              sum(sales) as total_sales
from ['sample_-_superstore$']
group by [product id],[product name]
order by total_sales DESC;

-- 6. What are the top 10 products causing the most loss?
select top 10 [product id],
              [product name],
              sum(quantity) as total_quantity,
              sum(sales) as total_sales
from ['sample_-_superstore$']
group by [product id],[product name]
order by total_sales ASC;

-- 7. What is the relationship between discount and profit?

select category,
       avg(discount) as avg_discount,
       avg(profit) as avg_profit,
       sum(profit) as total_profit
from ['sample_-_superstore$']
group by category
order by avg_discount DESC;

-- 8. Which customers are the most valuable (top spenders)?
select top 10 [customer id],
              [customer name],
              sum(sales) as total_sales,
              sum(profit) as total_profit
from ['sample_-_superstore$']
group by [customer id],
              [customer name]
order by total_sales DESC;


-- 9. What is the average shipping/delivery time?

select [ship mode],
       avg(datediff(day,[order date],[ship date])) as avg_shipping_days
from ['sample_-_superstore$']
group by [ship mode]
order by avg_shipping_days ASC;

-- 10. What percentage of total orders result in a loss?

select 
       count(case when profit < 0 then 1 end) as loss_orders,
       count(*) as total_orders,
       cast(count(case when profit < 0 then 1 end) as float) * 100 / count(*)  as loss_per
from ['sample_-_superstore$'];

-- 11. Bonus: What is the month-over-month sales growth %?

with monthly_sales as (select month([order date]) as mn,
       year([order date]) as yr,
       sum(sales) as total_sales
from ['sample_-_superstore$']
group by month([order date]),
       year([order date])
)

       select *, 
             lag(total_sales) over(order by mn) as prev_month_sales,
             cast((total_sales - lag(total_sales) over (order by yr, mn)) as float)
             / lag(total_sales) over (order by yr,mn) * 100 as growth_per
from monthly_sales




-- 12. Bonus: How does ship mode affect sales/profit?

select [ship mode],
       count(*) as total_orders,
       sum(sales) as total_sales,
       sum(profit) as total_profit,
       avg(profit) as avg_profit
from ['sample_-_superstore$']
group by [ship mode]
order by total_sales DESC;