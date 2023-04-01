-- Script to create the Product table and load data into it.

DROP TABLE if exists product;
CREATE TABLE product
( 
    product_category varchar(255),
    brand varchar(255),
    product_name varchar(255),
    price int
);

INSERT INTO product VALUES
('Phone', 'Apple', 'iPhone 12 Pro Max', 1300),
('Phone', 'Apple', 'iPhone 12 Pro', 1100),
('Phone', 'Apple', 'iPhone 12', 1000),
('Phone', 'Samsung', 'Galaxy Z Fold 3', 1800),
('Phone', 'Samsung', 'Galaxy Z Flip 3', 1000),
('Phone', 'Samsung', 'Galaxy Note 20', 1200),
('Phone', 'Samsung', 'Galaxy S21', 1000),
('Phone', 'OnePlus', 'OnePlus Nord', 300),
('Phone', 'OnePlus', 'OnePlus 9', 800),
('Phone', 'Google', 'Pixel 5', 600),
('Laptop', 'Apple', 'MacBook Pro 13', 2000),
('Laptop', 'Apple', 'MacBook Air', 1200),
('Laptop', 'Microsoft', 'Surface Laptop 4', 2100),
('Laptop', 'Dell', 'XPS 13', 2000),
('Laptop', 'Dell', 'XPS 15', 2300),
('Laptop', 'Dell', 'XPS 17', 2500),
('Earphone', 'Apple', 'AirPods Pro', 280),
('Earphone', 'Samsung', 'Galaxy Buds Pro', 220),
('Earphone', 'Samsung', 'Galaxy Buds Live', 170),
('Earphone', 'Sony', 'WF-1000XM4', 250),
('Headphone', 'Sony', 'WH-1000XM4', 400),
('Headphone', 'Apple', 'AirPods Max', 550),
('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
('Smartwatch', 'Apple', 'Apple Watch Series 6', 1000),
('Smartwatch', 'Apple', 'Apple Watch SE', 400),
('Smartwatch', 'Samsung', 'Galaxy Watch 4', 600),
('Smartwatch', 'OnePlus', 'OnePlus Watch', 220);
COMMIT;




-- All the SQL Queries written during the video

select * from product;


-- FIRST_VALUE 
-- Write query to display the most expensive product under each category (corresponding to each record)
select *,
first_value(product_name) over(partition by product_category order by price desc) as most_exp_product
from product;




-- LASR_VALUE
select *,
first_value(product_name) over(partition by product_category order by price desc) as most_exp_product,
last_value(product_name) over(partition by product_category order by price desc) as least_exp_product
from product;
-- 会发现 last_value 在这里并没有给我们想要的结果



-- frame clause: frame is a subset of partition
-- For the last_value() window function, when it processes the records in this partition, it's no going to use all the records in the partition at once. 
-- It's going to use all the records which are within its frame.
-- frame clause is after the "order by" in the over clause.

-- 摘自：https://drill.apache.org/docs/sql-window-functions-introduction/
-- frame_clause For window functions that operate on the frame instead of the whole partition, the frame_clause specifies the group of rows that create the window frame. 
-- 自悟：window function 分几类：
-- Aggregate Window Function (例如，min，max，count，avg, ...)
--     If an ORDER BY clause is used for an aggregate function, an explicit frame clause is required. 
--     自悟+自试：aggregate window 应该是默认 apply to the entire partition(如果不加 order by 的话)；如果加了 order by，就是默认的 frame 了（从头到 current row）

-- Ranking Window Function ( row_number, rank, dense_rank, cume_dist, percent_rank, ntile ...)
--     The OVER clause cannot contain an explicit frame specification, but must include an ORDER BY clause. 
--     自悟：从时候make sense 的角度讲，rank 和 dense_rank 是一定要加 order by 的；
--     自己试了一下，row_number 加不加 order by 都行

-- Value Window Function (lag, lead, first_value, last_value)
--     The frame clause refines the set of rows in a function’s window, including or excluding sets of rows within the ordered result.
--     根据视频，lag, lead, first_value 可以不 explicitly 加任何 frame，但是 last_value 需要改 frame






-- LAST_VALUE 
-- Write query to display the least expensive product under each category (corresponding to each record)
select *,
first_value(product_name) 
    over(partition by product_category order by price desc) 
    as most_exp_product,
last_value(product_name)                                           -- 第一组
	over(partition by product_category order by price desc
		range between unbounded preceding and current row)         -- this is the default frame clause in Postgre SQL and other SQL，导致 last_value() does not have access to all the records in the partition, 所以要改成如下 frame
	as least_exp_product_default_range,
last_value(product_name) 
    over(partition by product_category order by price desc
        range between unbounded preceding and unbounded following)  -- 对比第一组，这里修改了 range，得到了正确的结果  
	as least_exp_product,
last_value(product_name) 
    over(partition by product_category order by price desc
        rows between unbounded preceding and current row)          -- 对比第一组 last_value 的例子，都是到 current row，但这里是 rows 而不是 range
	as least_exp_product_2
from product
WHERE product_category ='Phone';

-- Not every window will be impacted by this default frame clause. It generally impacts the last_value() and the nth_value() and 
-- also all the aggregated functions (most of the aggregated functions).
-- 自悟：For aggregated functions (for aggregated functions only), 当 over clause 中 没有 order by 时，aggregated function 就是 aggregate 整个 partition（没有 frame 的概念）；
--      For aggregated functions (for aggregated functions only), 只有当 over clause 中用了 order by，才会出现 frame 的概念，这时如果不 explicitly specify frame，就会apply 
--      default frame，有些时候就会得到不 expect 的结果


-- The difference between "range" and "rows":
-- When I use "rows" and use "current row", then it's gonna consider the exact same row.
-- But for "range", if that particular row has some other rows with duplicate value, "range" will consider the last row


-- Other "frame" clause option
-- 下例中，it will conside 2 rows prior to the current row and 2 rows after the current row.
-- So when processing row #3, then row #1, #2, #3, #4, #5, all these 5 rows would be under its frame.
select *, 
--last_value(product_name)
last_value(price)
	over (partition by product_category order by price desc
		  rows between 2 preceding and 2 following)                  -- 视频里这里用的是 range，但自己试了一下，range 好像不是我们expect的结果，用 rows 就对了
	as least_exp_product
from product
where product_category = 'Phone';





-- Alternate way to write SQL query using Window functions
select *,
first_value(product_name) over w as most_exp_product,
last_value(product_name) over w as least_exp_product    
from product
WHERE product_category ='Phone'
window w as (partition by product_category order by price desc           -- this window clause has to be after "from" and "where" and before "order by". Everything you mentioned in the over clause, you can mention it here.
            range between unbounded preceding and unbounded following);
-- Window clause here specify everything that was supposed to be in the over clause and I'm giving it a name (here is w)
-- 用了 window clause，就不用把 same window 在 query 里写 again and again 了, will save a lot of lines in your query and increase readibility

-- 自己试：也可以定义多个 window here？ w1, w2, ...，见下面自己有例子





-- NTH_VALUE
-- NTH_VALUE can the value from any particular position that you specify
-- Write query to display the Second most expensive product under each category.
select *,
first_value(product_name) over w as most_exp_product,
last_value(product_name) over w as least_exp_product,
nth_value(product_name, 2) over w as second_most_exp_product,       -- this is gonna return the second most expensive product. It will get the second record of each partition.
nth_value(product_name, 5) over w as second_most_exp_product_2,
nth_value(product_name, 2) over w2 as second_most_exp_product_3
from product
window w as (partition by product_category order by price desc
            range between unbounded preceding and unbounded following),
       w2 as (partition by product_category order by price desc);   -- 区别在于：这里我们用的 default frame  --> 这里就是想说明：when we use last_value or nth_value, make sure you specify the proper frame clause





-- NTILE
-- NTILE can be used to group together a set of data within your partition and place it into certain buckets.
-- And SQL will try its best that each bucket created within a partition will have almost equal number of records

-- Write a query to segregate all the expensive phones, mid range phones and the cheaper phones.

-- The ntile function will receive 1 argument, which is the number of bucket you want to create
select *,
ntile(3) over (order by price desc) as buckets_3,      -- 这道题都不用 specify partition 因为 题目问的范围是 all phones，但是需要 order by
   													   -- It will try to equally split the 10 records, but we cannot equally splits 10 records into 3 buckets. 
													   -- So it will give precedence/priority to the first bucket. So first bucket will get 1 additional records
ntile(5) over (order by price desc) as buckets_5,
ntile(4) over (order by price desc) as buckets_4
from product
where product_category = 'Phone';

-- So NTILE groups together a set of rows depending on how many buckets you want to create. Under each bucket, it will try to provide equal number of records as much as possible.


select x.product_name, 
case when x.buckets = 1 then 'Expensive Phones'
     when x.buckets = 2 then 'Mid Range Phones'
     when x.buckets = 3 then 'Cheaper Phones' END as Phone_Category
from (
    select *,
    ntile(3) over (order by price desc) as buckets
    from product
    where product_category = 'Phone') x;

-- We can use NTILE function whenever we want to group a few records into some buckets.





-- CUME_DIST (cumulative distribution) ; 
/*  Formula = Current Row no (or Row No with value same as current row) / Total no of rows */

-- Query to fetch all products which are constituting the first 30% 
-- of the data in products table based on price.

-- For CUME_DIST(), you don't need to specify any arguments. It does not accept any argument
select product_name, cume_dist_percetage
from (
    select *,
    cume_dist() over (order by price desc) as cume_distribution,          -- 这里我们没有 specify partition，是把整个table 当成了一个 parition
	round(cume_dist() over (order by price desc)::numeric * 100,2)||'%' as cume_dist_percetage     -- fetch the first 2 decimal points
    from product) x
where x.cume_distribution <= 0.3;




-- PERCENT_RANK (relative rank of the current row / Percentage Ranking)
/* Formula = Current Row No - 1 / Total no of rows - 1 */

-- Query to identify how much percentage more expensive is "Galaxy Z Fold 3" when compared to all products.
select product_name, per_rank
from (
    select *,
    percent_rank() over(order by price) ,
    round(percent_rank() over(order by price)::numeric * 100, 2) as per_rank
    from product) x
where x.product_name='Galaxy Z Fold 3';


