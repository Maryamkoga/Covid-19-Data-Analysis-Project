/*

Queries used for Tableau Project

Skills used Aggregate Functions, Converting Data Types, Mathematical Operations


*/

-- 1

select sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
order by 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

-- select sum(new_cases) as total_cases,
-- sum(cast(new_deaths as int)) as total_deaths,
-- sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
-- from coviddeaths
-- where continent is not null
-- group by date
-- order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
select location, 
SUM(cast(new_deaths as int)) as totaldeathcount
From coviddeaths
where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income','Lower middle income', 'Low income')
group by location
order by totaldeathcount desc;

-- 3

select 
location,
population,
max(total_cases) as HighestInfectionCount,
round(max(total_cases/population)*100, 10) as PercentagePopulationInfected
from coviddeaths
group by location, population 
order by 
case when max(total_cases) is null then 1
else 0
end, PercentagePopulationInfected desc;

-- 4

select 
location,
population,
date,
max(total_cases) as HighestInfectionCount,
round(max(total_cases/population)*100, 10) as PercentagePopulationInfected
from coviddeaths
group by location, population, date 
order by 
case when max(total_cases) is null then 1
else 0
end, PercentagePopulationInfected desc;







