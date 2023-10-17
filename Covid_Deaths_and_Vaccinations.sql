 SELECT *
 FROM PortfolioProjects..CovidDeaths
 WHERE continent IS NOT NULL

-- Selecting data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%Turkey%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS populationPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%Turkey%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_infection_count, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC ;


-- Showing countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC ;

-- Let's do things for continents also

-- Showing the world and continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC ;


-- GLOBAL NUMBERS

-- By Date
SELECT  date, SUM(new_cases) as global_cases, SUM( CAST(new_deaths AS INT)) as global_deaths, ( SUM( CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentByDate
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- General Total

SELECT SUM(new_cases) as global_cases, SUM( CAST(new_deaths AS INT)) as global_deaths, ( SUM( CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentByDate
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--USE CTE

-- Looking at total population vs vaccinations


WITH PopvsVac (continent, location, date, population, new_vaccinations, total_vacci_so_far)
AS (
SELECT death.continent, death.location, death.date, death.population, vacci.new_vaccinations,
SUM(CONVERT(INT,vacci.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS total_vacci_so_far
FROM PortfolioProjects..CovidDeaths AS death
JOIN PortfolioProjects..CovidVaccinations AS vacci
ON  death.location = vacci.location AND death.date = vacci.date
WHERE death.continent IS NOT NULL
--ORDER BY 2.3
)

Select *, (total_vacci_so_far/population)*100 AS vacciPercent
FROM PopvsVac


--Creating view to store data for later visualizations

CREATE VIEW vacciPercentByCountry AS
SELECT death.continent, death.location, death.date, death.population, vacci.new_vaccinations,
SUM(CONVERT(INT,vacci.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS total_vacci_so_far
FROM PortfolioProjects..CovidDeaths AS death
JOIN PortfolioProjects..CovidVaccinations AS vacci
ON  death.location = vacci.location AND death.date = vacci.date
WHERE death.continent IS NOT NULL
--ORDER BY 2.3

--Ups! Wrong name for our view, so we need to change it.

EXEC sp_rename 'vacciPercentByCountry', 'totalVaccinationSoFar'

