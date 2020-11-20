-------------- Fall Assignement DE1 
----------- OPERATIONAL LAYER
-------- Import data from CSV files
-- Import first txt file
drop schema if exists term_project_police_killing_us;
create	schema Term_project_Police_killing_us;
use Term_project_Police_killing_us;
DROP TABLE IF exists Police_killing_US;
CREATE TABLE  Police_killing_US 
(id varchar(50),
name VARCHAR(200),
date VARCHAR (200),
manner_of_death VARCHAR(200),
armed VARCHAR(200),
age int,
gender VARCHAR(10),
Race VARCHAR(10),
city VARCHAR(50),
State VARCHAR(10),
signs_of_mental_illness VARCHAR(10),
threat_level varchar(50),
flee varchar(50),
body_camera varchar(5),
PRIMARY KEY(id));
SHOW VARIABLES LIKE "secure_file_priv";
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PoliceKillingsUS.txt'
INTO TABLE Police_killing_US
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

select * from term_project_police_killing_us.police_killing_us;

-- Import the second txt file
use Term_project_Police_killing_us;
drop table if exists state_income;
CREATE TABLE  state_income
( `Rank` varchar(100),
state_name VARCHAR(100),
state varchar(2),
Per_capita_income bigint,
Median_household_income bigint,
Median_family_income bigint,
Population bigint,
Number_of_households bigint,
Number_of_families bigint,
PRIMARY KEY(`rank`));
SHOW VARIABLES LIKE "secure_file_priv";
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/state_income.txt'
INTO TABLE state_income
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

Select * from state_income;

-- Import the third txt file
use Term_project_Police_killing_us;
drop table if exists state_homicide_rate;
CREATE TABLE state_homicide_rate
( Rank_Homicide_per_100000hab varchar(50),
state_name VARCHAR(50),
state varchar(2),
year_2015 decimal(4,2),
PRIMARY KEY(Rank_Homicide_per_100000hab));
SHOW VARIABLES LIKE "secure_file_priv";
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/homicide_rate_2015.txt'
INTO TABLE state_homicide_rate
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

Select * from state_homicide_rate;

-------- Cleaning data table
-- Change the format of the date
-- I will substring, concatenate, and cast in the date format
alter table police_killing_us
ADD date_formated VARCHAR(255);
use term_project_police_killing_us;
UPDATE police_killing_us 
SET 
  Date_formated = CAST(CONCAT(SUBSTRING(
police_killing_us.date
,7,10),SUBSTRING(
police_killing_us.date
,3,4),SUBSTRING(
police_killing_us.date
,1,2)) as DATE);

select date, date_formated from police_killing_us;

----------- ANALYTICS : Questions that coulb be answered thanks to this data:
-------- Whether the context of the killing (race,state,etc) were random or if we can uncover some pattern?
-------- Are more men kill than women?
-------- Is there a sesaonality (month, week, holidays) with regards to increase killings?
-------- Are there more killings in poorer states?
-------- Are there more killings in states with higher homicide rates?
-------- Do the killings uncnover racial profiling?
-------- To answer those questions I need to create a new table with the dimensions I need.
----- Dimension chosen : ID, Date (month), State, Homicide_rate, Median_income, race and gender

----------- ETL PIPLINE
-------- Stored Procedure (Extract the data (and join table), transform the data (date in month) and load)

DROP PROCEDURE IF EXISTS Data_store_killing;

DELIMITER //

CREATE PROCEDURE Data_store_killing()
BEGIN

	DROP TABLE IF EXISTS Stored_Police_killing_us;

	CREATE TABLE Stored_Police_killing_us AS
	SELECT 
	   police_killing_us.id AS Kills_id, 
	   police_killing_us.date_formated AS Date,
	   monthname (police_killing_us.date_formated) AS Month,
       police_killing_us.state AS State,
	   state_homicide_rate.year_2015 As Homicide_rate,   
	   state_income.Median_household_income As Median_income,
	   police_killing_us.race AS Race, 
       police_killing_us.gender As gender
	FROM
		police_killing_us
	INNER JOIN
		state_income USING (state)
	INNER JOIN
		state_homicide_rate USING (state)
	ORDER BY 
		date;

END //
DELIMITER ;
CALL Data_store_killing() ;
select * from Stored_police_killing_us;

-------- Create a trigger
----- If there is a new killing, I want my police_killing_us_data updated
DROP TABLE IF EXISTS messages;

CREATE TABLE IF NOT EXISTS messages (
message varchar(100) NOT NULL);

DROP TRIGGER IF EXISTS after_kills_insert; 

DELIMITER $$

CREATE TRIGGER after_kills_insert
AFTER INSERT
ON police_killing_us FOR EACH ROW
BEGIN
	
    	INSERT INTO messages SELECT CONCAT('new id: ', NEW.id);

	INSERT INTO stored_police_killing_us
	SELECT 
		police_killing_us.id AS kills_id, 
	   police_killing_us.date_formated AS Date,
	   monthname (police_killing_us.date_formated) AS Month,
       police_killing_us.state AS State,
	   state_homicide_rate.year_2015 As Homicide_rate,   
	   state_income.Median_household_income As Median_income,
	   police_killing_us.race AS Race, 
       police_killing_us.gender As gender
		FROM
		police_killing_us
	INNER JOIN
		state_income USING (state)
	INNER JOIN
		state_homicide_rate USING (state)
	WHERE id = NEW.id
	ORDER BY 
		date;
        
END $$

DELIMITER ;

INSERT INTO police_killing_us ( id,name, date, manner_of_death, armed, age, gender, Race, city, State, signs_of_mental_illness, threat_level, flee, body_camera,date_formated)
VALUES('1', 'John Doe', '22-01-2015', 'shot', 'gun', '30', 'M', 'A', 'Shelton', 'WA', 'FALSE','attack', 'foot','TRUE', '2015-01-22' );
select * from messages;
Select * from stored_police_killing_us
where kills_id = 1;
----------- I will delete it to not alter the data
delete from police_killing_us
where id =1;
delete from stored_police_killing_us
where kills_id =1;



-------- DATA MART : I will creat some views to define sections of the datastore police_killing_us_data useful for the analysis
-- View 1 : Kills vs Gender
use stored_police_killing_us;
drop view if exists Kills_vs_gender;
create view Kills_vs_gender as
select
case
when gender = 'F' then ' Female'
when gender = 'M' then 'Male'
end as kills_gender,
 count(kills_id) as Total_kills
FROM stored_police_killing_us
group by kills_gender;

select * from Kills_vs_gender;

-- View 2 : Kills vs race
use stored_police_killing_us;
drop view if exists Kills_vs_Race;
create view Kills_vs_race as
select race,
case
when race = 'B' then 'Black or African American'
when race = 'W' then 'white'
when race = 'A' then 'Asian'
when race = 'H' then 'Hispanic or Latino'
when race = 'N' then 'Native American'
when race = 'O' then 'Other'
else 'Unknown'
end as kills_race,
count(kills_id) as Total_kills
FROM stored_police_killing_us
group by race
order by Total_kills desc;

select * from Kills_vs_Race;


-- View 3 Kills vs Month
use stored_police_killing_us;
drop view if exists Kills_vs_Month;
create view Kills_vs_Month as
select count(kills_id) as Total_kills, stored_police_killing_us.month
from stored_police_killing_us
group by month
order by Total_kills desc;

select * from Kills_vs_Month;

-- View 4 State_income vs rate_homicide
use stored_police_killing_us;
drop view if exists state_income_vs_rate_homicide;
create view state_income_vs_rate_homicide as
select state, count(kills_id) as Total_kills, homicide_rate, 
case 
when homicide_rate > avg(homicide_rate) OVER () then 'High_homicide_rate'
when homicide_rate < avg(homicide_rate) OVER () then 'low_homicide_rate'
end as 'Homicide_rate_Cat',
median_income,
case
when median_income > avg(median_income) over () then 'Rich_state'
when median_income < avg(median_income) over () then 'Poor_state' 
end as 'State_income_cat'
from stored_police_killing_us
group by state
order by total_kills desc;

select * from state_income_vs_rate_homicide;
--
use stored_police_killing_us;
drop view if exists state_income_vs_rate_homecide_vs_gender;
create view state_income_vs_rate_homecide_vs_gender as
select gender,count(kills_id) as Total_kills, state, homicide_rate, 
case 
when homicide_rate > avg(homicide_rate) OVER () then 'High_homicide_rate'
when homicide_rate < avg(homicide_rate) OVER () then 'low_homicide_rate'
end as 'Homicide_rate_Cat',
median_income,
case
when median_income > avg(median_income) over () then 'Rich_state'
when median_income < avg(median_income) over () then 'Poor_state' 
end as 'State_income_cat'
from stored_police_killing_us
group by state, gender
order by state asc;

select * from state_income_vs_rate_homecide_vs_gender;

