/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT *
FROM covidDeaths c
Where continent is not null
order by 3,4 


SELECT *
FROM covidvaccinations 
order by 3,4 

-- Select Data that we are going to be using

Select location, date , total_cases, new_cases, total_deaths, population
From covidDeaths 
order by 1,2 


-- looking at Total Cases vs. Total Deaths
--shows the likelihood of dying if you contract covid in your country

Select location, date , total_cases, total_deaths, (total_deaths*1.0 / total_cases) *100 as DeathPercentage
From covidDeaths cd
Where location like '%states%'
and DeathPercentage is not null
order by 1,2 

--Looking at Total Cases vs. Population
--shows what percentage of population got Covid
Select location, date , total_cases, population , (total_cases *1.0 / population) *100 as PercentPopulationInfected
From covidDeaths cd
Where location like '%states%'
order by 1,2 

--Looking at countries with Highest Infection Rates compared to population

Select location, date , MAX(total_cases*1.0) as HighestInfectionCount, population , MAX((total_cases *1.0 / population)) *100 as PercentPopulationInfected
From covidDeaths cd
--Where location like '%states%'
GROUP BY location, population 
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covidDeaths cd
--Where location like '%states%'
WHERE location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union')
GROUP BY location
order by TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From covidDeaths cd
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL AND continent != '' AND continent != ' '
GROUP BY continent 
order by TotalDeathCount DESC




--GLOBAL Numbers

Select  SUM(new_cases)*1.0 as total_cases , SUM(new_deaths) as total_deaths , SUM(new_deaths)/sum(new_cases)*100 as DeathPercentage-- , total_cases, total_deaths, (total_deaths*1.0 / total_cases) *100 as DeathPercentage
From covidDeaths 
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date 
order by 1,2 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations *1.0) OVER (PARTITION by dea.location ORDER by dea.location , 
 	dea.Date) as RollingPeopleVaccinated 
--,	(RollingPeopleVaccinated/population)*100 
From covidDeaths dea
Join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null AND dea.continent != '' 
order by 1,2




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVAC (continent,location,date,population, new_vaccinations,RollingPeopleVaccinated)
as(
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations *1.0) OVER (PARTITION by dea.location ORDER by dea.location , 
 	dea.Date) as RollingPeopleVaccinated 
--,	(RollingPeopleVaccinated/population)*100 
From covidDeaths dea
Join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null AND dea.continent != '' 
--order by 1,2

)
Select * , (RollingPeopleVaccinated/population)*100
FROM PopvsVAC



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated (
Continent TEXT,
Location TEXT,
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated (
Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated
)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INTEGER)) OVER (
PARTITION BY dea.Location ORDER BY dea.location, dea.Date
) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *,
(RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated_new; 
CREATE VIEW PercentPopulationVaccinated_new (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INTEGER)) OVER (
PARTITION BY dea.Location ORDER BY dea.location, dea.Date
) AS RollingPeopleVaccinated
FROM 
	CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated_new;





