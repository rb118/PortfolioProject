👩🏻‍⚕️ # COVID-19 Data Exploration

Let's explore a global COVID-19 data set.

View the complete syntax [here](https://github.com/rb118/PortfolioProject/blob/main/COVID_Project/Covid_Portfolio_SQL_Final.sql)

***

### 1. Show total cases, total deaths, and the amount of deaths per case

``` sql
SELECT location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2
```

Result: 465 rows

Here are the last of the rows.


![](CovidProjectImages/covid_sql_image_1.png)
