/*
Covid 19 Data Exploration

Skills used Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from coviddeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with
select 
location,
date,
total_cases,
new_cases,
total_deaths,
population
from coviddeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
select 
location,
date,
total_cases,
total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location ilike '%kingdom%'and 
total_cases is not null and
continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what PERCENTAGE OF POPULATION got Covid
select 
location,
date,
population,
total_cases,
(total_cases/population)*100 as PercentagePopulationInfected
from coviddeaths
-- where location ilike '%kingdom%'and 
-- total_cases is not null and
-- continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select 
location,
population,
max(total_cases) as HighestInfectionCount,
max(total_cases/population)*100 as PercentagePopulationInfected
from coviddeaths
where total_cases is not null
group by population, location
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population
select 
location,
max(total_deaths) as TotalDeathCount
from coviddeaths
where total_deaths is not null and
continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Shows the likelihood of dying if you contract covid in each continent
select 
continent, 
max(total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
group by continent
order by 1,2

-- Shows what PERCENTAGE OF POPULATION got Covid in each Continent
select 
continent,
max(total_cases/population)*100 as PercentagePopulationInfected
from coviddeaths
where continent is not null
group by continent
order by 1,2

-- Continents with Highest Infection Rate compared to Population
select 
continent,
max(total_cases) as HighestInfectionCount,
max(total_cases/population)*100 as PercentagePopulationInfected
from coviddeaths
where continent is not null
group by continent
order by PercentagePopulationInfected desc


-- Showing Continents with Highest Death Count
select 
location,
max(total_deaths) as TotalDeathCount
from coviddeaths
where
continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- DeathPercentages globally according to date
select 
date,
sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths,
case
when sum(new_cases) = 0 then 0 -- If total_new_cases is zero, return 0 as DeathPercentage
else sum(new_deaths)/sum(new_cases)*100 
end as DeathPercentage
from coviddeaths
where continent is not null and
new_cases is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, 
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, 
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
cast(sum(new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date)as numeric) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, 
cast(rollingpeoplevaccinated/population as numeric (15,10))*100
from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists percentagepopulationvaccinated;

create table percentagepopulationvaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
);

insert into percentagepopulationvaccinated
select dea.continent, 
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select *, 
cast(rollingpeoplevaccinated/population as numeric (15,10))*100
from percentagepopulationvaccinated

-- Creating View to store data for later visualizations
create view percentagepopulationvaccinated as 
select dea.continent, 
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(new_vaccinations) 
over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date  
where dea.continent is not null;







