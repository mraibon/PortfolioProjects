/* select *
  from PortfolioProject.dbo.CovidDeaths$
 order by 3,4

 select *
  from PortfolioProject.dbo.CovidVaccinations$
 order by 3,4 */
select Location, date, total_cases, new_cases, total_deaths, population
  from PortfolioProject..CovidDeaths$
 order by 1,2

--Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
  from PortfolioProject..CovidDeaths$
 where location like '%states%'
 order by 1,2

-- Looking at Total cases vs. Population
-- Shows what percentage of population got Covid

select Location, date, Population, total_cases, (total_cases/ population)*100 as PercentofPopulationInfected
  from PortfolioProject..CovidDeaths$
 where location like '%states%'
 order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentofPopulationInfected
  from PortfolioProject..CovidDeaths$
 group by Location, Population
 order by 4 desc

-- Showing Countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths$
 where continent is not null
 group by Location
 order by 2 desc

-- LETS BREAK THINGS DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths$
 where continent is not null
 group by continent
 order by 2 desc

Select location, max(cast(total_deaths as int)) as TotalDeathCount
  from PortfolioProject..CovidDeaths$
 where continent is null
 group by location
 order by 2 desc

-- GLOBAL NUMBERS

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from PortfolioProject..CovidDeaths$
 where continent is not null
 order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent
     , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent
     , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *
     , (RollingPeopleVaccinated/Population) * 100
  from PopVsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent
     , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

Select *
     , (RollingPeopleVaccinated/Population) * 100
  from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent
     , dea.location
	 , dea.date
	 , dea.population
	 , vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

