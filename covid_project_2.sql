-- EDA Project on Covid data, using Microsoft SQL 
-- Using JOINs, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types) 
-- Data Source: ourworldindata.org 
-- Downloaded two files 'Covid Deaths' and 'Covid Vaccinations'.

--Look at our Covid Deaths Table

SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4 


--Look at our Covid Vaccinations Table

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3, 4


-- Show Top 20 Records of both Tables

SELECT TOP 20 * 
FROM CovidProject..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 3, 4


SELECT TOP 20 * 
FROM CovidProject..CovidVaccinations 
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Check the period of dataset
--We have the data from January 1st, 2020 until February 27th, 2023.

SELECT MIN(date), MAX(date) FROM CovidProject..CovidDeaths
SELECT MIN(date), MAX(date) FROM CovidProject..CovidVaccinations


-- For future analysis assign Null to empty cells in column 'Continent' in both Tables

UPDATE CovidProject..CovidDeaths
SET 
continent = NULL WHERE continent = ''


UPDATE CovidProject..CovidVaccinations
SET 
continent = NULL WHERE continent = ''


/*
 NOTE - continent IS NOT NULL is often used in queries
Both Tables includes continents in the column 'location' - North America, ASia, Africa, Oceania, South America, Europe
continent	location
NULL		South America
NULL		Europe
NULL		North America
NULL		Africa
NULL		ASia
NULL		Oceania
 for these rows, continent is NULL. Excluding these FROM result SET
*/


-- For future analysis change datatype of a few columns to the right type in the Deaths Table

ALTER TABLE CovidDeaths ALTER COLUMN date DATETIME
ALTER TABLE CovidDeaths ALTER COLUMN population BIGINT
ALTER TABLE CovidDeaths ALTER COLUMN total_cases FLOAT
ALTER TABLE CovidDeaths ALTER COLUMN new_cases FLOAT
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths FLOAT
ALTER TABLE CovidDeaths ALTER COLUMN icu_patients FLOAT 
ALTER TABLE CovidDeaths ALTER COLUMN hosp_patients FLOAT 
ALTER TABLE CovidDeaths ALTER COLUMN reproduction_rate FLOAT 
ALTER TABLE CovidDeaths ALTER COLUMN weekly_icu_admissions FLOAT 
ALTER TABLE CovidDeaths ALTER COLUMN weekly_hosp_admissions FLOAT 


-- For future analysis change datatype of a few columns to the right type in the Vaccinations Table

ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN date DATETIME
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN new_vaccinations FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN total_vaccinations FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN positive_rate FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN people_vaccinated FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN people_fully_vaccinated FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN male_smokers FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN female_smokers FLOAT
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN extreme_poverty FLOAT


-- Look a few columns in Table CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent is null
ORDER BY 1, 2


-- Calculate Death Percentage as Total Deaths/Total Cases*100  by date and by country

SELECT location, date, total_cases, total_deaths, ROUND(100*total_deaths/NULLIF(total_cases,0),2) AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is null
ORDER BY 1, 2


-- Calculate Death Percentage from Covid in The USA by date

SELECT location, date, total_cases, total_deaths, ROUND(100*total_deaths/NULLIF(total_cases,0),2) AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2


-- Calculate Total Cases vs Population

-- Calculate what percentage of population got Covid by country and by date

SELECT location, date, total_cases, population, ROUND(100*total_cASes/NULLIF(population,0),2) AS PrecentPopulationCovid
FROM CovidProject..CovidDeaths
--WHERE continent is  not null
ORDER BY 1, 2


-- Total Case Vs Total Deaths (United States) - Observing Change With Time 

SELECT location AS Country, date, total_cases AS cases, total_deaths AS deaths, 
ROUND((total_deaths/total_cases)*100, 4) AS DeathPct
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY date


-- Total Case Vs Total Deaths (Ukraine - my old country) - Observing Change With Time 

SELECT location AS Country, date, total_cases AS cases, total_deaths AS deaths, 
ROUND((total_deaths/total_cases)*100, 4) AS DeathPct
FROM CovidDeaths
WHERE location = 'Ukraine'
ORDER BY date

-- Find countries with the highest Covid case numbers compared to population percentage

SELECT location, population, MAX(total_cASes) AS HighestCovidRate, MAX(ROUND(100*total_cases/NULLIF(population,0),2)) AS PrecentPopulationGotCovid
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PrecentPopulationGotCovid DESC


-- Find countries with the highest death to population percentage

SELECT location, population, MAX(total_deaths) AS HighestDeathRate, MAX(ROUND(100*total_deaths/NULLIF(population,0),2)) AS PrecentPopulationDeath
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PrecentPopulationDeath DESC


-- Find countries with the highest total death counts

SELECT location, MAX(total_deaths) AS HighestDeathRate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathRate DESC


-- Find continents with the highest total death counts

SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathRate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathRate DESC


-- Worldwide Covid statistics

-- Calculate total new Covid cases  and deaths from Covid per day worldwide

SELECT date, SUM(new_cases) AS TotalCovidCases, SUM(CAST (new_deaths AS FLOAT)) AS TotalCovidDeaths, ROUND(100*SUM(CAST(new_deaths AS FLOAT))/NULLIF(SUM(new_cases),0),2) AS PrecentPopulDeathCovid
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Calculate total new Covid cases  and deaths from Covid worldwide

SELECT SUM(new_cases) AS TotalCovidCASes, SUM(convert(FLOAT, new_deaths)) AS TotalCovidDeaths, ROUND(100*SUM(CAST(new_deaths AS FLOAT))/NULLIF(SUM(new_cASes),0),2) AS PrecentPopulDeathCovid
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Worlwide Numbers - Total Cases,Total Deaths, and Death Percentage
SELECT SUM(total_cases) AS TotalCases, SUM(total_deaths) AS TotalDeaths,
SUM(total_deaths)/SUM(total_cases)*100 AS DeathPct
FROM (
		SELECT location, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths
		FROM CovidDeaths
		WHERE continent IS NOT NULL
		GROUP BY location
		HAVING MAX(total_cases) IS NOT NULL
	  ) AS WorldNumbers


-- List Of Countries Affected By Covid19
SELECT DISTINCT location AS List_Countries FROM CovidDeaths
WHERE continent IS NOT NULL 
AND total_cases IS NOT NULL
ORDER BY location


-- Total Number Of Countries Affected By Covid19 in the world

SELECT COUNT(*) AS Number_Countries 
FROM 
(
	SELECT DISTINCT location FROM CovidDeaths
		WHERE continent IS NOT NULL 
		AND total_cases IS NOT NULL
) 
AS country_count


-- Date Of First Case Reported For Each Country

SELECT location AS Country, MIN(date) AS FirstCaseReportedOn 
FROM CovidDeaths
WHERE continent IS NOT NULL 
AND total_cases IS NOT NULL
GROUP BY location
ORDER BY location


--Work with Covid Vaccinations Table

--Look at our Covid Vaccinations Table

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3, 4


--Join our two tables on location and date 

SELECT *
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
on d.location = v.location AND d.date=v.date
--ORDER BY 3, 4


-- Vaccination Start Date For All Countries

SELECT location AS Country, MIN(date) AS VaccinationStartedDate
FROM CovidProject..CovidVaccinations
WHERE continent IS NOT NULL 
AND total_vaccinations IS NOT NULL
AND total_vaccinations > 0 
GROUP BY location
ORDER BY VaccinationStartedDate


-- Vaccination Start Date For United States

SELECT location AS Country, MIN(date) AS VaccinationStartedDate
FROM CovidProject..CovidVaccinations
WHERE continent IS NOT NULL 
AND total_vaccinations IS NOT NULL 
AND total_vaccinations > 0 
AND location = 'United States'
GROUP BY location
ORDER BY VaccinationStartedDate

-- Calculate Vaccination vs Population by country and by date

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
on d.location = v.location AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3


-- Calculate Total Vaccination per day and country

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS TotalVaccines
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
on d.location = v.location AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3


-- Calculate  Percentage of Population that has received at least one Covid Vaccine by day and by country

-- By using CTE for calculation

With PopvsVac (continent, location, date, population, new_vaccinations, RollingSumVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingSUMVaccinated
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
on d.location = v.location AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingSumVaccinated/population)*100 AS VaccinePopulationPct
FROM PopvsVac

-- Calculate  Percentage of Population that as received at least one Covid Vaccine by day and by country
-- By using temporary table PctVaccinatedPopulation

DROP TABLE IF exists #PctPopulationVaccinated
CREATE TABLE #PctPopulationVaccinated
(
continent VARCHAR(50),
location VARCHAR(50),
date DATETIME,
population FLOAT,
new_vaccinations FLOAT,
RollingSUMVaccinated FLOAT
)

INSERT INTO #PctPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingSUMVaccinated
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
ON d.location = v.location AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, ROUND((RollingSUMVaccinated/population)*100, 2) AS VaccinePopulationPct
FROM #PctPopulationVaccinated

-- Create View to store data for visualizations

Create View PctPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingSUMVaccinated
FROM CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
ON d.location = v.location AND d.date=v.date
WHERE d.continent IS NOT NULL


-- VACCINATION ANALYSIS 
--DROP TABLE IF EXISTS #vaccination

WITH cte_vaccination (location, total_vaccinations, people_vaccinated, people_fully_vaccinated)
AS
(
	SELECT d.location,
	MAX(v.total_vaccinations),
	MAX(v.people_vaccinated),
	MAX(v.people_fully_vaccinated)
	FROM CovidProject..CovidDeaths d
    JOIN CovidProject..CovidVaccinations v
    on d.location = v.location AND d.date=v.date
	WHERE d.continent IS NOT NULL
	GROUP BY d.location
)
SELECT * INTO #vaccination
FROM cte_vaccination


-- TOP 10 countries with most people vaccinated 

SELECT TOP 10 location
FROM #vaccination
ORDER BY people_vaccinated DESC



-- COUNTRY DEMOGRAPHICS
--DROP TABLE IF EXISTS #country_demographics 

WITH cte_countryDemg(location, population, population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, human_development_index)
AS
(
	SELECT d.location, 
	MAX(d.population) AS population_max,
	MAX(v.population_density) AS Population_Density,
	MAX(v.median_age) AS Median_Age,
	MAX(v.aged_65_older) AS Aged_65_Older,
	MAX(v.aged_70_older) AS Aged_70_Older,
	MAX(v.gdp_per_capita) AS Gdp_Per_Capita,
	MAX(v.extreme_poverty) AS Extreme_Poverty,
	MAX(v.human_development_index) AS Human_Development_Index
	FROM CovidProject..CovidDeaths d
    JOIN CovidProject..CovidVaccinations v
    on d.location = v.location AND d.date=v.date
	WHERE d.continent IS NOT NULL
	GROUP BY d.location
)
SELECT * INTO #country_demographic 
FROM cte_countrydemg


-- TOP 10 countries with the highest demographics 

SELECT TOP 10 location
FROM #country_demographic
ORDER BY human_development_index DESC


-- TOP 10 countries with the lowest demographics

SELECT TOP 10 location
FROM #country_demographic
ORDER BY human_development_index ASC


-- COUNTRY HEALTH
--DROP TABLE IF EXISTS #country_health

WITH cte_countryHealth (location, population, Stringency_Index, Cardiovascular_Death_Rate, Diabetes_Prevalence, Female_Smokers, Male_Smokers, Life_Expectancy)
AS
(
	SELECT d.location,
	MAX(d.population) AS population,
	MAX(v.stringency_index) AS Stringency_Index,
	MAX(v.cardiovasc_death_rate) AS Cardiovascular_Death_Rate,
	MAX(v.diabetes_prevalence) AS Diabetes_Prevalence,
	MAX(v.female_smokers) AS Female_Smokers,
	MAX(v.male_smokers) AS Male_Smokers,
	MAX(v.life_expectancy) AS Life_Expectancy
	FROM CovidProject..CovidDeaths d
    JOIN CovidProject..CovidVaccinations v
    on d.location = v.location AND d.date=v.date
	WHERE d.continent IS NOT NULL
	--WHERE continent IS NOT NULLjf
	GROUP BY d.location
)
SELECT * INTO #country_health 
FROM cte_countryHealth


-- TOP 10 countries with the highest life expectancy 

SELECT TOP 10 location
FROM #country_health
ORDER BY life_expectancy DESC


-- TOP 10 countries with the lowest life expectancy 

SELECT TOP 10 location
FROM #country_health
ORDER BY life_expectancy ASC


-- CASES_SUMMARY: Look Total Cases, Total Deaths For Each Country
CREATE VIEW cases_sum AS
SELECT location AS Country, population, 
MAX(total_cases) AS Total_Cases, 
MAX(total_deaths) AS Total_Deaths,
MAX(total_cases)/population*100 AS Infected_Population_Pct, 
MAX(total_deaths)/population*100 AS Death_Population_Pct,   
MAX(total_deaths)/MAX(total_cases)*100 AS Death_Pct 
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL 
AND total_cases IS NOT NULL
GROUP BY location, population


-- Highest To Lowest Death Count
SELECT Country, population, Total_Deaths
FROM cases_sum
ORDER BY Total_Deaths DESC

-- Lowest to Highest Death Count
SELECT Country, population, Total_Deaths
FROM cases_sum
ORDER BY Total_Deaths ASC

