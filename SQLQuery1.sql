--SELECT *
--FROM CovidDeaths$

----SELECT *
----FROM CovidVaccinations

---- SELECT data that i am going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1, 2

-- looking at Total cases vs Total deaths
-- shows likelihood of dying if one contracts covid in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathperc
FROM CovidDeaths$
WHERE location  = 'India'
ORDER BY 2 DESC , Deathperc DESC;

-- Looking at total cases vs population
--shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Covidperc
FROM CovidDeaths$
WHERE location  = 'India'
ORDER BY 2 ;

-- looking at countries with highest infection rate compared to pouplation
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
MAX(total_cases/population)*100 AS infection_count
FROM CovidDeaths$
GROUP BY location, population
ORDER BY infection_rate DESC

--showing the countries with the highest death count per population
SELECT location, population, MAX(CAST(total_deaths AS int)) AS highest_death_count, 
MAX(total_deaths/population)*100 AS death_count
FROM CovidDeaths$
GROUP BY location, population
ORDER BY death_count DESC;

-- only countries with continents filtered out
SELECT location, MAX(CAST(total_deaths AS int)) AS most_deaths
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY most_deaths DESC

-- Lets break things down by Continent
SELECT location, MAX(CAST(total_deaths AS int)) AS most_deaths
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY most_deaths DESC

-- Global numbers by date
SELECT date, 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_per_cases_perc
-- total_deaths, (total_deaths/total_cases)*100 AS Deathperc
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- overall world death_per_cases_perc
SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_per_cases_perc
-- total_deaths, (total_deaths/total_cases)*100 AS Deathperc
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 


-- looking at total population vs vaccinations

SELECT cd.continent, 
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations ,
		SUM(CAST(cv.new_vaccinations AS int)) 
				OVER(PARTITION BY cd.location
					  ORDER BY cd.location, cd.date) AS running_total_vaccinated
FROM CovidDeaths$ AS cd
INNER JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL
ORDER BY 2,3

--Using CTE

WITH PopvsVac As 
(
SELECT cd.continent, 
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations ,
		SUM(CAST(cv.new_vaccinations AS int)) 
				OVER(PARTITION BY cd.location
					  ORDER BY cd.location, cd.date) AS running_total_vaccinated
FROM CovidDeaths$ AS cd
INNER JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL
)

SELECT *, 
	(running_total_vaccinated/population)*100
FROM PopvsVac


--Using Temp table

DROP TABLE IF EXISTS Tablename
CREATE TABLE Tablename
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
running_total_vaccinated  numeric
)

INSERT INTO Tablename
SELECT cd.continent, 
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations ,
		SUM(CAST(cv.new_vaccinations AS int)) 
				OVER(PARTITION BY cd.location
					  ORDER BY cd.location, cd.date) AS running_total_vaccinated
FROM CovidDeaths$ AS cd
INNER JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL

SELECT *, 
	(running_total_vaccinated/population)*100
FROM Tablename

-- creating view to store data for later visualizations

CREATE VIEW popvaccperc AS
SELECT cd.continent, 
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations ,
		SUM(CAST(cv.new_vaccinations AS int)) 
				OVER(PARTITION BY cd.location
					  ORDER BY cd.location, cd.date) AS running_total_vaccinated
FROM CovidDeaths$ AS cd
INNER JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL

SELECT * 
FROM popvaccperc