

SELECT *
FROM portfolioProject..covidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Selecting needed columns 
SELECT location, date, total_cases, total_deaths, population
FROM portfolioProject..covidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Checking total cases vs total deaths
-- Shows how possible it is to die if contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as Deathpercentage
FROM portfolioProject..covidDeath
WHERE continent IS NOT NULL
ORDER BY 2 DESC;

-- Looking at total cases vs Population
SELECT location, date, total_cases, (total_cases/population) *100 as PopulationInfected
FROM portfolioProject..covidDeath
ORDER BY 2 DESC;

-- Looking at Countries to Highest Infection Rate compared to population
SELECT location, MAX(total_cases) as max_totalCasesCount, population, MAX((total_cases/population) )*100 as max_PopulationInfected
FROM portfolioProject..covidDeath
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) as max_totalDeathsCount
FROM portfolioProject..covidDeath
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY 2 DESC;


-- Showing continent with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) as max_totalDeathsCount
FROM portfolioProject..covidDeath
WHERE continent IS  NULL AND location != 'World'AND location != 'High income' AND location != 'Upper middle income'
AND location != 'Low income' AND location != 'International' AND location != 'Lower middle income'
GROUP BY location
ORDER BY 2 DESC


-- Global numbers

SELECT  SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS INT)) as total_deaths ,SUM(CAST( new_deaths AS INT))/SUM(new_cases) * 100 as GlobalDeathpercentage
FROM portfolioProject..covidDeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1 ;


-- looking at total population vs vacination
SELECT cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST (cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) 
as RollingPeopleVaccinated
FROM portfolioProject..covidDeath cd
JOIN portfolioProject..covidVaccination cv
	on cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 1,2,3

-- USING CTE

WITH PopvsVac (continent, location, date, population,new_vaccination, RollingPeopleVaccinated)


as(

SELECT cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST (cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) 
as RollingPeopleVaccinated
FROM portfolioProject..covidDeath cd
JOIN portfolioProject..covidVaccination cv
	on cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 1,2,3
)

SELECT *, ( RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Creating views for visualisations
CREATE  View PopvsVac as
SELECT cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
SUM(CAST (cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) 
as RollingPeopleVaccinated
FROM portfolioProject..covidDeath cd
JOIN portfolioProject..covidVaccination cv
	on cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *
FROM PopvsVac