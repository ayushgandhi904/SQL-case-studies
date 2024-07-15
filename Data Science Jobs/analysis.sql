create database Practise;
use Practise;

select * from salaries;

/* 1. As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data.
Your Task is to know how many people were employed IN different types of companies AS per their size IN 2021.*/

select distinct company_location 
from salaries 
where (remote_ratio = 100) and (job_title like '%manager%') and (salary_in_usd >90000);


/* 2. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients 
IN large tech firms. you're tasked WITH Identifying top 5 Country Having greatest count of large (company size)
number of companies.*/

select company_location, COUNT(*) as 'country' from
(
select * from salaries where (company_size = 'L') and (experience_level = 'EN')
)t
group by company_location
order by country desc
limit 5;

/* 3. Picture yourself AS a data scientist Working for a workforce management platform. 
Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, 
Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/

set @total = (select count(*) from salaries where salary_in_usd > 100000);
set @count = (select count(*) from salaries where salary_in_usd > 100000 and remote_ratio = 100);
set @percentage = round(((select @count)/(select @total))*100,2);
select @percentage as 'percnet';

/* 4.Imagine you're a data analyst Working for a global recruitment agency. 
Your Task is to identify the Locations where entry-level average salaries exceed the average salary 
for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities. */

select t.job_title, company_location, avg_salary, avg_per_country from
(
select job_title, avg(salary_in_usd) as 'avg_salary' from salaries where experience_level = 'EN' group by job_title
)t
inner join
(
select company_location, job_title, avg(salary_in_usd) as 'avg_per_country' from salaries where experience_level = 'EN'group by company_location, job_title
)m
on t.job_title = m.job_title
where avg_salary > avg_per_country;

/* 5.You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which. Country pays the maximum average salary. 
This helps you to place your candidates IN those countries.*/


select * from 
(
select *, dense_rank() over (partition by job_title order by average desc) as rank_ from 
(
select company_location, job_title, avg(salary_in_usd) as 'average' from salaries group by company_location, job_title 
)t
)k where rank_ = 1;


/* AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends 
across different company Locations. Your goal is to Pinpoint Locations WHERE the average salary Has consistently 
Increased over the Past few years (Countries WHERE data is available for 3 years Only(present year and past two years) 
providing Insights into Locations experiencing Sustained salary growth.*/

with ayush as
(
	select * from salaries where company_location in
	(
	select company_location from 
	(
	select company_location, avg(salary_in_usd) as 'average', count(distinct work_year) as 'cnt' from salaries
	where work_year >= (year(current_date())-2) 
	group by company_location having cnt = 3
	)t
	)
)

select company_location,
max(case when work_year = 2022 then average end) as avg_salary_2022,
max(case when work_year = 2023 then average end) as avg_salary_2023,
max(case when work_year = 2024 then average end) as avg_salary_2024
from
(
 select company_location, work_year, avg(salary_in_usd) as average from ayush group by company_location, work_year)q
 group by company_location  having (avg_salary_2024 > avg_salary_2023) and (avg_salary_2023 > avg_salary_2022);
 
 
 /* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe 
 the percentage of  fully remote work for each  experience level IN 2021 and compare it WITH the correspONdINg figures for
 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON over the years.*/
 
select x.experience_level, remote_2021, remote_2024 from
(
	select *, ((cnt)/(total))*100 as remote_2021 from 
	(
	select a.experience_level, a.cnt, b.total from 
	(
	select experience_level, count(*) as cnt from salaries where work_year = 2021 and remote_ratio = 100 group by experience_level
	)a 
	inner join
	(
	select experience_level, count(*) as total from salaries where work_year = 2021 group by experience_level
	)b
	on a.experience_level = b.experience_level
	)c
)x
inner join
(
	select *, ((cnt)/(total))*100 as remote_2024 from 
	(
	select d.experience_level, d.cnt, e.total from 
	(
	select experience_level, count(*) as cnt from salaries where work_year = 2024 and remote_ratio = 100 group by experience_level
	)d
	inner join
	(
	select experience_level, count(*) as total from salaries where work_year = 2024 group by experience_level
	)e
	on d.experience_level = e.experience_level
	)f
)y
on x.experience_level = y.experience_level;

/* 8. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over time. 
Your objective is to calculate the average salary INcreASe percentage for each experience level and job title 
between the years 2023 and 2024, helpINg the company stay competitive IN the talent market.*/


select x.experience_level, x.job_title, avg_salary_2023, avg_salary_2024, ((avg_salary_2024 - avg_salary_2023)/avg_salary_2023)*100 as '%change' from 
	(
	select experience_level, job_title, avg(salary_in_usd) as 'avg_salary_2023' from salaries where work_year = 2023 group by experience_level, job_title
	)x
inner join
	(
	select experience_level, job_title, avg(salary_in_usd) as 'avg_salary_2024' from salaries where work_year = 2024 group by experience_level, job_title
	)y
on x.experience_level = y.experience_level and x.job_title = y.job_title;



/* 9. You're a database administrator tasked with role-based access control for a company's employee database. 
Your goal is to implement a security measure where employees in different experience level (e.g.Entry Level, Senior level 
etc.) can only access details relevant to their respective experience_level, ensuring data confidentiality and minimizing 
the risk of unauthorized access. */
 
use practise; 
create user 'entry_level'@'%' identified by 'EN';

create view entry_level as
(
select * from salaries where experience_level='EN'
);

grant select on practise.entry_level to 'entry_level'@'%';

show privileges 