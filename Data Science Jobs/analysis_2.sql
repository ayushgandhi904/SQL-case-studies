use Practise;

select * from salaries;

/*1.As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. 
Your Task is to know how many people were employed IN different types of companies AS per their size IN 2021.*/

select company_size, count(company_size) from salaries where work_year = 2021 group by company_size;

/*2.Imagine you are a talent Acquisition specialist Working for an International recruitment agency. 
Your Task is to identify the top 3 job titles that command the highest average salary Among part-time Positions IN the year 2023.*/

select job_title, avg(salary_in_usd) as 'average' from salaries where work_year = 2023 and employment_type = 'PT' group by job_title order by average desc limit 3;

/*3.As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary
for the year 2023.*/
set @average = (select avg(salary_in_usd) from salaries where experience_level = 'MI');
select company_location, avg(salary_in_usd) from salaries where experience_level = 'MI' and salary_in_usd > @average group by company_location;

/*4.As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for 
senior-level (SE) employees in 2023.*/

select company_location, avg(salary_in_usd) as average from salaries where work_year = 2023 and experience_level = 'SE' group by company_location
order by average desc limit 1;


select company_location, avg(salary_in_usd) as average from salaries where work_year = 2023 and experience_level = 'SE' group by company_location
order by average asc limit 1;

/*5. You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles.
By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN 
different job roles.*/

with temp as 
(
select a.job_title, avg_2023, avg_2024 from

	(
	select job_title, avg(salary_in_usd) as avg_2023 from salaries where work_year = 2023 group by job_title
	)a
    inner join
    (
    select job_title, avg(salary_in_usd) as avg_2024 from salaries where work_year = 2024 group by job_title
	)b
    on a.job_title = b.job_title
)
select *, round((((avg_2024 - avg_2023)/avg_2023)*100),2) as '%change' from temp;


/*6. You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. 
Your task is to list the top three  Countries with the highest salary growth rate FROM 2020 to 2023, helping multinational Corporations identify 
Emerging talent markets.*/






