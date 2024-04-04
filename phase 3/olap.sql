-- Part1
-- drill down, display the loan amount passed for each date
select sum(l.loan_amt), d.date from loan l join date d on l.date_id = d.id group by d.date order by d.date;

-- roll up, display the loan amount passed for each month
select sum(l.loan_amt), d.month, d.year from loan l join date d on l.date_id = d.id group by d.month, d.year order by d.year, d.month asc;

-- slice, display the total loan amount in 2022
select sum(l.loan_amt), d.year from loan l join date d on l.date_id = d.id where d.year=2022 group by d.year ;

-- dice, display the total loan amount in 2022 applied by foreign worker
select sum(l.loan_amt), d.year from loan l 
join date d on l.date_id = d.id 
join customer c on l.customer_id = c.id 
where d.year=2022 and c.foreign_worker = true group by d.year;

--dice, display the total passed loan in 2022 applied by female
select sum(l.loan_amt), d.year from loan l 
join date d on l.date_id = d.id 
join customer c on l.customer_id = c.id 
where d.year=2022 and c.gender = 'female' group by d.year;

--combine, drill down loan amount to each specific date and slice for year 2022
select sum(l.loan_amt), d.date from loan l 
join date d on l.date_id = d.id 
where d.year=2022 group by d.date order by d.date;

--combine, drill down total loan amount to each specific date and slice for only credit over 200
select sum(l.loan_amt), d.date, ca.status from loan l
join checking_account ca on l.checking_account_id = ca.id
join date d on l.date_id = d.id
where ca.status = 'above:200' group by d.date, ca.status order by d.date;

--combine, roll up total loan amount to each year and slice for only customer with credit over 200
select sum(l.loan_amt), d.year, ca.status from loan l
join checking_account ca on l.checking_account_id = ca.id
join date d on l.date_id = d.id
where ca.status = 'above:200' group by d.year, ca.status order by d.year;

--combine, roll up total loan amount to each year and slice for only single customer
select sum(l.loan_amt), d.year, c.marriage from loan l
join customer c on l.customer_id = c.id
join date d on l.date_id = d.id
where c.marriage = 'single' group by d.year, c.marriage order by d.year;

-- Part 2

-- iceburg display the 20 biggest loan passed in 2022
select l.loan_amt, d.date from loan l
join date d on l.date_id = d.id
where d.year = 2022  order by l.loan_amt desc limit 20;

-- windowing, display the rank by each loan amount partitioned by applicant job type
WITH loan_avg AS(
  SELECT l.loan_amt, 
         c.job_type, 
         ROUND(AVG(l.loan_amt) OVER (PARTITION BY c.job_type), 2) AS avg_loan_amt_by_job_type
  FROM loan l 
  JOIN customer c ON l.customer_id = c.id)

SELECT loan_amt, 
       job_type, 
       avg_loan_amt_by_job_type,
       RANK() OVER (PARTITION BY job_type ORDER BY loan_amt) AS loan_amt_rank
FROM loan_avg;

--window clause, show the rank by each loan amount partitioned by allicant marriage status
WITH loan_avg AS(
  SELECT l.loan_amt, 
         c.marriage, 
         ROUND(AVG(l.loan_amt) OVER W, 2) AS avg_loan_amt_by_job_type
  FROM loan l 
  JOIN customer c ON l.customer_id = c.id
  WINDOW W AS (PARTITION BY c.marriage ORDER BY l.loan_amt))

SELECT loan_amt, 
       marriage, 
       avg_loan_amt_by_job_type,
       RANK() OVER W AS loan_amt_rank
FROM loan_avg
WINDOW W AS (PARTITION BY marriage ORDER BY loan_amt);