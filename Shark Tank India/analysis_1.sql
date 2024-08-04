use practise;

select * from sharktank;
truncate table sharktank;
alter table sharktank modify column Started_in varchar(20);


load data infile 'D:/SQL-case-studies/Shark Tank India/sharktank.csv'
into table sharktank
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select * from sharktank;


/*1. You Team must promote shark Tank India season 4, The senior come up with the idea to show highest funding domain wise so 
that new startups can be attracted, and you were assigned the task to show the same.*/

select industry, max(`Total_Deal_Amount(in_lakhs)`) as max_funding from sharktank group by industry order by max_funding desc;

select * from 
(
select industry, `Total_Deal_Amount(in_lakhs)`, row_number() over(partition by industry order by `Total_Deal_Amount(in_lakhs)` desc) as 'rnk'
from sharktank group by industry, `Total_Deal_Amount(in_lakhs)`
)t
where rnk = 1;


/*2. You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%*/

select *, (female/male)*100 as 'ratio' from
(
select industry, sum(Female_Presenters) as 'female', sum(Male_Presenters) as 'male' -- , (female + male) as 'total', (female/total) as 'ratio'
from sharktank group by industry having female > 0 and male > 0
)t
having ratio > 70;

/*3. You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per season sale pitch made, 
pitches who received offer and pitches that were converted. Also show the percentage of pitches converted and percentage of pitches 
entertained.*/

select * from sharktank;

select a.season_number, (offered/total)*100 as 'offered_%', (accepted/total)*100 as 'accepted_%' from 

(
select season_number, count(pitch_number) as 'total' from sharktank group by season_number
)a
inner join
(
select season_number, count(pitch_number) as 'offered' from sharktank where received_offer = 'yes' group by season_number
)b 
on a.season_number = b.season_number
inner join
(
select season_number, count(pitch_number) as 'accepted' from sharktank where accepted_offer = 'yes' group by season_number
)c
on b.season_number = c.season_number;

/*4. As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show, 
you are determining the season with the highest average monthly sales and identify the top 5 industries with the highest average 
monthly sales during that season to optimize investment decisions?*/

set @season = (select season_number from 
(
select season_number, round(avg(`monthly_sales(in_lakhs)`),2) as 'avg_sales' from sharktank 
group by season_number order by avg_sales desc limit 1
)t);

select industry, round(avg(`monthly_sales(in_lakhs)`),2) as 'avg_sales_of_industry' from sharktank where season_number = @season
group by industry order by avg_sales_of_industry desc limit 5;

/*5. As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent 
increases in funds raised over multiple seasons. This requires focusing on industries where data is available across all three seasons. 
Once these industries are pinpointed, your task is to delve into the specifics, analyzing the number of pitches made, 
offers received, and offers converted per season within each industry.*/

select * from sharktank;
select industry, season_number, sum(`Total_Deal_Amount(in_lakhs)`) as 'total_deal' from sharktank
group by industry, season_number;

-- pivot 
with required as 
(
select industry,
max(case when season_number = 1 then `Total_Deal_Amount(in_lakhs)` end) as season_1,
max(case when season_number = 2 then `Total_Deal_Amount(in_lakhs)` end) as season_2,
max(case when season_number = 3 then `Total_Deal_Amount(in_lakhs)` end) as season_3
from sharktank
group by industry
having season_3 > season_2 and season_2 > season_1 and season_1 != 0
)

select b.season_number, a.industry, count(b.startup_name) as 'total', 
count(case when b.received_offer = 'yes' then b.startup_name end) as 'received',
count(case when b.accepted_offer = 'yes' then b.startup_name end) as 'accepted' 
from required as a inner join sharktank as b
on a.industry = b.industry
group by b.season_number, a.industry

/*6. Every shark wants to know in how much year their investment will be returned, so you must create a system for them, where shark 
will enter the name of the startup’s and the based on the total deal and equity given in how many years their principal amount will 
be returned and make their investment decisions.*/













