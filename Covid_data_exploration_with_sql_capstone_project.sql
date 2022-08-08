SELECT *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--select useful data

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--% of deaths
--chance of people dying from covid in their country from the 
--and to query data from United States

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as percent_pop_Percent
From PortfolioProject..CovidDeaths$
WHERE location like '%States'
and continent is not null
order by 1,2

--Calculating the percentage of population with covid infection
SELECT Location, date, total_cases, population, (total_deaths/population)*100 as DeathPercent
From PortfolioProject..CovidDeaths$
WHERE location like '%States'
order by 1,2

--quering the countries with the highest infection rate compared to population.
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopInfected
From PortfolioProject..CovidDeaths$
--WHERE location like '%States'
where continent is not null
Group by Location, Population
order by PercentofPopInfected desc

--showing countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--WHERE location like '%States'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Breaking things down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--WHERE location like '%States'
where continent is null
Group by Location
order by TotalDeathCount desc

--showing the continents with the highest death counts
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--WHERE location like '%States'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Breaking global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeatPercent
From PortfolioProject..CovidDeaths$
--WHERE location like '%States'
where continent is not null
Group By date
order by 1,2


--Looking at Vaccination Data and performing joins. Here looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Use CTE

with PopvsVac (Continent, location, Date, Population, New_Avccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating views to store data for future visualization

Create View TotalDeaths as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--WHERE location like '%States'
where continent is not null
Group by continent
--order by TotalDeathCount desc

--calling the created view
select *
from TotalDeaths

