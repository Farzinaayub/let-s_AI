select * from customers;
select CustomerID,concat(Firstname,' ',Lastname) as Fullname, PostalCode
 from customers;
 
select count(distinct o.orderid ) as cnt from orders o
join customers c
on c.customerid=o.customerid
group by customerid;

SELECT 
    CONCAT(
        FirstName, ' ', 
        IFNULL(LastName, 'web'), 
        ' was born on ', 
        DAY(date_of_birth), 'th ',
        MONTHNAME(date_of_birth), ' ',
        YEAR(date_of_birth), 
        ' and has ordered ',
        (SELECT COUNT(DISTINCT orderid) FROM orders o WHERE o.customerid = c.customerid),
        ' orders yet.'
    ) AS description, 
    customerid,
    RIGHT(email, LENGTH(email) - POSITION('@' IN email)) AS domain 
FROM 
    customers c
ORDER BY 
    DateEntered desc,customerid asc;

select * from customers;
select * from category;
select * from orderdetails;
select * from orders;
select * from payments;
select * from products;
select * from shippers;
select * from suppliers;
with cte1 as(
select customerid,year(date_of_birth) as birthyear,
	case
		when year(date_of_birth)<=1980 then 'GenX'
		when year(date_of_birth) between 1981 and 1996 then 'Millenials'
		else 'GenZ'
		end as Generation
from customers)
select cte1.generation,sum(quantity*(pd.market_price-pd.sale_price)) as discount
from cte1
join orders o
on cte1.customerid=o.customerid
join orderdetails od
on o.orderid=od.orderid
join products pd
on od.productid=pd.productid
group by cte1.generation
order by cte1.generation;


create view weekendorders as 
select * ,dayname(orderdate) as weekday_oforder
from orders
where dayname(OrderDate) in ('saturday','sunday');


select * from weekendorders;


alter view weekendorders as 
select * ,dayname(orderdate) as weekday_oforder
from orders
where dayname(OrderDate) in ('saturday','sunday') and Total_order_amount>20000;

 rename table weekendorders
 to newview;
 select * from newview;
 drop view newview;


#window funcitions

select *,count(*) over (partition by country) as count
from customers;

select *,count(*) over (partition by customerid) as no_of_orders
from orders;

select customerid,orderdate,count(*) as orders_on_firstday from(
select * from(
select *,min(orderdate) over (partition by customerid) as firstorder
from orders) as c
where orderdate=firstorder) as f
group by customerid,orderdate
order by 3 desc;

#rank functions

select *, 
rank() over (partition by customerid order by total_order_amount desc) as ranking
from orders;

select *, 
rank() over (partition by customerid order by total_order_amount) as ranking
from orders;
select * from(
select *, 
rank() over (partition by customerid order by total_order_amount desc) as ranking
from orders) as c
where ranking=1;

#rank() v/s dense rank()
# value rank()  Dense rank()
#   10    1       1
#   10    1       1
#   20    3       2

select *, 
dense_rank() over (order by total_order_amount desc) as ranking
from orders;
#row_number() --> sl n.o

# NTILE
select * , NTILE(2) over (order by Marks desc) as bucket
from students;

select *,lag(sales,1,0) over(order by year,quarter) as prevsales,
lead(sales,1,0) over(order by year,quarter) as nxtsales
from yearsales;

select * from sales;

select monthname(month_) as Month, sales,sum(sales) over(order by month_) as cum_sum,avg(sales) over(order by month_) as cum_avg
from sales;


select monthname(month_) as Month, sales,
sum(sales) over(order by month_ rows between 2 preceding and current row) as '3_month_rolling_sum',
avg(sales) over(order by month_ rows 2 preceding) as '3_month_rolling_avg',
avg(sales) over(order by month_ rows between current row and 3 following) as '3_month_rolling_future_avg'
from sales;

# reverse cumulative sum

select * from sales;

select Monthname(month_) as Month,Sales,
count(sales) over (order by month(month) rows between current row and unbounded following) as cnt,
sum(sales) over (order by month(month) rows between current row and unbounded following) as rev_cum_sales
from sales
order by month(Month);

select * from students;
with cte1 as (
select *,rank() over(order by marks desc) as ranking,
dense_rank() over(partition by class order by marks desc) as dense_ranking
from students)
select row_number() over(order by name) as slno,cte1.* from cte1 where dense_ranking<3;
  

WITH CTE1 AS(
	SELECT O.ORDERID,O.CUSTOMERID,
    CASE 
		WHEN DATEDIFF(O.SHIPDATE,O.ORDERDATE)<=3 THEN 'LTE3'
        WHEN DATEDIFF(O.SHIPDATE,O.ORDERDATE)<=5 THEN 'LTE5'
        WHEN DATEDIFF(O.SHIPDATE,O.ORDERDATE)<=7 THEN 'LTE7'
        WHEN DATEDIFF(O.SHIPDATE,O.ORDERDATE)>7 THEN 'GT7' 
        END
	AS LATETAG
    FROM ORDERS O
    JOIN CUSTOMERS C ON O.CUSTOMERID=C.CUSTOMERID)
SELECT S.COUNTRY AS SUP_COUNTRY,C.COUNTRY AS CUST_COUNTRY,
	COUNT(DISTINCT CASE WHEN LATETAG='LTE3' THEN CTE1.ORDERID END) AS LTE3,
    COUNT(DISTINCT CASE WHEN LATETAG='LTE5' THEN CTE1.ORDERID END) AS LTE5,
    COUNT(DISTINCT CASE WHEN LATETAG='LTE7' THEN CTE1.ORDERID END) AS LTE7,
    COUNT(DISTINCT CASE WHEN LATETAG='GT7' THEN CTE1.ORDERID END) AS GT7
FROM CTE1
JOIN CUSTOMERS C ON C.CUSTOMERID=CTE1.CUSTOMERID
JOIN ORDERDETAILS OD ON OD.ORDERID=CTE1.ORDERID
JOIN SUPPLIERS S ON S.SUPPLIERID=OD.SUPPLIERID
GROUP BY S.COUNTRY,C.COUNTRY
ORDER BY GT7 DESC,LTE7 DESC,LTE5 DESC,LTE3 DESC;
        


