use maven_advanced_sql;

select * from students;

select * from students  where school_lunch ='Yes';
-- The BIG 6 --
select grade_level, avg(gpa) as avg_gpa
 from students 
 where school_lunch ='Yes'
 group by grade_level
 having avg_gpa < 3.3
 order by grade_level;
 
 -- Common Keywords --
 
 select distinct grade_level from students;

select count(distinct grade_level) from students;

select max(gpa), min(gpa) from students;


select max(gpa) - min(gpa) as gpa_range  from students;

select * from students 
where grade_level < 12;

select * from students 
where grade_level < 12 and school_lunch = 'Yes';

select * from students 
where grade_level in(9,10,11);

select * from students
where email is null;


select * from students
where email is not null;

select * from students
where email like '%.edu';

select * from students
order by gpa desc;


select * from students
order by gpa desc
limit 5;

select student_name , grade_level,
       case when grade_level =9 then 'Freshmen'
            when grade_level = 10 then 'Sophomore'
            when grade_level = 11 then 'junior'
            else 'senior' end as student_class
            from students;
            

-- Basic joins --
select * from happiness_scores;
select * from country_stats;

select hs.year, hs.country,hs.happiness_score,cs.continent
from happiness_scores hs
inner join country_stats cs
on hs.country = cs.country;

select * from orders;
select * from products;

select p.product_id,p.product_name, o.product_id  as product_id_in_orders
from products p
left join orders o
on o.product_id = p.product_id
where o.product_id is null;

select * from happiness_scores hs 
left join inflation_rates as ir
on hs.country = ir.country_name and hs.year = ir.year;


-- self join 

create table if not exists employees(
employee_id int primary key,
employee_name varchar(100),
salary int,
manager_id int
);

insert into employees(employee_id,employee_name,salary,manager_id)
values (1,'Ava', 85000, Null),
       (2, 'Bob', 72000, 1),
       (3, 'Cat', 59000,1),
       (4, 'Dan', 85000,2);


select * from employees;

select e1.employee_id,e1.employee_name,e1.salary,
e2.employee_id,e2.employee_name,e2.salary from employees e1
inner join employees e2
on e1.salary = e2.salary
where  e1.employee_id > e2.employee_id;
;
 
-- employees that have a greater salary

select e1.employee_id,e1.employee_name,e1.salary,
e2.employee_id,e2.employee_name,e2.salary
 from employees e1
inner join employees e2 
on e1.salary > e2.salary
order by e1.employee_id;


-- employees and their managers

select * from employees;

select e1.employee_id,e1.employee_name,e1.salary,
e2.employee_name as manager_name from employees e1
left join employees e2 
on e1.manager_id = e2.employee_id;

select * from products;

select p1.product_id, p1.product_name,p1.unit_price,
p2.product_name,p2.unit_price, (p1.unit_price -p2.unit_price) as diff
from products p1
cross join products p2
on p1.product_id <> p2.product_id
-- where (p1.unit_price -p2.unit_price) between -0.25 and 0.25
where abs(p1.unit_price -p2.unit_price) <0.25
and p1.product_name < p2.product_name
order by diff desc;
 
-- cross joins--
create table tops(
id int,
item varchar(50)
);

create table sizes(
id int,
size varchar(50)
);

create table outerwear(
id int,
item varchar(50)
);

insert into tops(id,item)
values(1, 'T-shirts'),
      (2,'Hoodie');
      
insert into sizes(id,size)
values(101, 'small'),
      (102,'medium'),
      (103,'Large');
      
insert into outerwear(id,item)
values(2, 'Hoodie'),
      (3,'Jacket'),
      (4,'Coat');
      
select * from tops;
select * from sizes;

select * from tops 
cross join sizes;


-- union 

select * from tops;
select * from outerwear;

select * from tops
union
select * from outerwear;
       
select * from tops
union all
select * from outerwear;

select * from happiness_scores;
select * from happiness_scores_current;

select year, country, happiness_score from happiness_scores
union all
select 2024,country, ladder_score from happiness_scores_current;


-- subqueries and CTE's

select * from happiness_scores;

select avg(happiness_score) from happiness_scores;

-- Happiness score deviation from the average
select year, country, happiness_score,
(select avg(happiness_score) from happiness_scores) as avg_score,
happiness_score - (select avg(happiness_score) from happiness_scores) as deviation
from happiness_scores ;

-- list of products from most to least expensive and long with 
-- how much product price differs from avg product price
select * from products;

-- using subqueries inside select statement
select product_id, product_name, unit_price,
(select avg(unit_price) from products) as avg_price,
unit_price - (select avg(unit_price) from products) as diff from products
order by diff desc;


-- subqueries using from clauses

-- average happiness score for each country

-- return  a country happiness scores for the year as well as the average hapiness
-- score for the country across years 


select year, hs.country, hs.happiness_score, c.avg_score ,
(hs.happiness_score - c.avg_score)as diff
from happiness_scores hs
left join
(select country,  avg(happiness_score) as avg_score  
from happiness_scores
group by country) as c
on hs.country = c.country
where hs.country = 'United states';


-- multiple subqueries
-- Return year where happiness_score is greater then avg happiness_score

select * from happiness_scores;

select * from happiness_scores_current;

select * from 
 (select hs.year, hs.country, hs.happiness_score, c1.avg_score
from
(select year, country, happiness_score from happiness_scores
union all
select 2024, country, ladder_score from happiness_scores_current) as hs
left join 
(select avg(happiness_score)as avg_score, country from happiness_scores
group by country) as c1
on c1.country = hs.country) as c1
where happiness_score > avg_score +1;

select * from products;

select p1.factory ,p1.product_name, p2.num_products from products p1
left join 
(select product_name, factory, count(product_name)as num_products from products
group by factory) as p2
on p1.factory = p2.factory
order by factory ;


-- subqueries in where clauses

select * from happiness_scores;

select avg(happiness_score) from happiness_scores;

select year, country, happiness_score from happiness_scores
where happiness_score > (select avg(happiness_score) from happiness_scores);

-- subqueries in having clauses
select region, avg(happiness_score) as avg_score
 from happiness_scores
group by region
having avg_score > (select avg(happiness_score) from happiness_scores);



-- ANY vs ALL 

-- scores that are greater then any 2024 scores 
-- any will check for every row with every other row like cross join 
-- and it will return every thing

select year, country, happiness_score from happiness_scores
where happiness_score > any ( select ladder_score from happiness_scores_current);


-- ALL -
select year, country, happiness_score from happiness_scores
where happiness_score > All ( select ladder_score from happiness_scores_current);

-- Exists -

select * from happiness_scores;
select * from inflation_rates;

select * from happiness_scores  h
where exists ( select country_name from inflation_rates	 as i
                where i.country_name = h.country);
                
-- ALternative to Exists is Inner join

select * from happiness_scores hs
inner join inflation_rates i
on hs.country = i.country_name and hs.year = i.year;

select * from products
where unit_price <
(select min(unit_price) from products
where factory = "Wicked Choccy's") ;


select * from products
where unit_price < 
		all(select unit_price from products
		where factory = "Wicked Choccy's");

-- CTE common table expressions

with country_hs as (select country, avg(happiness_score) as avg_hs_by_country
from happiness_scores
group by country)

select * from happiness_scores as hs
left join 
country_hs on hs.country = country_hs.country;

-- reusable CTE

select * from happiness_scores where year = 2023;

select hs1.year, hs1.happiness_score, hs1.region,
hs2.year,hs2.happiness_score, hs2.region from happiness_scores hs1 inner join
happiness_scores hs2
where hs1.region = hs2.region;


select hs1.year, hs1.happiness_score, hs1.region,
hs2.year,hs2.happiness_score, hs2.region from (select * from happiness_scores where year = 2023)
 hs1 inner join
(select * from happiness_scores where year = 2023) hs2
where hs1.region = hs2.region;

with hs as (select * from happiness_scores where year = 2023)
select hs1.year, hs1.country,hs1.happiness_score, hs1.region,
hs2.year,hs2.country,hs2.happiness_score, hs2.region from 
 hs hs1 inner join hs hs2
on hs1.region = hs2.region
where hs1.country  < hs2.country;


select * from orders;
select * from products;


with cte_1 as (select o.order_id,sum(o.units * p.unit_price) as total from orders o
left join products p
on o.product_id = p.product_id
group by order_id
having total > 200
order by total desc)

select count(*) from cte_1;


-- Multiple CTE's

-- compare 2023 vs 2024 happiness scores side by side.


select * from (with hs23 as (select * from happiness_scores where year = 2023),
     hs24 as (select * from happiness_scores_current)

select hs23.country, hs23.happiness_score as hs_2023,
      hs24.ladder_score as hs_2024
	  from hs23
		left join hs24 
     on hs23.country = hs24.country) as hs_2025
      where hs_2024 > hs_2023;
     
-- return the countries where the scores have been incresed

with hs23 as (select * from happiness_scores where year = 2023),
	 hs24 as (select * from happiness_scores_current),
     hs23_24 as (select hs23.country, hs23.happiness_score as hs_2023,
      hs24.ladder_score as hs_2024
	  from hs23
		left join hs24 
     on hs23.country = hs24.country)
select * from hs23_24
where hs_2024 > hs_2023;

with cte_1 as (select factory,count(product_name) as num_products from products
			  group by factory)
              select p.factory,p.product_name, cte_1.num_products from products p
              left join cte_1
              on p.factory = cte_1.factory
              order by factory;

with cte_1 as (select factory,count(product_name) as num_products from products
			  group by factory),
	 cte_2 as (select p.factory,p.product_name from products p)
     
		select  O2.factory, o.product_name, O2.num_products from cte_2 as O
				left join cte_1 as O2
				on O.factory = O2.factory
				order by O2.factory
;	

-- Recursive CTE's

with recursive emp_hire as 
	( select employee_id, employee_name, manager_id, employee_name as hierarchy
		from employees
where manager_id is null
union all
select e.employee_id,e.employee_name, e.manager_id,
       concat(eh.hierarchy,' > ', e.employee_name) as hierarchy
       from employees e 
       inner join emp_hire as eh
       on e.manager_id = eh.employee_id)

select * from emp_hire;


-- generating sequencies of date

with recursive my_dates(dt) as  (
select '2024-11-01'
union all
select dt + interval 1 day
from my_dates
where dt < '2024-11-06')

select * from my_dates;

-- adding multiple columns to recurvise
with recursive my_dates(dt, dt_plus_two_days) as (
    select '2024-11-01', '2024-11-03'  -- Start dates
    union all
    select dt + interval 1 day, dt + interval 3 day  -- Add 1 day and 3 days to each date
    from my_dates
    where dt < '2024-11-06'
)
select * from my_dates;



with recursive emp_hirerachy as (
select  employee_id, employee_name, manager_id, employee_name as hierarchy
from employees
where manager_id is null

union all

select e.employee_id, e.employee_name, e.manager_id,
      concat(eh.hierarchy,'>',e.employee_name) as hierarchy
      from employees e inner join emp_hirerachy eh
      on e.manager_id = eh.employee_id)

select * from emp_hirerachy;


-- Temporary table and views
-- Temporary table stores the query for that particular session
-- view will store the query in the my view and when ever we call them it will run the query

create temporary table temp_1 as
select year, country, happiness_score from happiness_scores
union all 
select 2024, country, ladder_score from happiness_scores_current;
select * from temp_1;


create  view my_view as
select year, country, happiness_score from happiness_scores
union all 
select 2024, country, ladder_score from happiness_scores_current;

select * from my_view
order by year;

-- drop view my_view3;
drop view if exists my_view3;

create view my_view3 as 
select year, country, happiness_score 
from happiness_scores
union all
select 2024, country, ladder_score 
from happiness_scores_current;

select * from my_view3;


-- Window Functions --

-- return all row numbers
select country, year, happiness_score,
       row_number() over() from happiness_scores
order by country, year;

-- return all row numbers within each window
select country, year, happiness_score,
       row_number() over(partition by country order by year) as row_num
       from happiness_scores
order by country, year;

select * from orders;

select customer_id, order_id, transaction_id,
       row_number() over(partition by customer_id order by transaction_id) as row_num
       from orders
       order by customer_id, row_num;
       
-- Row number rank dense rank

create table if not exists baby_girl_names(
name varchar(100),
babies int);

insert into baby_girl_names(name, babies)
values('Olivia', 99),
      ('Emma', 80),
      ('Charlotte', 80),
      ('Amelia', 75),
      ('Sophia', 72),
      ('Isabella', 70),
      ('Ava', 70),
      ('Mia', 64);

select *,
      row_number() over() as row_num,
      rank() over(order by babies desc) as ranks,
      dense_rank() over(order by babies desc) as dense from 
      baby_girl_names;

-- 

select order_id, product_id,units,
       row_number() over(partition by order_id order by units desc) ranks from orders
      order by order_id, ranks;


select order_id, product_id,units,
       dense_rank() over(partition by order_id order by units desc) ranks from orders
       where order_id like '%44262';
      

select order_id, product_id,units,
       dense_rank() over(partition by order_id order by units desc) ranks from orders;

-- firstvalue(), last_value(), nth_value()

create table baby_names(
gender varchar(100),
name varchar(100),
babies int);
      
insert into baby_names (gender,name, babies)
values ('Female', 'Charlotte', 80),
       ('Female', 'Emma', 82),
       ('Female', 'Olivia', 99),
       ('Male', 'James', 85),
       ('Male', 'Liam', 110),
       ('Male', 'Noah', 95);
        
select * from baby_names;


select *, 
first_value(name) over(partition by gender order by babies desc ) as Top_name,
last_value(name) over(partition by gender ) as last_name,
nth_value(name,3) over (partition by gender) as nth_values
from baby_names;


-- return the first name in each window

select * from baby_names;

select gender, name, babies,
       first_value(name) over(partition by gender order by babies desc) as top_name
       from baby_names;

-- only return the top name for each gender
select * from(
select gender, name, babies,
       first_value(name) over(partition by gender order by babies desc) as top_name
       from baby_names) as tf
where name = top_name;


-- CTE alternative
with cte1 as (
select gender, name, babies,
       first_value(name) over(partition by gender order by babies desc) as top_name
       from baby_names)
select * from cte1
where name = top_name;

-- Return the second name in each window

with cte_2 as (select gender, name, babies,
     nth_value(name,2) over(partition by gender order by babies desc) as second_name
     from baby_names)
	select * from cte_2 where
    name = second_name;
    

-- alternative for using Nth_value
with cte_3 as (select gender, name, babies,
     row_number() over(partition by gender order by babies desc) as second_name
     from baby_names)

select * from cte_3 where second_name <= 2;


select * from(select order_id, product_id, units,
nth_value(product_id,2) over(partition by order_id order by units desc) as units_1
 from orders) as tf
 where product_id = units_1;


select * from (select order_id, product_id, units,
rank() over(partition by order_id order by units desc) as units_1
 from orders) as o
 where units_1 = 2;



-- Lead and Lag
-- return the prior year happiness score

select country , year, happiness_score,
lag(happiness_score) over(partition by country order by year) as prior_score
from happiness_scores;

-- differernce in happiness_scores
with cte_2 as (
select country , year, happiness_score,
lag(happiness_score) over(partition by country order by year) as prior_score
from happiness_scores)
select  country , year, happiness_score, 
       happiness_score - prior_score as diff   from cte_2;

-- lag function with shifting 2 rows prior
with cte_2 as (
select country , year, happiness_score,
lag(happiness_score,2) over(partition by country order by year) as prior_score
from happiness_scores)
select  country , year, happiness_score, 
       happiness_score - prior_score as diff   from cte_2;
       
       
with cte_1 as (select customer_id, order_id, min(transaction_id) min_tr,
				sum(units) as units_1 from orders
				group by customer_id, order_id
				order by customer_id, min_tr),

   prior_cte as (select customer_id, order_id,units_1, 
				lag(units_1) over(partition by customer_id order by order_id) as prior
				from cte_1)
select *, units_1 - prior as diff from prior_cte;

-- Ntile()
-- add a percentile to each row of the data

select region, country, happiness_score from happiness_scores;

-- return the top 25% of the happiness_scores by region

with cte_1 as (select region, country, happiness_score,
      ntile(4) over(partition by region order by happiness_score desc) as hs_pct
      from happiness_scores
      order by region, happiness_score desc)

select * from cte_1 where hs_pct = 1;


-- pull a list of top 1 % of customers in terms of how they spent--

with cte_1 as (select o.customer_id, sum(o.units * p.unit_price) as spent from orders o
				left join products p
				on o.product_id = p.product_id
				group by  o.customer_id),
	cte_2 as (select *, ntile(100) over(order by spent desc) as pct from cte_1)
select * from cte_2
where pct = 1;

-- to get top 1 pct of customer 

-- functions

-- Numeric Functions

select country, population,
       log(population)as log_pop,
       log(population,10) as log_base10,
       round(log(population),2) as log_pop2 from country_stats;


-- floor function for binning
select country, population, floor(population /1000000) as pop_mill
        from country_stats;


-- how many countries have pop > 38 million
with cte_1 as (select country, population, floor(population /1000000) as pop_mill
        from country_stats)
        
select pop_mill, count(country) as num_country from cte_1
group by pop_mill
-- having pop_mill > 38
order by num_country desc;



create table max_run(
name varchar(100),
q1 int,
q2 int,
q3 int,
q4 int);

insert into max_run(name, q1,q2,q3,q4) 
values ('Ali', 100,200,150,null),
       ('Bolt', 350,400,380,300),
       ('Jordon', 200,250,300,320);
       

select * from max_run;


-- return the greatest value in each column

select max(q1),max(q2),max(q3),max(q4) from max_run;

-- return the greatest value in each row

select greatest(q1,q2,q3,q4) from max_run;

-- deal with null values (COALESE)

select greatest(q1,q2,q3,coalesce(q4,0)) from max_run;

-- cast & convert
create table sample_table(
id int,
str_value char(50)
);

insert into sample_table(id, str_value)
values (1,'100.2'),
       (2,'200.4'),
       (3,'300.6');


select * from sample_table;

select id, str_value * 2  from sample_table;

select id, cast(str_value as Decimal(5,2)) * 2  from sample_table;

-- Turn integer into a float

select country , population / 5.0 from country_stats;


select o.customer_id, sum((o.units * p.unit_price)) total_spent,
        floor(sum((o.units * p.unit_price))/10)*10 as ranges
       from orders o left join products p
       on o.product_id = p.product_id
       group by o.customer_id;
  
  
-- aggregrate data 

with cte_1  as (select o.customer_id, sum((o.units * p.unit_price)) total_spent,
        floor(sum((o.units * p.unit_price))/10)*10 as ranges
       from orders o left join products p
       on o.product_id = p.product_id
       group by o.customer_id)
select ranges, count(customer_id) as num_cust from cte_1
group by ranges
order by ranges;

-- date time functions

select current_date(), current_timestamp();

-- select * from my_events;

-- Year(event_date)
-- month(event_date)
-- dayofweek(event_date)
-- dayname(event_data)

-- calculate interval between dates
-- datediff(event_date, current_date())

-- add / subtract interval from a datetime value

-- date_add(event_datetime, interval 1 hour) as plus_one_hour
-- date_add(event_datetime, interval 1 day) as plus_one_hour
-- date_add(event_datetime, interval 1 minute) as plus_one_hour


select order_id, order_date, date_add(order_date, interval 2 day) as ship_date
from orders
where order_date between'2024-04-01' and '2024-06-30';


select order_id, order_date, date_add(order_date, interval 2 day) as ship_date
from orders
where year(order_date) = 2024 and month(order_date) between 4 and 6;

select * from orders;

-- show me list of orders placed on for the quarter q2 for 2024  and 3 days  
-- to the order day as shipping date

select order_id, order_date,
  date_add(order_date, interval 3 day)  as shipping_day from orders
where year(order_date) = 2024 and month(order_date) between 4 and 6;


-- string function

-- change the case

-- upper(event_name)
-- lower(event_name)
-- replace(trim(event_type),'!','')
-- trim(replace(event_type,'!',''))
-- length(event_type)
-- concat(eventname, '|', event_descprition)

select factory, product_id, 
trim(replace(replace(concat(factory,'-',product_id),"'",''),' ','-')) as fac_pr_id 
from products
order by factory;


-- string functions : -pattern matching
--  return first word of each event

-- select event_name, -- 
-- substr(event_name,1,3) -- returns first char to 3rd char
-- instr(event_name,' ') -- returns numerice value where the first space occurs

-- substr(event_name,1,instr(event_name,' ')) -- returns first char to all way to space
-- substr(event_name,1,instr(event_name,' ')-1) returns first char to all way to space and -1
--                                              removes space

-- case when instr(event_name,' ') = 0 then event_name
    --   else substr(event_name,1,instr(event_name,' ')-1) end as first_name

-- Return description that contains family;

-- select * from my_events
-- where desc like '%family%';


-- Return description that starts with A

select * from my_events
where event_desc like 'A %';

-- Return students with three letter first_names

select * from students
where  student_name like '___ %';

-- regular expressions regexexp

-- select event_desc,

--  regexp_substr(event_desc, 'celebration|festival|holiday') as celebration
-- from events;

-- return words with hypen in them

-- select event_desc,
--  regexp_substr(event_desc, '[A-Z][a-z]+(-[A-Za-z]+)+') as celebration
-- from events;




select product_name, 
case when instr(product_name,'-')= 0 then product_name else
trim(replace(substr(product_name, instr(product_name,'-')),'-','')) end as name1
from products;


select product_name,
Trim(replace(replace(product_name, 'Wonka Bar',''),'-','')) from products;


-- NUll functions

create table contacts (
name varchar(50),
email varchar(50),
alt_email varchar(100));

insert into contacts (name, email, alt_email)
values('Anna', 'anna@example.com', NULL),
('Bob', Null, 'bob.alt@example.com'),
('Charlie', Null, Null),
('David', 'david@example.com', 'david.alt@example.com');



select * from contacts;

-- Null functions

-- Return non null values using case statement

select name, email, 
			case when email is not null then email
            else 'no email' end as contact_email
from contacts;

-- return non null values using IFNUll

select name, email, ifnull(email, 'no email') as contact
from contacts;


select name, email, ifnull(email, alt_email) as contact
from contacts;

-- Return alternative field using multiple checks

select name, email, 
			ifnull(email, 'no email') as contact,
            ifnull(email, alt_email) as contact2,
            coalesce(email,alt_email,'no email' ) as coalees1
from contacts;


select product_name, factory, division,
coalesce(division, 'other')as division2 from products
order by factory;

with cte_1 as (select factory, division, count(product_name)
				as num_products
				from products
				where division is not null
				group by factory, division),

cte_2 as (select factory, division, num_products,
	row_number() over(partition by factory order by num_products desc) np_rank 
    from cte_1)
    
select factory, division from cte_2 where np_rank = 1;

-- Replace missing value with top division

with cte_1 as (select factory, division, count(product_name)
				as num_products
				from products
				where division is not null
				group by factory, division),

cte_2 as (select factory, division, num_products,
	row_number() over(partition by factory order by num_products desc) np_rank 
    from cte_1),
    
cte_3 as (select factory, division from cte_2 where np_rank = 1)

select p.product_name, p.factory, p.division,
       coalesce(p.division, 'other')as division_other,
       coalesce(p.division, cte_3.division)as division_top
from products p left join cte_3 
on p.factory = cte_3.factory
order by p.factory, p.division ;
 


with cte_1 as (select factory,  division ,count( division), 
row_number() over(partition by factory order by count(division) desc) ranks from products
where division is not null
group by factory, division)

select factory, division from cte_1
where ranks = 1;

-- Data analysis application

 -- Duplicate values
 create table employee_details(
 region varchar(50),
 employee_name varchar(50),
 salary int
 );
 
 insert into employee_details(region, employee_name, salary)
 values('East', 'Ava', 85000),
       ('East', 'Ava', 85000),
       ('East', 'Bob', 72000),
       ('East', 'Cat', 59000),
       ('West', 'Cat', 63000),
       ('West', 'Dan', 85000),
       ('West', 'Eve', 72000),
       ('West', 'Eve', 75000);
 
 -- Selecting duplicate employee name
 
 select employee_name, count(employee_name) as dup_cnt from employee_details
 group by employee_name
 having  dup_cnt > 1;

-- Selecting duplicate employee name, region

 select employee_name, region, count(employee_name) as dup_cnt from employee_details
 group by employee_name, region
 having  dup_cnt > 1;

-- Selecting duplicate employee name, region, salary
 select employee_name, region, salary,  count(employee_name) as dup_cnt from employee_details
 group by employee_name, region, salary
 having  dup_cnt > 1;
 
 -- exclude fully duplicate rows
 select distinct region,employee_name, salary from employee_details;

-- 2. Exclude partially duplicate rows ( unique employee name for each row)
select * from (select region, employee_name, salary,
       row_number() over(partition by employee_name order by salary desc) as ranks
       from employee_details) as cte_1
where ranks = 1;

-- Exclude partically duplicate rows between region and employee_name
select * from (select region, employee_name, salary,
row_number() over(partition by employee_name , region order by salary desc) as ransk
from employee_details) as cte_1
where ransk = 1;


-- assigniment Duplicate values
-- select * from students;

with cte_1 as (select id, student_name, email,
row_number() over(partition by student_name order by id desc ) as ranks from students)
select * from cte_1
where ranks = 1
order by id;

-- min max filtering

create table sales(
id int primary key,
sales_rep varchar(50),
date date,
sales int);

insert into sales(id, sales_rep, date, sales)
values(1,'Emma', '2024-08-01', 6),
      (2,'Emma', '2024-08-01', 17),
      (3,'Jack', '2024-08-02', 14),
      (4,'Emma', '2024-08-04', 20),
      (5,'Jack', '2024-08-05', 5),
      (6,'Emma', '2024-08-07', 1);

select * from sales;

-- Return the most recent sales amount for each sales rep with window and CTE

with cte_1 as (select id, sales_rep, date, sales,
row_number() over(partition by sales_rep order by date desc) as ranks
from sales)
select id, sales_rep, date, sales from cte_1 where ranks = 1;


-- Return the most recent sales amount for each sales rep with group by

with cte_1 as (select s.sales_rep, max(s.date) as most_recent_date from sales s
group by s.sales_rep)
select cte_1.sales_rep, cte_1.most_recent_date, s.sales from cte_1 
left join sales s 
on cte_1.sales_rep = s.sales_rep  and cte_1.most_recent_date = s.date;


-- assignment 2

select * from students;

-- filter students scores based on top score in subjects 
-- with window functions and subquery or cte
select  id, student_name, class_name, final_grade from (select s.id, s.student_name, sg.class_name, sg.final_grade,
dense_rank() over(partition by s.student_name order by final_grade desc)as top_rank
from student_grades sg
left join students s 
on sg.student_id = s.id) as cte_1
where top_rank = 1;

-- with group by and join

select * from students;
select * from student_grades;

select s.id, s.student_name, sg.class_name, sg.final_grade
from students s left join  student_grades sg
on s.id = sg.student_id;

-- every student and their highest grade

select s.id, s.student_name, max(sg.final_grade)as top_grade
from students s inner join  student_grades sg
on s.id = sg.student_id
group by s.id, s.student_name
order by s.id ;

-- for every top grade i want to  pull in class name

with cte_1 as(select s.id, s.student_name, max(sg.final_grade)as top_grade
				from students s inner join  student_grades sg
				on s.id = sg.student_id
				group by s.id, s.student_name
				order by s.id)
select cte_1.id, cte_1.student_name,sg.class_name,cte_1.top_grade
from cte_1 left join student_grades sg 
on cte_1.id = sg.student_id and cte_1.top_grade = sg.final_grade ;

select * from student_grades;

-- pivoting tables summary

create table pizza_table(
category varchar(50),
crust_type varchar(50),
pizza_name varchar(100),
price decimal (5,2)
);

insert into pizza_table(category, crust_type, pizza_name, price)
values ('Chicken', 'Gluten-Free Crust', 'California Chicken', 21.75),
      ('Chicken', 'Thin Crust', 'Chicken Pesto', 20.75),
        ('Classic', 'Standard Crust', 'Greek', 21.50),
         ('Classic', 'Standard Crust', 'Hawaiian', 19.50),
          ('Classic', 'Standard Crust', 'Pepperoni', 18.75),
          ('Supreme', 'Standard Crust', 'Spicy Italian', 22.75),
          ('Veggie', 'Thin Crust', 'Five Cheese', 18.50),
          ('Veggie', 'Thin Crust', 'Margherita', 19.50),
          ('Veggie', 'Gluten-Free Crust', 'Garden Delight', 21.50);
          
select *,
       case when crust_type = 'Standard Crust'then 1 else 0 end as 'Standard Crust',
       case when crust_type = 'Thin Crust'then 1 else 0 end as 'Thin Crust',
       case when crust_type = 'Gluten-Free Crust' then 1 else 0 end as 'Gluten-Free Crust'
       from pizza_table;


select category,
       sum(case when crust_type = 'Standard Crust'then 1 else 0 end) as 'Standard Crust',
       sum(case when crust_type = 'Thin Crust'then 1 else 0 end) as 'Thin Crust',
       sum(case when crust_type = 'Gluten-Free Crust' then 1 else 0 end) as 'Gluten-Free Crust'
       from pizza_table
       group by category;
       
select * from students;
select * from student_grades;

select distinct grade_level from students;

-- creating  new columns for pivoting
select  sg.department, sg.final_grade,
 case when s.grade_level = 9 then 1 else 0 end as freshmen,
 case when s.grade_level = 10 then 1 else 0 end as sophmore,
 case when s.grade_level = 11 then 1 else 0 end as junior,
 case when s.grade_level = 12 then 1 else 0 end as senior 
 from students s
left join student_grades sg
on s.id = sg.student_id
group by sg.department,s.grade_level;

-- update the values for the final grade

select  sg.department,
 case when s.grade_level = 9 then sg.final_grade else 0 end as freshmen,
 case when s.grade_level = 10 then sg.final_grade else 0 end as sophmore,
 case when s.grade_level = 11 then sg.final_grade else 0 end as junior,
 case when s.grade_level = 12 then sg.final_grade else 0 end as senior 
 from students s
left join student_grades sg
on s.id = sg.student_id
group by sg.department,s.grade_level; 


-- final summary table 

select  sg.department,
		 avg(case when s.grade_level = 9 then sg.final_grade else null end) as freshmen,
		 avg(case when s.grade_level = 10 then sg.final_grade else null end) as sophmore,
		 avg(case when s.grade_level = 11 then sg.final_grade else null end) as junior,
		 avg(case when s.grade_level = 12 then sg.final_grade else null end) as senior 
 from students s
left join student_grades sg
			on s.id = sg.student_id
where sg.department is not null
group by sg.department
order by department;


-- Rolling Calculations
create table pizza_orders(
order_id int primary key,
customer_name varchar(50),
order_date date,
pizza_name varchar(100),
price decimal(5,2)
);

insert into pizza_orders(order_id, customer_name, order_date, pizza_name,price)
values(1,'Jack', '2024-12-01', 'Pepperoni', 18.75),
(2,'Jack', '2024-12-02', 'Pepperoni', 18.75),
(3,'Jack', '2024-12-03', 'Pepperoni', 18.75),
(4,'Jack', '2024-12-04', 'Pepperoni', 18.75),
(5,'Jack', '2024-12-05', 'Spicy Italian', 22.75),
(6,'Jill', '2024-12-01', 'Five Cheese', 18.50),
(7,'Jill', '2024-12-03', 'Margherita', 19.50),
(8,'Jill', '2024-12-05', 'Garden Delight', 21.50),
(9,'Jill', '2024-12-05', 'Greek', 21.50),
(10,'Tom', '2024-12-02', 'Hawaiian', 19.50),
(11,'Tom', '2024-12-04', 'Chicken Pesto', 20.75),
(12,'Tom', '2024-12-05', 'Spicy Italian', 22.75),
(13,'Jerry', '2024-12-01', 'California Chicken', 21.75),
(14,'Jerry', '2024-12-02', 'Margherita', 19.50),
(15,'Jack', '2024-12-04', 'Greek', 21.50);

select * from pizza_orders;

-- Calculate the sales subtotals for each customer

-- view the total sales for each customer on each date.
 
 select customer_name, order_date, sum(price) as total_sales from pizza_orders
 group by customer_name, order_date;

-- Include the subtotals
 select customer_name, order_date, sum(price) as total_sales, count(price) as nums from pizza_orders
 group by customer_name, order_date with rollup;
 
 -- calculate the cumulative sum of sales over time
 
 select order_date, price from pizza_orders
 order by order_date;
 
 -- calculate total sales for each day

 
 select order_date, sum(price) as total_sales from pizza_orders
 group by order_date
 order by order_date;
 
 -- calculate the cumulative sales over time
 
 with cte_1 as ( select order_date, sum(price) as total_sales from pizza_orders
 group by order_date
 order by order_date)

select 	order_date, total_sales,
		sum(total_sales) over(order by order_date)as sums
from 	cte_1;

-- calculate the 3 year moving average of happiness_sccores for each country
 
select * from happiness_scores;

-- view the happiness scores for each country, sorted by year
select year, country, happiness_score from happiness_scores
order by country , year;

-- create a basic row_number window function
select year, country, happiness_score,
row_number() over(partition by country order by year) from happiness_scores
order by country , year;


-- update the function to a moving average calculation
select year, country, happiness_score,
avg(happiness_score) over(partition by country order by year)as row_num from happiness_scores
order by country , year;


-- update the function to a 3 year moving average calculation
select year, country, happiness_score,
round(avg(happiness_score) 
	over(partition by country order by year rows between 2 preceding and current row),3)as row_num 
from happiness_scores
order by country , year;


select year(o.order_date)as Y, month(o.order_date)as M, sum((units * unit_price)) as total_sum,
sum(sum((units * unit_price))) over(order by  year(o.order_date), month(o.order_date)) as cum_sum,
round(avg(sum(units * unit_price)) over(partition by  year(o.order_date) order by month(o.order_date)
										rows between 5 preceding and current row),2) 
as six_cum_sum
from orders o
left join products p 
on o.product_id = p.product_id
group by Y,M
;









-- generate a report to show total sales by month year and cum sales month over month
-- six month moving average of total sales

select * from orders;

select * from products;

select year(o.order_date) Y, month(o.order_date) M, sum(units * unit_price) total_sum,
sum(sum(units * unit_price)) over(partition by year(o.order_date) order by month(o.order_date))as monthly_cumulative,
round(avg(sum(units * unit_price)) over(order by
					year(o.order_date), month(o.order_date) rows between 5 preceding and current row),2)
            as five_month_average
from orders o
left join products p 
on o.product_id = p.product_id
group by Y,M;

-- now this is the bad way to write any sql query due to no appropriate names given no indentation
-- user fill have a hard way to read this.
-- best way is to break it down to multiple cte's and window functions 

select o.order_date, o.units * p.unit_price as total_sum 
from orders o left join products p
on o.product_id = p.product_id;


-- we month over month sales 

select year(o.order_date) as yrs, Month(o.order_date) as mnth, sum(o.units * p.unit_price) as total_sum 
from orders o left join products p
on o.product_id = p.product_id
group by yrs,mnth
order by  yrs,mnth;

-- Add on a cumulative sum and 6 month moving average

with ms as (select year(o.order_date) as yrs, Month(o.order_date) as mnth, sum(o.units * p.unit_price) as total_sum 
			from orders o left join products p
			on o.product_id = p.product_id
			group by yrs,mnth
			order by  yrs,mnth)

select *,
	   row_number() over(order by yrs, mnth) as row_num,
       sum(total_sum) over(order by yrs, mnth) as cum_num,
       avg(total_sum)  over(order by yrs, mnth Rows between 5 preceding and current row) 
       as six_avg_mvng from  ms;
       
-- Imputing Null values

create table if not exists stock_prices(
date Date primary key,
price decimal(10,2)
);

insert into stock_prices(date, price)
values('2024-11-01', 678.27),
('2024-11-03', 688.83),
('2024-11-04', 645.40),
('2024-11-06', 591.01);

select * from stock_prices;


with recursive my_dates(dt) as (select '2024-11-01' 
								union all 
								select dt + interval 1 day
								from my_dates
								where dt <'2024-11-06')
                                
select md.dt, sp.price from my_dates md
left join stock_prices sp
on md.dt = sp.date;

-- lets replace null values in the price columns in 4 differernt ways

-- 1. with hard coded values
-- 2. with a subquery
-- 3. with one window function
-- 4. with two window functions



with recursive my_dates(dt) as (select '2024-11-01' 
								union all 
								select dt + interval 1 day
								from my_dates
								where dt <'2024-11-06'),
													
					sp as (select md.dt, sp.price from my_dates md
							left join stock_prices sp
							on md.dt = sp.date)

select dt, price, 
		coalesce(price, 600) as updated_price_600,
        coalesce(price, (select avg(price) from sp)) as avg_updated_price,
        coalesce(price, lag(price)over()) as prior_updated_price,
        coalesce(price, lead(price)over()) as next_updated_price,
        coalesce(price, (lag(price)over() + lead(price)over())/2) as smooth_updated_price
        from sp;



 


