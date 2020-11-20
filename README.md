# DE1_term_project
Maeva Braeckevelt-Term_project-DE1
# Analytic plan #

I chose three data tables from Kaggle : the first one is about the killings in USA by the police in 2015, I have a lot of variable like state, sex, race, age etc.
The second one is about the median income in every state of USA for 2015.
The last one is about the homicide rate by state in 2015.

## Importing the data

I ran into some difficulties when I was importing the data.
One of them was the date, it was in European format so when I imported it was reversed.
So, I decided to import it as a string and then find a way to convert it.

## ERR Diagram 

I create my ERR Diagram :
![picture alt](https://github.com/Maeva2408/DE1_term_project/blob/main/ERR_Diagram_kills_data.png "ERR Diagram - Police Killing in US in 201")

I can see that State will be a easy way to join the three table together.

## Analytics

I would like to prepare my data for analysis so I will do a stored procedure to create ma data store.

Here the questions I would like to start with :

* Whether the context of the killing (race,state,etc) were random or if we can uncover some pattern?
* Are more men kill than women?
* Is there a seasonality (month, week, holidays) with regards to increase killings?
* Are there more killings in poorer states?
* Are there more killings in states with higher homicide rates?
* Do the killings uncnover racial profiling?

To answer those questions I need to create a data store with the dimensions I need.

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

I did my stored procedure to create a data store with those variables. (ETL)
I add a trigger and I test it. The trigger will add the new lines from the Police_killing_us to my data store.

## Views
I did five views to lay foundations for future analysis aim to answer the five questions.
To facilitate the comparaison between state for the income and the homicide rate:
I decided to calculate the average of all states and I qualified it either Rich or poor if they were higher or lower than the average.
I did the same for the Homicide rate.
Here is the part of the code:

`case 
when homicide_rate > avg(homicide_rate) OVER () then 'High_homicide_rate'
when homicide_rate < avg(homicide_rate) OVER () then 'low_homicide_rate'
end as 'Homicide_rate_Cat',
median_income,
case
when median_income > avg(median_income) over () then 'Rich_state'
when median_income < avg(median_income) over () then 'Poor_state' 
end as 'State_income_cat'`

## Conclusion
I really enjoyed working on this project. It helps me to see the big picture. Starting with the operational layer: I import, load and clean the data.
Thanks to my analytic plan I knew what to include in my data store which I did through my stored procedure. 
I made sure my data store would been update thanks to a trigger.
Finaly, I made view to help me for a futur analysis of the data.





