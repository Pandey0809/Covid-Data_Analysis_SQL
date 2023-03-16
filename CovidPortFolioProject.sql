select * FROM 
PortfolioProject.CovidDeaths cd 
WHERE continent is not NULL 
and continent <> ''
order by 3,4 DESC;

-- select * FROM 
-- PortfolioProject.CovidVaccinations cv  
-- order by 3,4 DESC;

-- select data we are going to use
SELECT 
	location, `date`, total_cases ,new_cases ,total_deaths ,population 
from 
	PortfolioProject.CovidDeaths cd 
order by 
	1,2 DESC;
	
-- Total cases vs Total deaths percentage
-- Shows likelihood of dying if you contract covid
SELECT 
	location,
	`date`,
	total_cases,
	total_deaths,
	ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL  
	AND
	location like '%INDIA%'
order by 
	1,2 DESC;
	

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT 
	location,
	`date`,
	total_cases,
	population ,
	ROUND((total_cases /population)*100,2) as PopulationPercentage
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL  
	AND
	location like '%INDIA%'
order by 
	5 DESC ;


-- Looking at countries with the heighest infection rate compared to the population
SELECT 
	location,
	MAX(total_cases) as HeighestInfectionCount,
	ROUND(MAX((total_cases /population)*100),2) as PercentOfPopulationInfected
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL  
group by location, population  
order by PercentOfPopulationInfected DESC 
	;

-- Looking at countries with the heighest death count per population
SELECT 
	location,
	MAX(total_deaths) as TotalDeathCount
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL  
	AND 
	continent is not NULL 
	and continent <> ''
group by location
order by TotalDeathCount DESC 
	;

-- Looking at countries with the heighest death count by Continent
SELECT 
	continent,
	MAX(total_deaths) as TotalDeathCount
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL  
	AND continent is not NULL 
group by continent 
order by TotalDeathCount DESC 
	;


-- Global Numbers
SELECT 
	`date`,
	SUM(new_cases) as total_cases ,
	SUM(new_deaths) as total_deaths ,
	SUM(new_deaths)/SUM(new_cases)*100  
	-- total_deaths,
	-- ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL 
	GROUP by `date` 
order by 
	1,2 DESC;

SELECT 
	SUM(new_cases) as total_cases ,
	SUM(new_deaths) as total_deaths ,
	SUM(new_deaths)/SUM(new_cases)*100  
	-- total_deaths,
	-- ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
from 
	PortfolioProject.CovidDeaths cd
where 
	total_cases IS NOT NULL  
	AND 
	total_deaths  IS NOT NULL 
  -- GROUP by `date` 
order by 
	1,2 DESC;

-- Looking at total population vs Vaccination
-- USE CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
SELECT 
	cd.continent,
	cd.location ,
	cd.`date` ,
	cd.population ,
	cv.new_vaccinations,
	SUM(CONVERT(cv.new_vaccinations, SIGNED INTEGER)) over (PARTITION by cd.location order by cd.location, cd.`date`) as RollingVaccinated
	-- ,(RollingVaccinated/population)*100
from 
	PortfolioProject.CovidDeaths cd
join PortfolioProject.CovidVaccinations cv 
	on (cd.location=cv.location
		AND
		cd.`date`=cv.`date`)
		AND cd.continent is not NULL 
-- order by 2,3
)
SELECT *,
	(RollingPeopleVaccinated/Population)*100
from PopvsVac;



-- TEMP TABLE
DROP TEMPORARY TABLE IF EXISTS PercentPeopleVaccinated;
Create Table PercentPeopleVaccinated
 (Continent varchar(255) 
,Location varchar(255) 
,Date date 
,Population numeric 
,New_Vaccinations numeric 
,RollingPeopleVaccinated numeric )


INSERT INTO PercentPeopleVaccinated
SELECT 
	cd.continent,
	cd.location ,
	cd.`date` ,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(FLOOR(cv.new_vaccinations), SIGNED INTEGER)) over (PARTITION by cd.location order by cd.location, cd.`date`)  as RollingVaccinated
from 
	PortfolioProject.CovidDeaths cd
join PortfolioProject.CovidVaccinations cv 
	on (cd.location=cv.location
		AND
		cd.`date`=cv.`date`)
WHERE cd.continent is not NULL 
	AND cd.continent <> ''
	AND cv.new_vaccinations IS NOT NULL
;

SELECT * FROM PercentPeopleVaccinated;

SELECT *,
	(RollingPeopleVaccinated/Population)*100
from PercentPeopleVaccinated;

-- Creating view to store data for later visualization 
CREATE VIEW PercentagePopulationVaccinated as
SELECT 
	cd.continent,
	cd.location ,
	cd.`date` ,
	cd.population,
	CONVERT(cv.new_vaccinations, SIGNED INTEGER) as new_vaccinations,
	SUM(CONVERT(FLOOR(cv.new_vaccinations), SIGNED INTEGER)) over (PARTITION by cd.location order by cd.location, cd.`date`)  as RollingVaccinated
from 
	PortfolioProject.CovidDeaths cd
join PortfolioProject.CovidVaccinations cv 
	on (cd.location=cv.location
		AND
		cd.`date`=cv.`date`)
WHERE cd.continent is not NULL 
	AND cd.continent <> ''
	AND cv.new_vaccinations IS NOT NULL
;
DROP VIEW PercentagePopulationVaccinated;



	