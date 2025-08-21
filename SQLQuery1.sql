SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4



--Select Data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--looking at total cases and total deaths

--Shows likelihood of dying if you contract covide in your country 
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%germany%'
ORDER BY 1,2

--Looking at Total Cases vs Poplutaion 

--Shows what percentage of population got Covid 
SELECT location, date, population,total_cases , (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%germany%'
AND continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Poplution 
SELECT location, MAX(cast(total_cases as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT  

--Showing continents with the highest death count per population.
SELECT Continent, MAX(cast(total_cases as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc


-- Average gobal numbers of deaths in the world.
SELECT Date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, 
	SUM(cast(new_deaths as int))/SUM (new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations 

SELECT dea.Continent,dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
	,SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Use CTE 
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent,dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
	,SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac; 


--TEMP Table

DROP table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.Continent,dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
	,SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View for data Visualization 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.Continent,dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
	,SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location
	,dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated