-- This file is to demonstrate the use / behavior of the "distinct" keyword
-- 如果两点 record，只有在 “所有query的column” 中（并不是table中有的所有 column）所有值都一样 [也就意味着两个record是duplicate]，
-- 对任何一个 column 做一个 distinct 就会去除这样的 duplicate


-- Prepare "Staff" table
drop table if exists staff;
CREATE TABLE IF NOT EXISTS STAFF
(
    STAFF_ID         VARCHAR(20)
  , STAFF_TYPE       VARCHAR(30)
  , SCHOOL_ID        VARCHAR(20)
  , FIRST_NAME       VARCHAR(100) NOT NULL
  , LAST_NAME        VARCHAR(100) NOT NULL
  , AGE              INT
  , DOB              DATE
  , GENDER           VARCHAR(10) CHECK (GENDER IN ('M', 'F', 'Male', 'Female'))
  , JOIN_DATE        DATE
  , ADDRESS_ID       VARCHAR(20)
);

INSERT INTO STAFF (STAFF_ID, STAFF_TYPE, SCHOOL_ID, FIRST_NAME, LAST_NAME, AGE, DOB, GENDER, JOIN_DATE, ADDRESS_ID) VALUES
('STF1001', 'Teaching', 'SCHL1001', 'Violet', 'Mascarenhas', '33', TO_DATE('01/01/1987', 'DD/MM/YYYY'), 'F', TO_DATE('02/03/2006', 'DD/MM/YYYY'), 'ADR1003'),
('STF1001', 'Teaching', 'SCHL1001', 'Shaheen', 'Maryam', '55', TO_DATE('02/02/1965', 'DD/MM/YYYY'), 'F', TO_DATE('03/04/1984', 'DD/MM/YYYY'), 'ADR1004');


-- Prepare "Staff_Salary" table
drop table if exists staff_salary;
CREATE TABLE IF NOT EXISTS STAFF_SALARY
(
    STAFF_ID         VARCHAR(20)
  , SALARY           FLOAT
  , CURRENCY         VARCHAR(5)
);

INSERT INTO STAFF_SALARY (STAFF_ID, SALARY, CURRENCY) VALUES
('STF1001', '15000', 'USD'),
('STF1001', '8000', 'USD'),
('STF1001', '6000', 'USD'),
('STF1001', '6000', 'USD'),
('STF1001',' 6000', 'RMB')
;

select * from staff;

-- 对比以下两个 query result
select * from staff_salary;
select distinct(s.staff_id), s.* from staff_salary s;


-- 对比以下两个 query result
SELECT  distinct(STF.FIRST_NAME||' '||STF.LAST_NAME) AS FULL_NAME, SS.SALARY
FROM STAFF STF
JOIN STAFF_SALARY SS ON SS.STAFF_ID = STF.STAFF_ID;

SELECT  distinct(STF.FIRST_NAME||' '||STF.LAST_NAME) AS FULL_NAME, SS.SALARY, ss.currency
FROM STAFF STF
JOIN STAFF_SALARY SS ON SS.STAFF_ID = STF.STAFF_ID;

