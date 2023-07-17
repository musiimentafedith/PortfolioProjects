/* SIMPLE STUDY ON COVID DATA
	Skills use: CTEs, Temp tables, joins, changing datatypes, window functions
				aggregated Functions, creating views
*/

-- just a look at all the data in table covid_deaths
select *
from SQL_Portfolio_project..covid_deaths
order by 3,4

-- just a look at all the data in table covid_vaccins
select *
from SQL_Portfolio_project..covid_vaccins
order by 3,4

-- We are going to use the selected data below for now
select location, date, total_cases, new_cases, total_deaths, population
from SQL_Portfolio_project..covid_deaths
order by 1,2

-- Total cases vs total death
-- shows the likelywood of dying if you contract covid in Uganda
select location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/cast(total_cases as float))*100 as percentage_death
from SQL_Portfolio_project..covid_deaths
where location = 'Uganda' and continent != 'NULL'
order by 1,2

--look at total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, 
(cast(total_cases as float)/population)*100 as percentpopulationinfected
from SQL_Portfolio_project..covid_deaths
where continent is not null
order by 1,2

--looking at countries with highiest infection rate compaired to population
select location, population, max(total_cases) as HighlyInfectedCountry, 
max(cast(total_cases as float)/population)*100 as max_percentpopulationinfected
from SQL_Portfolio_project..covid_deaths
where continent != 'NULL'
group by location, population
order by max_percentpopulationinfected desc

--looking at countries with highest death count per population
select location, max(cast(total_deaths as int)) as deathcount
from SQL_Portfolio_project..covid_deaths
where continent is not null
group by location
order by deathcount desc

-- lets break it down using continent
-- showning continet with highest death count
select continent, max(cast(total_deaths as int)) as deathcount
from SQL_Portfolio_project..covid_deaths
where continent is not null
group by continent
order by deathcount desc

-- Grobal numbers
select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as float))/nullif(sum(cast(new_cases as float)), 0) as deathpercentage
from SQL_Portfolio_project..covid_deaths
where total_deaths != 0 and continent is not null
group by date
order by date

--full grobal totals as per july
select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as float))/nullif(sum(cast(new_cases as float)), 0) as deathpercentage
from SQL_Portfolio_project..covid_deaths
where total_deaths != 0 and continent is not null

-- LOOKING AT THE VACCITION TABLE
-- first let's find out how many people are vaccinated in each country
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by cd.location)
as total_country_vaccinations
from SQL_Portfolio_project..covid_deaths as cd
join SQL_Portfolio_project..covid_vaccins as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by cd.location, cd.date

--lets use order by and generate a cumulative total_country_vaccinations column
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(new_vaccinations as bigint))
over(partition by cd.location order by cd.location, cd.date)
as cumulative_total_country_vaccinations
from SQL_Portfolio_project..covid_deaths as cd
join SQL_Portfolio_project..covid_vaccins as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by cd.location, cd.date

-- we use a CTE to know the ratio of people vaccinated to country population for Uganda
with CTE_vacc_ratio (continent, location, date, population, new_vaccinations, cumulative_total_country_vaccinations) 
	as(
	Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(cast(new_vaccinations as bigint))
	over(partition by cd.location order by cd.location, cd.date)
	as cumulative_total_country_vaccinations
	from SQL_Portfolio_project..covid_deaths as cd
	join SQL_Portfolio_project..covid_vaccins as cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null)
	--order by cd.location, cd.date)
select *,
(cumulative_total_country_vaccinations/population)*100 as vaccinatedper
from CTE_vacc_ratio
where location = 'uganda'
order by location, date
