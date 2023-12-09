select *
from Covidvaccis
order by 3,4

select *
from CovidDeats
order by 3,4

select location,date,total_cases,new_cases,total_deaths,new_deaths,population
from coviddeats
order by 1,2

--checking total cases and total deaths by percentage, a likelihood of death cases by location
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeats
where location like '%africa%'
order by 1,2

---checking total cases by population
select location,date,population,total_cases,(total_cases/population)*100 as deathpercentage
from coviddeats
--where location like '%africa%'
order by 1,2

--checking highest infection cases by country
select location,population,max(total_cases) as infectionrate,max(total_cases/population)*100 as infectionheight
from coviddeats
--where location like '%africa%'
group by location, population
order by 1,2

select location,population,max(total_cases) as infectionrate,max(total_cases/population)*100 as infectionheight
from portfolioproject..coviddeats
where continent is not null
group by location, population
order by 1,2

--CHECKING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location,max(CAST(total_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM portfolioproject..coviddeats
where continent is not null
group by location
order by TOTALDEATHCOUNT DESC

select location,max(total_DEATHS) AS TOTALDEATHCOUNT
FROM portfolioproject..coviddeats
where continent is not null
group by location
order by TOTALDEATHCOUNT DESC

select location,max(CAST(total_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM portfolioproject..coviddeats
--where continent is not null
where continent is null
group by location
order by TOTALDEATHCOUNT DESC

--checking contitnents with the highest death count per population
select continent,max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeats
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeats
where continent is not null
order by 1,2

select *
from PortfolioProject..CovidDeats as dea
join PortfolioProject..CovidVaccis as vac
	on dea.location = vac.location
	and dea.date = vac.date

--checking total population vs vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)
from PortfolioProject..CovidDeats as dea
join PortfolioProject..CovidVaccis as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeats as dea
join PortfolioProject..CovidVaccis as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE
with popvsvac(continent,location,date,population,new_vacinnations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)
from PortfolioProject..CovidDeats as dea
join PortfolioProject..CovidVaccis as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *
from popvsvac

with popvsvac(continent,location,date,population,new_vacinnations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)
from PortfolioProject..CovidDeats as dea
join PortfolioProject..CovidVaccis as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--TEMP TABLE
drop table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated
(continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVacinated
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeats dea
join PortfolioProject..CovidVaccis vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVacinated

--Creating View to Store Data for Visualizing
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVacinated
from PortfolioProject..coviddeats dea
join PortfolioProject..covidVaccis vac
	on dea.location = Vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *
from percentpopulationvaccinated