
/*

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY location,date


-- Data that I am going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location,date


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Serbia'
ORDER BY location,date


-- Looking at Total Cases vs Population
-- Shows what percentage got covid 

SELECT location, date, total_cases,  population,total_deaths, (total_cases/population)*100 as CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Serbia'
ORDER BY location,date


-- Looking at Countries with highest and lowest Infection rate compared to population

SELECT location, population, MAX(total_cases) as MaxNumberInfected, MAX((total_cases/population))*100 as CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL  -- Without continents
GROUP BY location, population
ORDER BY CovidInfectedPercentage DESC

SELECT location, population, MAX(total_cases) as MaxNumberInfected, MAX((total_cases/population))*100 AS CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL-- Without continents
GROUP BY location, population
ORDER BY CovidInfectedPercentage ASC



-- Number of deaths, countries

SELECT location, MAX(cast(total_deaths AS INT)) AS Number_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Number_Deaths DESC


-- Number of deaths, continets 

SELECT continent, MAX(cast(total_deaths AS INT)) AS Number_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Number_Deaths DESC


-- Numbers for the whole world 

SELECT date, SUM(new_cases) AS New_Cases, SUM(cast(new_deaths AS int)) AS New_death_cases
, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS Mortality_Rate

FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date


-- Show countries 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location 
, cast(dea.date AS datetime)) AS RollingNumberVaccine
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date


-- Using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingNumberVaccine)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location 
, cast(dea.date AS datetime)) AS RollingNumberVaccine 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingNumberVaccine/population)*100 AS Percent_Vaccines_Recieved
FROM PopVsVac


-- TEMP TABLE

DROP TABLE if exists #CalculatePercent
CREATE TABLE #CalculatePercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingNumberVaccine numeric
)

INSERT INTO #CalculatePercent
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location 
, cast(dea.date AS datetime)) AS RollingNumberVaccine
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingNumberVaccine/population)*100 as Percent_Vaccines_Recieved
FROM #CalculatePercent


-- Average and % number of people that got infected

DROP TABLE if exists #Table_Average
CREATE TABLE #Table_Average
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_cases numeric,
Rolling_Average_Infected float
)
INSERT INTO #Table_Average
SELECT continent, location, date, population, new_cases,
AVG(new_cases) OVER (PARTITION BY location ORDER BY date) AS Rolling_Average_Infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date


SELECT *, (Rolling_Average_Infected/population)*100 as Percent_Rolling_Average_Infected
FROM #Table_Average


-- Creating View to store data for later visualizations || change from master to PortfolioProject!

CREATE VIEW CalculatePercent 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location 
, cast(dea.date AS datetime)) AS RollingNumberVaccine
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
