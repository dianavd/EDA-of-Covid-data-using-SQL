-- EDA Project on Covid dataset, using SQL 
--( Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types) 

--Look at our Covid Deaths Table

Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3, 4 


--Look at our Covid Vaccinations Table

Select *
From CovidProject..CovidVaccinations
Order by 3, 4


-- For future analysis assign Null to empty cells in column 'Continent'

Update CovidProject..CovidDeaths
Set 
continent = NULL WHERE continent = ''


-- For future analysis change datatype of columns total_cases and total_deaths from varchar to integer

ALTER TABLE CovidDeaths ALTER COLUMN date datetime
ALTER TABLE CovidDeaths ALTER COLUMN population bigint
ALTER TABLE CovidDeaths ALTER COLUMN total_cases float
ALTER TABLE CovidDeaths ALTER COLUMN new_cases float
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths float


-- Look a few columns in Table CovidDeaths

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is null
Order by 1, 2


-- Calculate Death Percentage as Total Deaths/Total Cases*100  by date and by country

Select location, date, total_cases, total_deaths, Round(100*total_deaths/NULLIF(total_cases,0),2) as DeathPercentage
From CovidProject..CovidDeaths
Where continent is null
Order by 1, 2


-- Calculate Death Percentage from Covid in The USA by date

Select location, date, total_cases, total_deaths, Round(100*total_deaths/NULLIF(total_cases,0),2) as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1, 2


-- Calculate Total Cases vs Population

-- Calculate what percentage of population got Covid

Select location, date, total_cases, population, Round(100*total_cases/NULLIF(population,0),2) as PrecentPopulationCovid
From CovidProject..CovidDeaths
--Where continent is  not null
Order by 1, 2


-- Show what percentage of population got Covid in The USA by date

Select location, date, total_cases, population, Round(100*total_cases/NULLIF(population,0),2) as PrecentPopulationGotCovid
From CovidProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1, 2


-- Find countries with the highest Covid case numbers compared to population percentage

Select location, population, max(total_cases) as HighestCovidRate, max(Round(100*total_cases/NULLIF(population,0),2)) as PrecentPopulationGotCovid
From CovidProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by PrecentPopulationGotCovid DESC


-- Find countries with the highest death to population percentage

Select location, population, max(total_deaths) as HighestDeathRate, max(Round(100*total_deaths/NULLIF(population,0),2)) as PrecentPopulationDeath
From CovidProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by PrecentPopulationDeath DESC


-- Find countries with the highest total death counts

Select location, max(total_deaths) as HighestDeathRate
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by HighestDeathRate DESC


-- Find continents with the highest total death counts

Select continent, max(cast(total_deaths as int)) as HighestDeathRate
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathRate DESC


-- Worldwide Covid statistics

-- Calculate total new Covid cases  and deaths from Covid per day worldwide

Select date, sum(new_cases) as TotalCovidCases, sum(cast (new_deaths as float)) as TotalCovidDeaths, Round(100*sum(cast(new_deaths as float))/NULLIF(sum(new_cases),0),2) as PrecentPopulDeathCovid
From CovidProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2


-- Calculate total new Covid cases  and deaths from Covid worldwide

Select sum(new_cases) as TotalCovidCases, sum(convert(float, new_deaths)) as TotalCovidDeaths, Round(100*sum(cast(new_deaths as float))/NULLIF(sum(new_cases),0),2) as PrecentPopulDeathCovid
From CovidProject..CovidDeaths
Where continent is not null
Order by 1, 2


--Work with Covid Vaccinations Table

--Look at our Covid Vaccinations Table

select *
from CovidProject..CovidVaccinations
order by 3, 4


-- Change datatype of columns total_cases and total_deaths from varchar to integer

ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN date datetime
ALTER TABLE CovidProject..CovidVaccinations ALTER COLUMN new_vaccinations float

--Join our two tables on location and date 

select *
From CovidProject..CovidDeaths d
Join CovidProject..CovidVaccinations v
On d.location = v.location and d.date=v.date
--order by 3, 4


-- Calculate Vaccination vs Population by country and by date

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
From CovidProject..CovidDeaths d
Join CovidProject..CovidVaccinations v
On d.location = v.location and d.date=v.date
Where d.continent is not null
Order by 2, 3


-- Calculate Total Vaccination per day and country

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as TotalVaccines
From CovidProject..CovidDeaths d
Join CovidProject..CovidVaccinations v
On d.location = v.location and d.date=v.date
Where d.continent is not null
Order by 2, 3


-- Calculate  Percentage of Population that has received at least one Covid Vaccine by day and by country

-- By using CTE for calculation

With PopvsVac (continent, location, date, population, new_vaccinations, RollingSumVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingSumVaccinated
From CovidProject..CovidDeaths d
Join CovidProject..CovidVaccinations v
On d.location = v.location and d.date=v.date
Where d.continent is not null
--Order by 2, 3
)
select *, (RollingSumVaccinated/population)*100 as VaccinePopulationPct
From PopvsVac

-- Calculate  Percentage of Population that has received at least one Covid Vaccine by day and by country
-- By using temporary table PctVaccinatedPopulation

Drop Table if exists #PctPopulationVaccinated
Create Table #PctPopulationVaccinated
(
continent varchar(50),
location varchar(50),
date datetime,
population float,
new_vaccinations float,
RollingSumVaccinated float
)

Insert into #PctPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingSumVaccinated
From CovidProject..CovidDeaths d
Join CovidProject..CovidVaccinations v
On d.location = v.location and d.date=v.date
Where d.continent is not null
--Order by 2, 3

select *, Round((RollingSumVaccinated/population)*100, 2) as VaccinePopulationPct
From #PctPopulationVaccinated

-- Create View to store data for visualizations

Create View PctPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingSumVaccinated
From CovidProject..CovidDeaths d
Join CovidProject..CovidVaccinations v
On d.location = v.location and d.date=v.date
Where d.continent is not null


