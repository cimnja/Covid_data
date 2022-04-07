Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


--Select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION 
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Total cases vs Total Deaths 

SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%DENMA%'
ORDER BY 1, 2


--Total cases vs population 

SELECT LOCATION, DATE, population, TOTAL_CASES, (total_cases/population)*100 as InfectedPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%DENMA%'
ORDER BY 1, 2


--Highest infection rate 

SELECT LOCATION, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%DENMA%'
GROUP BY LOCATION, population
ORDER BY InfectedPercentage DESC


--Highest death count per population 

SELECT LOCATION, population, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount, MAX((total_deaths/population))*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%DENMA%'
WHERE continent is not null
GROUP BY LOCATION, population
ORDER BY TotalDeathCount DESC


--By continet 

SELECT location, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%DENMA%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC



--Global numbers 

SELECT DATE, SUM(NEW_CASES) as TotalCases, SUM(CAST(new_deaths as bigint)) as 'Total Deaths', 
			SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%DENMA%'
WHERE continent is not null 
GROUP BY date 
ORDER BY 1, 2


--Total population vs Vaccinations 

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
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
and		dea.date = vac.date
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
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
and		dea.date = vac.date
--WHERE dea.continent is not null 
--WHERE vac.new_vaccinations is not null AND vac.continent is not null 

SELECT *, (PeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating view 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated 

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location
and		dea.date = vac.date
WHERE vac.new_vaccinations is not null AND vac.continent is not null 
--ORDER BY 2, 3




SELECT*
FROM PercentPopulationVaccinated 
