use practise;

select * from playstore;
truncate table playstore;

load data infile 'D:/SQL-case-studies/Google Play Store/playstore.csv'
into table playstore
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

/*1. You're working as a market analyst for a mobile app development company. 
Your task is to identify the most promising categories (TOP 5) for launching new free apps based on their average ratings.*/

select category, round(avg(rating),2) as average from playstore where type = 'free' group by category order by average desc limit 5;

/*2. As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue 
from paid apps. This calculation is based on the product of the app price and its number of installations.*/

select category, round(avg(revenue),2) as 'rev' from
(
select *, (installs*price) as 'revenue' from playstore where type = 'paid'
)x
 group by category order by rev desc limit 3;


/*3. As a data analyst for a gaming company, you're tasked with calculating the percentage of games within each category. 
This information will help the company understand the distribution of gaming apps across different categories.*/

select *, (cnt/(select count(*) from playstore))*100 as '%' from
(
select category, count(app) as 'cnt' from playstore group by category
)t;

/*4. As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should develop paid or free apps 
for each category based on the ratings of that category.*/

select *, if (free_rating > paid_rating, 'develop free app', 'develop paid app') as 'decision' from
(
select x.category, free_rating, paid_rating  from (
(
	select category, round(avg(rating),4) as 'free_rating' from playstore where type = 'free' group by category
)x
inner join
(
	select category, round(avg(rating),4) as 'paid_rating' from playstore where type = 'paid' group by category
)y
on x.category = y.category
)
)a


select * from playstore;

