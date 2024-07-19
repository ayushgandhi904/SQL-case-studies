use practise;

select * from playstore;
truncate table playstore;

load data infile 'D:/SQL-case-studies/Google Play Store/playstore.csv'
into table playstore
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;