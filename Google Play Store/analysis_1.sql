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
)a;

/*5. Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the database, 
it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be changed, 
do some measure where the changes in price can be recorded as you can’t stop hackers from making changes.*/

create table changelog(
app varchar(255),
old_price decimal(10,2),
new_price decimal(10,2),
operation_type varchar(255),
operation_date timestamp
)

select * from changelog;

-- temp table
create table play as 
select * from playstore;

-- creating trigger

DELIMITER //
create trigger changelog
after update
on play
for each row 
begin 
	insert into changelog(app, old_price, new_price, operation_type, operation_date)
    values(new.app, old.price, new.price, 'update', current_timestamp);
end;
// DELIMITER ;





/*6. Your IT team have neutralized the threat; however, hackers have made some changes in the prices, 
but because of your measure you have noted the changes, now you want correct data to be inserted into the database again.*/


/*7.As a data person you are assigned the task of investigating the correlation between two numeric factors: 
app ratings and the quantity of reviews.*/



/*8.Your boss noticed  that some rows in genres columns have multiple genres in them, which was creating issue when developing the  recommender system from the data he/she assigned you the task to clean the genres column and make two genres out of it, 
rows that have only one genre will have other column as blank.*/



/*9.Your senior manager wants to know which apps are not performing as par in their particular category, however he is not interested 
in handling too many files or list for every  category and he/she assigned  you with a task of creating a dynamic tool where he/she 
can input a category of apps he/she  interested in  and your tool then provides real-time feedback by displaying apps within that category 
that have ratings lower than the average rating for that specific category.*/



/*10. .What is the difference between “Duration Time” and “Fetch Time.”*/





