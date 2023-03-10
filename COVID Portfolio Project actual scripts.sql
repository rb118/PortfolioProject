-- Show total cases, total deaths, and the amount of deaths per case

SELECT location, date, total_cases, total_deaths, (total_deaths)/(total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2

-- Show each location's highest amount of confirmed cases (max amount of people infected) and the percent of the popuation infected

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 1, 2

-- Show countries and their highest death count

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Show countries where highest death count is greater than or equal to 50000. First query uses CTE, second query uses subquery
-- 1. Using cte 

with cte as(
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
)
SELECT location, TotalDeathCount
FROM cte
WHERE TotalDeathCount >= 50000
ORDER BY TotalDeathCount desc

-- 2. Using subquery

SELECT location, TotalDeathCount
FROM (
	SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL 
	GROUP BY location
) max_death
WHERE TotalDeathCount >= 50000
ORDER BY TotalDeathCount DESC

-- Show total cases, total tests, and the percent of confirmed cases of total tests

SELECT dea.continent, dea.location, dea.date, dea.total_cases, vac.total_tests, (dea.total_cases/vac.total_tests)*100 as CasesPerTest
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.total_cases != 0 and vac.total_tests != 0
ORDER BY location, date

-- Breaking things by continent (where North America only includes U.S. Values) ->
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers: global death percentage grouped by date

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Global numbers: finding global death percetange

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- How many people in the world have been vaccinated? (total population vs vaccinated)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2, 3

-- Using above with CTE to help find percent of people vaccinated

with cte as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/cte.population)*100 as RPV_Percentage
FROM cte
ORDER BY 2, 3

-- temp table

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
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

-- Max ICU patients by country ordered from highest to lowest

SELECT location, MAX(CAST(icu_patients as int)) as maxicu
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY maxicu desc

-- Highest number of ICU patients grouped by date in the United States

SELECT location, date, MAX(CAST(icu_patients as int)) as icupatients
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'United States'
GROUP BY location, date
ORDER BY icupatients desc

-- What were the 3 days with the highest number of ICU patients in the United States?

with cte as (
SELECT location, date, MAX(CAST(icu_patients as int)) as icu_patients2, RANK() OVER(PARTITION BY location ORDER BY MAX(CAST(icu_patients as int)) DESC) as rnk
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'United States'
GROUP BY location, date
)

SELECT location, date, icu_patients2
FROM cte
WHERE rnk <= 3

-- Top 3 days with highest number of ICU patients for every country

with cte as (
SELECT location, date, MAX(CAST(icu_patients as int)) as icu_patients2, RANK() OVER(PARTITION BY location ORDER BY MAX(CAST(icu_patients as int)) DESC) as rnk
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, date
)

SELECT location, date, icu_patients2
FROM cte
WHERE rnk <= 3 and icu_patients2 IS NOT NULL

-- Amount of people fully vaccinated in each country

SELECT dea.location, dea.population, MAX(CAST(vac.people_fully_vaccinated as int)) as fully_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY fully_vaxxed DESC

-- Amount of people fully vaxxed in each country expressed as a percentage, alphabetical order by location

with cte as (
SELECT dea.location, dea.population, MAX(CAST(vac.people_fully_vaccinated as int)) as fully_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.population
)

SELECT location, population, fully_vaxxed, (fully_vaxxed/population)*100 as PercentFullyVaccinated
FROM cte
ORDER BY location

-- 7 day rolling average of deaths for United States

SELECT continent, location, date,  population, CAST(new_deaths as int) as new_deaths, AVG(CAST(new_deaths as int)) over(partition by location ORDER BY location, date rows between 6 preceding and current row) as WeeklyRollingDeathAverage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and location = 'United States'
ORDER BY location, date

-- 7 day rolling average of deaths for every location

SELECT continent, location, date,  population, CAST(new_deaths as int) as new_deaths, AVG(CAST(new_deaths as int)) over(partition by location ORDER BY location, date rows between 6 preceding and current row) as WeeklyRollingDeathAverage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY location, date

-- People vaccinated (1 dose)

with cte as (
SELECT dea.continent, dea.location, dea.population, MAX(CAST(vac.people_vaccinated as int)) as partially_vaxxed
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.population
)

SELECT continent, location, population, partially_vaxxed, (partially_vaxxed/population)*100 as PercentPartiallyVaccinated
FROM cte

-- People vaccinated per hundred

SELECT continent, location, max(cast(people_vaccinated_per_hundred as float)) as Max_People_Vaccinated_Per_Hundred
FROM PortfolioProject..CovidVaccinations
GROUP BY continent, location
ORDER BY location

-- GDP per capita and people vaccinated per hundred 

with cte as(
SELECT continent, location, max(gdp_per_capita) as Max_GDP_Per_Capita, max(cast(people_vaccinated_per_hundred as float)) as Max_People_Vaccinated_Per_Hundred 
FROM PortfolioProject..CovidVaccinations
GROUP BY continent, location
)

SELECT *
FROM cte
WHERE Max_GDP_Per_Capita IS NOT NULL
ORDER BY Max_People_Vaccinated_Per_Hundred DESC
