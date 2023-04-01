drop table if exists employee;
create table employee (
    emp_id     int,
	emp_name   varchar(20),
	salary     int
);

insert into employee values
(101, 'Mohan', 40000),
(102, 'James', 50000),
(103, 'Robin', 60000),
(104, 'Carol', 70000),
(105, 'Alice', 80000),
(106, 'Jimmy', 90000);

drop table if exists sales;
create table sales (
    store_id     int,
	store_name   varchar(20),
	product      varchar(20),
	quantity     int,
	cost         int
);

insert into sales values
(1, 'Apple Originals 1', 'iPhone 12 Pro', 1, 1000),
(1, 'Apple Originals 1', 'MacBook pro 13', 3, 2000),
(1, 'Apple Originals 1', 'AirPods Pro', 2, 280),
(2, 'Apple Originals 2', 'iPhone 12 Pro', 2, 1000),
(3, 'Apple Originals 3', 'iPhone 12 Pro', 1, 1000),
(3, 'Apple Originals 3', 'MacBook pro 13', 1, 2000),
(3, 'Apple Originals 3', 'MacBook Air', 4, 1100),
(3, 'Apple Originals 3', 'iPhone 12', 2, 1000),
(3, 'Apple Originals 3', 'AirPods Pro', 3, 280),
(4, 'Apple Originals 4', 'iPhone 12 Pro', 2, 1000),
(4, 'Apple Originals 4', 'MacBook pro 13', 1, 2500);


select * from employee;
select * from sales;

-- WITH clause can also be referred was CTE (Common Table Expression) / Sub-query factoring

-- Question 1:Fetch employees who earn more than average salary of all employees

with average_salary (avg_sal) as 
        (select avg(salary) from employee)
select * 
from employee e, average_salary av
where e.salary > av.avg_sal;


with average_salary (avg_sal) as 
        (select cast(avg(salary) as int) from employee)
select * 
from employee e, average_salary av
where e.salary > av.avg_sal;

-- Question 2: Find stores whose sales were better than the average sales across all stores

-- 1) find the total sales per each store - Total_Sales
-- 2) find the average of all the sales across all the stores - Avg_Sales
-- 3) Find the stores where Total_Sales > Avg_Sales of all stores.

-- 1)
select s.store_id, sum(cost) as total_sales_per_store
from sales s
group by s.store_id;

-- 2)
select cast(avg(total_sales_per_store) as int) as avg_sales_for_all_stores
from (
	select s.store_id, sum(cost) as total_sales_per_store
	from sales s
	group by s.store_id
) x;

-- 3)
-- Solve with subquery (use the same subquery multiple times)
select *
from (
	select s.store_id, sum(cost) as total_sales_per_store
	from sales s
	group by s.store_id) total_sales
join (select cast(avg(total_sales_per_store) as int) as avg_sales_for_all_stores
	  from ( select s.store_id, sum(cost) as total_sales_per_store
		     from sales s
		     group by s.store_id) x) avg_sales
    on total_sales.total_sales_per_store > avg_sales.avg_sales_for_all_stores;

-- Solve with WITH clause
with Total_Sales (store_id, total_sales_per_store) as 
        (select s.store_id, sum(cost) as total_sales_per_store
	     from sales s
	     group by s.store_id),
	 avg_sales (avg_sales_for_all_stores) as
	     (select cast(avg(total_sales_per_store) as int) as avg_sales_for_all_stores
		  from Total_Sales)
select *
from Total_Sales ts
join avg_sales av
on ts.total_sales_per_store > av.avg_sales_for_all_stores
;

-- 为什么要用 subquery？ subquery 的好处？
-- Use a particular subquery multiple times -> should consider using a WITH clause
-- 让人更 easy to read/maintain/understand/debug
-- 可以 improve performance, 因为相同的 subquery 不用算多次了




