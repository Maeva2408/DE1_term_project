# DE1_term_project
Maeva Braeckevelt-Term_project-DE1
# Analytic plan #

I choose three data tables from Kaggle : the first one is about the killings in USA by the police in 2015, I have a lot of variable like state, sex, race, age etc.
The second one is about the median income in every state of USA for 2015.
The last one is about the homicide rate by state in 2015.

## Importing the data

I ran into some difficulties when I was importing the data.
One of them was the date, it was in European format so when I imported it it was reversed.
So,I decided to import it as a string and then find a way to convert it.

## ERR Diagram 

![picture alt](https://github.com/Maeva2408/DE1_term_project/blob/main/ERR_Diagram_kills_data.png "ERR Diagram - Police Killing in US in 201")

## Analytics

I would like to prepare my data for analysis so I will do a stored procedure to create ma data store.
Here the questions I would like to start with :

*Whether the context of the killing (race,state,etc) were random or if we can uncover some pattern?
*Are more men kill than women?
*Is there a sesaonality (month, week, holidays) with regards to increase killings?
*Are there more killings in poorer states?
*Are there more killings in states with higher homicide rates?
*Do the killings uncnover racial profiling?

To answer those questions I need to create a new table with the dimensions I need.
Dimension chosen : ID, Date (month), State, Homicide_rate, Median_income, race and gender

Class | Measure
:-----| :-------------
Fact  | Kills
Dimension  | State
Dimension  | Gender
Dimension  | Median Income
Dimension  | Rate Homicide
Dimension  | Race
Dimension  | Date (Month)


## Stored Procedure and Trigger

I did my stored procedure to create a data store with those variable. 











I add a trigger and I test it.

## Views








