DROP TABLE if exists employee_history;
DROP TABLE if exists EMPLOYEE;
drop table if exists department;
DROP table if exists sales ;

create table department
(
	dept_id		int ,
	dept_name	varchar(50) PRIMARY KEY,
	location	varchar(100)
);
insert into department values (1, 'Admin', 'Bangalore');
insert into department values (2, 'HR', 'Bangalore');
insert into department values (3, 'IT', 'Bangalore');
insert into department values (4, 'Finance', 'Mumbai');
insert into department values (5, 'Marketing', 'Bangalore');
insert into department values (6, 'Sales', 'Mumbai');

CREATE TABLE EMPLOYEE
(
    EMP_ID      INT PRIMARY KEY,
    EMP_NAME    VARCHAR(50) NOT NULL,
    DEPT_NAME   VARCHAR(50) NOT NULL,
    SALARY      INT,
    constraint fk_emp foreign key(dept_name) references department(dept_name)
);
insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);


CREATE TABLE employee_history
(
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(50) NOT NULL,
    dept_name   VARCHAR(50),
    salary      INT,
    location    VARCHAR(100),
    constraint fk_emp_hist_01 foreign key(dept_name) references department(dept_name),
    constraint fk_emp_hist_02 foreign key(emp_id) references employee(emp_id)
);

create table sales
(
	store_id  		int,
	store_name  	varchar(50),
	product_name	varchar(50),
	quantity		int,
	price	     	int
);
insert into sales values
(1, 'Apple Store 1','iPhone 13 Pro', 1, 1000),
(1, 'Apple Store 1','MacBook pro 14', 3, 6000),
(1, 'Apple Store 1','AirPods Pro', 2, 500),
(2, 'Apple Store 2','iPhone 13 Pro', 2, 2000),
(3, 'Apple Store 3','iPhone 12 Pro', 1, 750),
(3, 'Apple Store 3','MacBook pro 14', 1, 2000),
(3, 'Apple Store 3','MacBook Air', 4, 4400),
(3, 'Apple Store 3','iPhone 13', 2, 1800),
(3, 'Apple Store 3','AirPods Pro', 3, 750),
(4, 'Apple Store 4','iPhone 12 Pro', 2, 1500),
(4, 'Apple Store 4','MacBook pro 16', 1, 3500);




select * from employee;
select * from department;

-- There are 3 types of subquery:
-- Scalary subquery:
-- Multiple Rwo subquery:
--       multiple row, single column
--       multiple row, multiple column
-- Correlated subquery
-- Nested subquery


-- Scalary subquery
-- subquery awlays returns one row and one col
select * from employee 
where salary > (select avg(salary) from employee)
;

-- can rewrite the query: subquery can also be used in the join/from clause besides where clause
select * from employee e
join (select avg(salary) sal from employee) avg_sal 
on e.salary > avg_sal.sal
;


-- multiple row subquery: a subquery returns multiple rows
-- there are two types of multiple row subquery: 
-- 1. subquery which returns multiple columns and multiple rows
-- 2. subquery which returns only 1 column and multiple rows

-- multiple column, multiple row subquery
/* QUESTION: Find the emplyees who earn the highest salary in each department */
select dept_name, max(salary)
from employee
group by dept_name
;

-- In SQL, we can compare more than one column in the filter condition by placing multiple columns in a parathesis
select * 
from employee
where (dept_name, salary) in (select dept_name, max(salary)  -- it's gonna match the combination of dept_name and salary from the employee table with the values returned by the subquery.
							  from employee
							  group by dept_name);
-- 注意：上面这里用的是 in operator，不是 =
-- = -> expect the right hand side always returns one row
-- in -> if right hand side returns multiple rows


-- single column, multiple row subquery
/* QUESTION: Find department who does not have any employees */

select * 
from department
where dept_name not in (select distinct dept_name from employee)
;




-- Correlated subquery:
-- Correlated subquery is a subquery which is releated to the outer query.

/* QUESTION: Find the employee in each department who earn more than the average salary in that department. */
select avg(salary) from employee where dept_name = "specific_dept"

select * 
from employee e1
where salary > (select avg(salary) 
				from employee e2
				where e2.dept_name = e1.dept_name);
-- 这时，单独run subquery 会错，因为 subquery depends on some of the values from the outer query. SQL will be able to process the subquery from the beginning.
-- For every single rows that is processed in the outer query, it will execute the inner query.
-- In this particular case, 因为 employee table 有 24 different records, this subquery will be executed 24 times.
-- 每次执行时，it's gonna fetch the dept_name from the outer query


/* QUESTION: Find department who do not have any employees */
select * 
from department d
where not exists (select 1 from employee e where e.dept_name = d.dept_name);

select 1 from employee e where e.dept_name = 'Admin'
-- when the subqurey returns no records, then the not exists() will return true; otherwise false



-- Nested Subquery: Subquery inside a subquery

select * from sales;

/* QUESTION: Find stores whose sales were better than the average sales across all stores */
-- 3 steps to solve this problem:
-- 1) find the total sales for each store.
-- 2) find avg sales for all the sotres.
-- 3) compare 1 & 2

select *
from (select store_name, sum(price) as total_sales
	  from sales
	  group by store_name) sales
join (select avg(total_sales) as sales
      from (select store_name, sum(price) as total_sales
	        from sales 
            group by store_name) x) avg_sales
	  on sales.total_sales > avg_sales.sales;


-- If you use the same subquery multiple times, then it's better to use WITH clause.

with sales as
    (select store_name, sum(price) as total_sales
	 from sales
	 group by store_name)
select * 
from sales
join (select avg(total_sales) as sales
	  from sales x) avg_sales
	  on sales.total_sales > avg_sales.sales;






-- Different clause you can use a subquery

-- Using a subquery in a SELECT clause.
/* QUESTION: Fetch all employee details and add remarks to those employee who earn more than the average pay. */

select * 
, (case when salary > (select avg(salary) from employee)
            then 'Higher than average'
        else null
   end
  ) as remarks
from employee;


-- 改写以上 query，把 subquery 放到 join clause 中
select *
, (case when salary > avg_sal.sal
            then 'Higher than average'
        else null
   end ) as remarks
from employee
cross join (select avg(salary) sal from employee) avg_sal;


-- Use a subquery in a HAVING clause
/* QUESTION: Find the stores who have sold more units than the average units sold by all stores. */

select store_name, sum(quantity)
from sales
group by store_name;
having sum(quantity) > (select avg(quantity) from sales);



-- Use subquery in other SQL commands: INSERT, UPDATE, DELETE

-- Use subquery in INSERT
/* QUESTION: Insert data to employee history table. Make sure not insert duplicate records. */

select * from employee_history;

insert into employee_history
select e.emp_id, e.emp_name, d.dept_name, e.salary, d.location
from employee e
join department d on d.dept_name = e.dept_name
where not exists (select 1 
				  from employee_history eh
				  where eh.emp_id = e.emp_id);


-- Use subquery in UPDATE
/* QUESTION: Given 10% increment to all employees in Bangalore location based on the maximum
salary earned by an emp in each dept. Only consider employees in employee_history table. */

update employee e
set salary = (select max(salary) + (max(salary) * 0.1) 
			  from employee_history eh
			  where eh.dept_name = e.dept_name)
where e.dept_name in (select dept_name 
					  from department 
					  where location = 'Bangalore')
and e.emp_id in (select emp_id from employee_history);


-- Use subquery in DELETE statement
/* QUESTION: Delete all departments who do not have any employees. */

delete from department
where dept_name in (select dept_name
				    from department d
				    where not exists (select 1
									  from employee e
									  where e.dept_name = d.dept_name)
					);
-- this is basically a subquery with single column and multiple rows. The subquery returns all departments that do not
-- have any employees.








