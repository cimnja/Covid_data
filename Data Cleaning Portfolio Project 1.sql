Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4



SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continet is not null
ORDER BY 1, 2

--Total cases vs Total Deaths (likelihood of death if infected in a specific country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%denma%'
AND continent is not null
ORDER BY 1, 2


--Total cases vs population (what % of population is infected)

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%denma%'
ORDER BY 1, 2


--Highest infection rate compated to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%denma%'
GROUP BY location, population
ORDER BY InfectedPercentage DESC


--Highest death count per population 

SELECT location, population, MAX(cast(total_deaths as bigint)) AS TotalDeathCount, MAX((total_deaths/population))*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%denma%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Breaking data down by continet 

--Continents with highest death count per population

SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%denma%'
WHERE continent is null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global numbers 

SELECT DATE, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) as 'Total Deaths', 
			SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%denma%'
WHERE continent is not null 
GROUP BY date 
ORDER BY 1, 2


--Total population vs Vaccinations (% of population that recieved at least one vaccine)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
and		dea.date = vac.date
--WHERE dea.continent is not null 
WHERE vac.new_vaccinations is not null AND vac.continent is not null 
ORDER BY 1, 2, 3






---USE CTE

WITH PopVac (Continent, Locatio, Date, Population, New_Vaccinations, PeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated 

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
AND		dea.date = vac.date
--WHERE dea.continent is not null 
WHERE vac.new_vaccinations is not null AND vac.continent is not null 
)

SELECT *, (PeopleVaccinated/Population)*100 
FROM PopVac




--Temp Table 

 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar (225),
 Location nvarchar (225),
 Date datetime, 
 Population numeric, 
 New_vaccinations numeric, 
 PeopleVaccinated numeric
 )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated 

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
AND		dea.date = vac.date
--WHERE dea.continent is not null 
--WHERE vac.new_vaccinations is not null AND vac.continent is not null 

SELECT *, (PeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating view 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated 

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
AND		dea.date = vac.date
WHERE vac.new_vaccinations is not null AND vac.continent is not null 
--ORDER BY 2, 3




SELECT*
FROM PercentPopulationVaccinated 
