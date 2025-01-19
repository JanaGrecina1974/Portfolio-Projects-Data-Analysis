
-- Total Population vs. Total Vaccination: How many people in the world have been vaccinated?
-- Rolling number of vaccinations 

select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,RollingPeopleVaccenated = sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date)
from dbo.CovidDeath dea
JOIN dbo.CovidVaccinations vac
ON 
dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE - Show the percentage of the population that has been vaccinated in each country. 

WITH RollingVacc As 
(
select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,RollingPeopleVaccenated = sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date)
from dbo.CovidDeath dea
JOIN dbo.CovidVaccinations vac
ON 
dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
)

select
continent
,location
,population
,TotalVaccinated = max(RollingPeopleVaccenated)
,PercentageOfVaccinated = round(max(cast(RollingPeopleVaccenated as float))/population * 100,3)
from RollingVacc
group by continent, location, population
order by 5 desc

-- Using TEMP table - Show the percentage of the population that has been vaccinated in each country. 

drop table if exists #PersentageVaccenated

CREATE TABLE #PersentageVaccenated
(
continent varchar(255)
,location varchar(255)
,[date] datetime
,population numeric
,NewVaccinations  numeric
,RollingPeopleVaccenated float 
)


insert into #PersentageVaccenated (continent, location, [date], population, NewVaccinations,RollingPeopleVaccenated)
select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,RollingPeopleVaccenated = sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date)
from dbo.CovidDeath dea
JOIN dbo.CovidVaccinations vac
ON 
dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null


select
continent
,location
,population
,TotalVaccinated = max(RollingPeopleVaccenated)
,PercentageOfVaccinated = round(max(cast(RollingPeopleVaccenated as float))/population * 100,3)
from #PersentageVaccenated
group by continent, location, population
order by 5 desc


-- Creating a view for later use in visualization

CREATE VIEW PercentPopulationVaccinated AS
select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,RollingPeopleVaccenated = sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date)
from dbo.CovidDeath dea
JOIN dbo.CovidVaccinations vac
ON 
dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null

select
continent
,location
,population
,TotalVaccinated = max(RollingPeopleVaccenated)
,PercentageOfVaccinated = round(max(cast(RollingPeopleVaccenated as float))/population * 100,3)
from PercentPopulationVaccinated
group by continent, location, population
order by 5 desc
