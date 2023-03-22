# 💉 COVID-19 Data Exploration 

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

Here are the last few rows:

![](CovidProjectImages/covid_sql_image_1.png)

***

### 2. Show each location's highest amount of confirmed cases (max amount of people infected) and the percent of the popuation infected

``` sql 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 1, 2
```

Result: 219 rows

Here are the first 9 rows:

![](CovidProjectImages/covid_sql_image_2.png)

***

### 3. Show countries and their max total death count

``` sql
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
```

Result: 210 rows

Here are the first 9 rows:

![](CovidProjectImages/covid_sql_image_3.png)

***

### 4. Show countries where highest death count is greater than or equal to 50,000

``` sql
with cte AS(
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
)
SELECT location, TotalDeathCount
FROM cte
WHERE TotalDeathCount >= 50000
ORDER BY TotalDeathCount DESC
```

Result: 210 rows

Here are the last few rows (notice TotalDeathCount does not go below 50,000):

![](CovidProjectImages/covid_sql_image_4.png)

***

### 5. Show total cases, total tests, and the percent of confirmed cases of total tests

``` sql
SELECT dea.continent, dea.location, dea.date, dea.total_cases, vac.total_tests, (dea.total_cases/vac.total_tests)*100 AS CasesPerTest
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.total_cases != 0 AND vac.total_tests != 0
ORDER BY location, date
```

Result: 38, 361 rows

Here are the first 9 rows: 

![](CovidProjectImages/covid_sql_image_5.png)

***

### 6. Breaking things down by continent (where North America only includes U.S. Values) and showing continents with the highest death count per population

```sql
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
```

Result: 6 rows

![](CovidProjectImages/covid_sql_image_6.png)

***

### 7. Global numbers: Show the global death percentage grouped by date

```sql
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2
```

Result: 486 rows

Here are the last few rows:

![](CovidProjectImages/covid_sql_image_7.png)

***

### 8. Global numbers: Show the global death percetange

```sql
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2
```

Result: 1 row

![](CovidProjectImages/covid_sql_image_8.png)


### 9. How many people in the world have been vaccinated (total population vs vaccinated)? 

```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER by 2, 3
```

Result: 81,060 rows

Here are the last few rows: 

![](CovidProjectImages/covid_sql_image_9.png)

***

### 10. Using above with CTE to help find percent of people vaccinated

```sql
with cte AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/cte.population)*100 AS RPV_Percentage
FROM cte
ORDER BY 2, 3
```

Result: 81,060 rows

Here are the last few rows:

![](CovidProjectImages/covid_sql_image_10.png)

***

### 10a. Turning above into temp table and then creating a view

#### Creating temp table

``` sql
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS RPV_Percentage
FROM #PercentPopulationVaccinated
```

#### Creating view

``` sql
CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
```

***

### 11. Max ICU patients by country ordered from highest to lowest

```sql
SELECT location, MAX(CAST(icu_patients AS int)) AS maxicu
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY maxicu DESC
```

Result: 210 rows, most of which are null so I will not show them

![](CovidProjectImages/covid_sql_image_11.png)

***

### 12. 
