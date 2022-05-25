
select continent, location, count(*) as count
from covidvaccines
group by continent, location
order by continent, location

select continent, location, count(*) as count
from covidDeaths
group by continent, location
order by continent, location


----
select continent, location
from covidDeaths
where continent is null


--select the data we are going to work with 
select location, date, total_cases, new_cases, total_deaths, new_deaths, population
from PortfolioProject.dbo.covidDeaths
order by 1,2

--total cases v/s total deaths
--shows likelihood chances of you dying of covid if you contract covid
select location, date, total_cases, total_deaths, (Total_deaths/Total_cases) * 100 as Death_Percent
from PortfolioProject.dbo.covidDeaths
where location like '%states%'
order by date desc


--total cases v/s population
--shows what percent of the population has contracted covid
select location, date, population, total_cases, (Total_cases/population) * 100 as InfectedCases_Percent
from PortfolioProject.dbo.covidDeaths
where location like '%states%'
order by date desc

---Max of infected rate by countrie
select location, population, max(cast(total_cases as int)) as HighestInfections,  
(max(Total_cases)/population) * 100 as InfectedRate_Percent
from PortfolioProject.dbo.covidDeaths
group by location, population
order by HighestInfections desc



---Max of Death rate by countries
select location, population, max(cast(total_deaths as int)) as TotalDeathCount,
(max(cast(Total_deaths as int))/population) * 100 as DeathRate_Percent
from PortfolioProject.dbo.covidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc


---Lets break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.covidDeaths
--where continent is not null
group by continent
order by TotalDeathCount desc

--looking at total deaths v/s total vaccinations

--lets create a CTE PopvsVaccines
with PopVsVac (Continent, Location, Date, Population, Vaccinations,  RollingVaccinatedCount)
As
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, --, sum(cast(vac.new_vaccinations as int))
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
from PortfolioProject.dbo.covidDeaths dea
inner join PortfolioProject.dbo.covidvaccines vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
)


select Continent, Location, max((RollingVaccinatedCount/Population) *100) as maxPercentofVaccinated
from PopVsVac
group by Continent, Location
order by Continent, Location
--where location like '%India%'


---lets create a view 

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, --, sum(cast(vac.new_vaccinations as int))
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
from PortfolioProject.dbo.covidDeaths dea
inner join PortfolioProject.dbo.covidvaccines vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by  2, 3

select * from PercentPopulationVaccinated
