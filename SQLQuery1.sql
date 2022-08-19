select * from portfolioproject..CovidDeaths$;

select * from portfolioproject..covidvaccination$;


select location, date, total_cases, new_cases, total_deaths, population 
from portfolioproject..CovidDeaths$
order by 1,2;


--Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..CovidDeaths$
order by 1,2;


--shows likelihood of dying if you contract covid in your country.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..CovidDeaths$
where location like '%Italy%'
order by 5,2;

--- looking at total cases vs population
--shows what percentage of population has gotten covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentpopulationInfected
from portfolioproject..CovidDeaths$
where location like '%Italy%'
order by 5,2;

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentpopulationInfected
from portfolioproject..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentpopulationInfected desc;

--- showing countries with the highest deathcount perpopuation

select location, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc;

select location, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc;


---showing the continent with the highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc;


---- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as Deathpercentage
from portfolioproject..CovidDeaths$
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as Deathpercentage
from portfolioproject..CovidDeaths$
where continent is not null
order by 1,2;

--- looking at total population vs vaccination

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated 
---,(rollingpeoplevaccinated /population) * 100
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


----USE CTE

with popvsvac(continent, loction, date, population, new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated 
---,(rollingpeoplevaccinated /population) * 100
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac



---Temp Table

Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
) 
insert into #percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated 
---,(rollingpeoplevaccinated /population) * 100
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


-----creating views to store data for ater visualization

create view percentpopulationvaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated 
---,(rollingpeoplevaccinated /population) * 100
from portfolioproject..covidDeaths$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from percentpopulationvaccinated;
Drop view percentpopulationvaccinated;



create view globalnumbers as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as Deathpercentage
from portfolioproject..CovidDeaths$
where continent is not null
--order by 1,2;

select * from globalnumbers;
Drop view globalnumbers;