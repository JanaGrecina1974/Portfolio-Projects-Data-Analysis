-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract COVID-19

SELECT
location
,date
,total_cases
,total_deaths
,DeathPercentage = ROUND((CAST(total_deaths AS Float)/CAST(total_cases AS FLOAT)) *100,2)
FROM [dbo].[CovidDeath]
where continent is not null
group by location, date, total_cases, total_deaths
order by 1,2

-- Looking at Total Cases vs. Total Population per Country
-- Shows the percentage of the population that got COVID-19

SELECT
location
,date
,total_cases
,population
,[% of Population Got Covid] = (CAST(total_cases AS Float)/CAST(population AS FLOAT)) *100
FROM [dbo].[CovidDeath]
where continent is not null
group by location, date, total_cases, population
order by 5 desc

-- Looking at Countries with the Highest Infection Rate Compared to Population.

with TotalCasesByCountry AS
(
SELECT
location
,HighestInfectionCount = max(total_cases)
FROM [dbo].[CovidDeath]
where continent is not null
group by location 

),

TotalPopulation AS
(
SELECT
location
,CountryPopulation = max(population)
FROM [dbo].[CovidDeath]
where continent is not null
group by location

)

select
a.location
,CountryPopulation
,HighestInfectionCount 
,InfectionRate = cast(HighestInfectionCount As Float) /cast(CountryPopulation as Float) * 100
From TotalPopulation a
JOIN
TotalCasesByCountry b
on a.location = b.location
Order by InfectionRate DESC


--OR

select 
location
,Population
,HighestInfectionCount = max(total_cases)
,InfectionRate = max(cast(total_cases As Float))/population * 100

from [dbo].[CovidDeath]
where continent is not null
group by location, population
order by 4 desc

-- Showing Countries with the Highest Death Count per Population.

select 
location
,HighestDeathCount = MAX(Total_deaths)
from [dbo].[CovidDeath]
where continent is null
group by location
order by 2 desc

--Showing Continents with the Highest Death Count per Population

select 
continent
,HighestDeathCount = MAX(Total_deaths)
from [dbo].[CovidDeath]
where continent is not null
group by continent
order by 2 desc

-- Global numbers

select 
TotalNewCases = sum(cast(new_cases as Float))
,TotalNewDeaths = sum(cast(new_deaths as Float))
,DeathPercentage =  CASE
WHEN sum(isnull(new_cases,0)) = 0 THEN 0
ELSE sum(isnull(cast(new_deaths as float),0))/sum(isnull(cast(new_cases as float),0)) * 100
END
from [dbo].[CovidDeath]
where continent is not null
order by 1,2
