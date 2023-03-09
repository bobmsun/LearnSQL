-- Video: https://www.youtube.com/watch?v=Ww71knvhQ-s

drop table employee;
create table employee
( emp_ID int
, emp_NAME varchar(50)
, DEPT_NAME varchar(50)
, SALARY int);

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
COMMIT;


/* **************
   Video Summary
 ************** */

select * from employee;

-- Using Aggregate function as Window Function
-- Without window function, SQL will reduce the no of records.
select dept_name, max(salary) from employee
group by dept_name;


-- 自己加：如果 over 里边没有 partition，sql will take the entire table as 1 partition
select e.*, 
max(salary) over() as max_salary, 
max(salary) over() - e.salary as diff_to_max_salary 
from employee e;


-- By using MAX as an window function, SQL will not reduce records but the result will be shown corresponding to each record.
select e.*,
max(salary) over(partition by dept_name) as max_salary
from employee e;


-- row_number(), rank() and dense_rank()
-- row_number() assigns a unique value to each of the record in the table 但是自己试了一下 row number 不见得是按照 record 本身在 tabele 中的顺序 assign 的，就是随机 assin 的
-- （会发现 emp_id 不是sorted，如果需要某种顺序，需要在 over clause 中加 order by）
select e.*,
row_number() over(partition by dept_name) as rn
from employee e;

-- 如果想按照某一顺序 assign row number，可以这样：
select e.*,
row_number() over(partition by dept_name order by salary desc) as rn 
from employee e;


-- Fetch the first 2 employees from each department to join the company.
select * from (
	select e.*,
	row_number() over(partition by dept_name order by emp_id) as rn
	from employee e) x
where x.rn < 3;


-- Fetch the top 3 employees in each department earning the max salary.     
select * from (
	select e.*,
	rank() over(partition by dept_name order by salary desc) as rnk     -- 这里的 rank() 函数会根据 order by 的 column 来 rank
	from employee e) x
where x.rnk < 4;


-- Checking the different between rank, dense_rnk and row_number window functions:
select e.*,
rank() over(partition by dept_name order by salary desc) as rnk,
dense_rank() over(partition by dept_name order by salary desc) as dense_rnk,
row_number() over(partition by dept_name order by salary desc) as rn
from employee e;
-- rank will skip a value for every duplicates; dense_rank will not skip any value
-- row_number just add a unique number to every record


-- 自己加：（面试题）找出 salary 排前三的人
-- clarify: 怎么排序（排序时如何 handle 排名相同的多个人）？ --> 这决定了用什么 rank 的 window function
select * from (
	select e.*,
	rank() over(order by salary desc) as rnk,
	dense_rank() over(order by salary desc) as dense_rnk
	from employee e
) x
where x.rnk < 4    -- 或是 x.dense_rnk < 4  取决于如何排序
;



-- lead and lag

-- 自己加：学习 lag()  window function
select e.*,
lag(salary) over() as prev_salary       -- 这里不加 offset 参数，默认 offset 是 1
from employee e;

select e.*,
lag(salary, 2) over() as prev_salary
from employee e;

select e.*,
lag(salary, -2) over() as prev_salary
from employee e;
-- lag: get the record from previous rows

-- if there is no previous records, it returns null by default, but you can specify a particular value
select e.*,
lag(salary, 2, 0) over(partition by dept_name order by emp_id) as prev_emp_salary 
from employee e;


-- fetch a query to display if the salary of an employee is higher, lower or equal to the previous employee.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
case when e.salary > lag(salary) over(partition by dept_name order by emp_id) then 'Higher than previous employee'
     when e.salary < lag(salary) over(partition by dept_name order by emp_id) then 'Lower than previous employee'
	 when e.salary = lag(salary) over(partition by dept_name order by emp_id) then 'Same than previous employee' end as sal_range
from employee e;


-- Similarly using lead function to see how it is different from lag.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
lead(salary) over(partition by dept_name order by emp_id) as next_empl_sal
from employee e;


-- 自己加：关于 lead
select e.*,
lead(salary, 3) over(order by salary) as next_empl_sal
from employee e;

select e.*,
lead(salary, -3) over(order by emp_id) as next_empl_sal      -- lead + 负offset = lag + 正offset
from employee e;


-- 自己加：其他 window function example
select e.*,
count(*) over(partition by dept_name) as count_of_emp,
sum(e.salary) over(partition by dept_name) as sum_of_salary,
avg(e.salary) over(partition by dept_name) as avg_of_salary
from employee e;
