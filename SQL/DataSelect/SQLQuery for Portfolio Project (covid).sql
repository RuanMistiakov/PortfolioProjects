SELECT * FROM CovidDeaths
order by 3,4

--SELECT * FROM CovidVaccinations
--order by 3,4

--SELECT Data that we are going to be using

SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows probability of dying if contract Covid in Russia
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Russia%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population) * 100 as InfectedPercentage
FROM CovidDeaths
WHERE location like '%Russia%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
-- Showing Countries with Highest Infection per Population
SELECT
	location,
	population,
	MAX(total_cases) as HighestInfectionCount,
	MAX(total_cases/population) * 100 as InfectedPercentage
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY InfectedPercentage desc


-- Showing Countries with Highest Death Count per Population
SELECT
	location,
	MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing Continents with Highest Death Count per Population
SELECT
	continent,
	MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers
-- Shows Global death percentage
SELECT
	date,
	SUM(cast(new_cases as float)) as total_cases,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2


-- Showing Total Population vs Vaccinations
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CountryPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Using CTE to show percent of vaccinated people in country
WITH PopulationVSVaccination (continent, location, date, population, new_vaccinations, CountryPeopleVaccinated)
as (
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CountryPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT
	*,
	(CountryPeopleVaccinated / population) * 100 as VaccinationPercentage
FROM PopulationVSVaccination


-- Creating view to store data for visualization
CREATE VIEW PercentPopulationVaccinted as
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CountryPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT * FROM PercentPopulationVaccinted