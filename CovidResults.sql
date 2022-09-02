
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at total cases vs total deaths
--likelihood of contracting covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Africa%' and continent is not null
ORDER BY 1,2

--looking at total cases vs population
--shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
ORDER BY 1,2

--looking at countries with higest infection rate compared to population
SELECT continent, population, MAX(total_cases) as highest_infection_Count, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
GROUP BY continent, population
ORDER BY PercentPopulationInfected desc

--showing continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

--Global numbers
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2

SELECT date,SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Africa%'
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--TEMP Table

CREATE TABLE #PercentPopulationVaccinated(

Continent nvarchar,
Location nvarchar,
date datetime, 
Population numeric,
New_vaccionations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageOfPeopleVaccin
FROM #PercentPopulationVaccinated


--Creating View to Store data for Later Visualization

Create View PercentPopulationVaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3