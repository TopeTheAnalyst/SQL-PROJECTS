select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--looking at total  cases vs total deaths
-- shows likelihood of dying if you have covid in Nigeria

Select location, date, total_cases,total_deaths, 
(total_deaths / total_cases) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like '%nigeria%'
Order by 1,2

--looking at total cases vs population 
--shows what percentage of population got covid

Select location, date, population,total_cases,
(total_cases / population) * 100 AS PercentofPopulationAffected
from PortfolioProject..covidDeaths
--where location like '%nigeria%'
Order by 1,2

--looking at countries with highest infection rate compared to population

Select location, population,max (total_cases)as HighestInfectionCount,
(total_cases/population)* 100 AS PercentofPopulationAffected
from PortfolioProject..covidDeaths
--where location like '%nigeria%'
group by location, population,total_cases
Order by PercentofPopulationAffected desc

--showing countries with the highest death count per population

Select location,max (total_deaths)as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%nigeria%'
group by location
Order by TotalDeathCount

--BREAKING THINGS DOWN BY CONTINENT

--showing continents with highest death

Select continent,max (total_deaths)as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases, sum(new_deaths)as total_deaths,
sum(new_deaths) / sum (new_cases) * 100 AS DeathPercentage
from CovidDeaths 
--where location like '%nigeria%'
where continent is not null
group by date
Order by 1,2

--Looking at total population vs vaccination

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location,date , population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations ) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100 as PerecentagePopulationVaccinated
from #PercentPopulationVaccinated


----creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

