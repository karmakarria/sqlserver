use ria ;
select * from myorder_date;


create temporary table myorder(
select *,concat(right(purchase_date,4),"-",mid(purchase_date,4,2),"-",left(purchase_date,2)) as purchase_date_new
from myorder_date);

alter table myorder
modify purchase_date_new date;

alter table myorder
drop purchase_date;

describe myorder;
select * from myorder;


/Top 3 months with largest sales amount with the amount itself*\

SELECT 
    MONTHNAME(purchase_date_new) AS month_name,
    sum(Final_Price) as largest_sales
    from myorder
    group by month_name
    order by largest_sales desc limit 3;
    
    Top 3 months where discount amount is highest with the total discount and average discount\
    
    select
        MONTHNAME(purchase_date_new) AS month_name,
        sum(Price-Final_Price) as total_discount,
        avg(Price-Final_Price)as avg_discount
        from myorder
        group by month_name
        order by total_discount,avg_discount desc
        limit 3;
        
        / Month on month trend on count of product for different payment methods sorted by highest to lowest/
        
        WITH cte AS (
    SELECT 
        MONTHNAME(purchase_date_new) AS month_name,
        Payment_Method,
        COUNT(*) AS transaction_
    FROM myorder
        
    GROUP BY 
        month_name, Payment_Method
)
SELECT 
    Payment_Method,
    SUM(CASE WHEN month_name = 'January' THEN transaction_ ELSE 0 END) AS January,
    SUM(CASE WHEN month_name = 'February' THEN transaction_ ELSE 0 END) AS February,
    SUM(CASE WHEN month_name = 'March' THEN transaction_ ELSE 0 END) AS March,
    SUM(CASE WHEN month_name = 'April' THEN transaction_ ELSE 0 END) AS April,
    SUM(CASE WHEN month_name = 'May' THEN transaction_ ELSE 0 END) AS May,
    SUM(CASE WHEN month_name = 'June' THEN transaction_ ELSE 0 END) AS June,
    SUM(CASE WHEN month_name = 'July' THEN transaction_ ELSE 0 END) AS July,
    SUM(CASE WHEN month_name = 'August' THEN transaction_ ELSE 0 END) AS August,
    SUM(CASE WHEN month_name = 'September' THEN transaction_ ELSE 0 END) AS September,
    SUM(CASE WHEN month_name = 'October' THEN transaction_ ELSE 0 END) AS October,
    SUM(CASE WHEN month_name = 'November' THEN transaction_ ELSE 0 END) AS November,
    SUM(CASE WHEN month_name = 'December' THEN transaction_ ELSE 0 END) AS December
FROM 
    cte
GROUP BY 
    Payment_Method
    order by Payment_Method desc;
    
    Find the top category with highest avg final _price and its amount\

select category,avg(final_price) as avg_price
from myorder
group by category
order by avg_price desc 
limit 1;

-- Project common users from the purchase history in Jan and Feb--

 SELECT user_id
FROM myorder
WHERE MONTH(purchase_date_new) IN (1, 2)
GROUP BY user_id
HAVING COUNT(DISTINCT MONTH(purchase_date_new)) <= 2;


--Project 75%ile of historical final_price for every month--


with dummy as (
select monthname(purchase_date_new) as month_name,final_price,
percent_rank() over (partition by monthname(purchase_date_new) order by final_price desc) as ranking
from myorder)
select month_name,max(final_price) as'75%ile'
from dummy
where ranking>0.25
group by month_name;
