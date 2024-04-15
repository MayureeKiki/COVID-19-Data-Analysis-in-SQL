select*
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths
-- shows likelihood og dying if you contract covid in your country
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentag
from CovidDeaths
where location like '%state%'
order by 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentagPopulationInfected
from CovidDeaths
--where location like '%state%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compare to Population
Select location, MAX(total_cases) as HighestInfectionCount, population, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentagPopulationInfected
from CovidDeaths
Group by location, population
order by PercentagPopulationInfected desc

-- Showing Countries with Highest Deaths Count per Population
Select location, MAX(total_deaths) as HighestDeathsCount, population, 
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentagPopulationDeaths
from CovidDeaths
Group by location, population
order by PercentagPopulationDeaths desc

-- Let's break thing down by continent 
Select continent, MAX(CONVERT(float,total_deaths)) as TotalDeathsCount
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

Select location, MAX(CONVERT(float,total_deaths)) as TotalDeathsCount
from CovidDeaths
where continent is null
Group by location
order by TotalDeathsCount desc


--Showing contitents with highest death count per population

Select continent, MAX(CONVERT(float,total_deaths)) as TotalDeathsCount
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

-- Global Numbers

Select SUM(convert(int,new_cases)) as TotalCases 
, SUM(convert(int,new_deaths)) as TotalDeaths
, SUM(convert(float,new_deaths))/ Nullif(SUM(convert(float,new_cases)), 0) * 100 as DeathPercentage
from CovidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2


-- Looking at total Population vs Vaccinations

select dea.continent, dea.location
, dea.date, population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by convert(nvarchar(50),dea.location), convert(nvarchar(50),dea.date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea 
join CovidVaccinaton vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
Order by 2,3

-- USE CTE 

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location
, dea.date, population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by convert(nvarchar(50),dea.location), convert(nvarchar(50),dea.date)) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinaton vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Lacation nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location
, dea.date, population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) 
OVER (Partition by dea.location 
Order by convert(nvarchar(50), dea.location)
, convert(nvarchar(50),dea.date)) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinaton vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- Creating View to Store data for later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location
, dea.date, population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) 
OVER (Partition by dea.location 
Order by convert(nvarchar(50), dea.location)
, convert(nvarchar(50),dea.date)) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinaton vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
--Order by 2,3

Select*
From PercentPopulationVaccinated