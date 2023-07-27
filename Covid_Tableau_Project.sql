# Dashboard main contents #

--Tableau Table 1
---List Covid Cases, Deaths and its death'a ratio in the world
SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,SUM(new_deaths) / SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
where continent is not null
order by 1,2

--Tableau Table 2
---List total deaths by location 
select location, SUM(cast(new_deaths as int)) AS TotalDeathCount from CovidDeaths
where continent is null and location not in ('World', 'European Union', 'International')
and location not like('%income')
Group by location
order by TotalDeathCount DESC

--Tableau Table 3
---Looking at countries with infection rates per population
select Location,population,MAX(total_cases) AS HighestInfectedCount,(MAX(total_cases)/population)*100 as PercentagePopulationInfected from CovidDeaths
where continent is not null
Group by Location,population
order by PercentagePopulationInfected DESC

--Tableau Table 4
-- Use CTE and add vaccinated ratio per country
With VaccinatedPop(Continent,Location,Date,Population,New_Vaccination,VaccinatedPeople)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as TotalVaccinated
from CovidDeaths dea
Join CovidVaccines vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select *, VaccinatedPeople/Population *100 as VaccinatedRatio from VaccinatedPop

#--Other Data Analasis in SQL(SSMS)#

--Show all tables 
select * from CovidDeaths
where continent is not null
order by 3,4

select * from CovidVaccines
where continent is not null
order by 3,4

-- Select Data that to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
order by 1,2

 --Total Cases vs Total Deaths
select Location,date,total_cases,total_deaths,(total_deaths/cast(total_cases as float))*100 as DeathPercentage from CovidDeaths
where location like 'United States' and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows the likelihood of population infected with Covid
select Location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected from CovidDeaths
where location like 'United States' and continent is not null
order by 1,2


----Looking at countries with highest infection rate per population
select Location,population,MAX(total_cases) AS HighestInfectedCount,(MAX(total_cases)/population)*100 as PercentagePopulationInfected from CovidDeaths
where continent is not null
Group by Location,population
order by PercentagePopulationInfected DESC

--Looking at countries with highest death count per population
select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount from CovidDeaths
where continent is not null
Group by Location 
order by TotalDeathCount DESC

--Group it by continents with the highest death count per population
select continent, Max(cast(total_deaths as int)) AS TotalDeathCount from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Global DeathPercentage
SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,SUM(new_deaths) / SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population vs vaccinations per location
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as TotalVaccinated
from CovidDeaths dea
Join CovidVaccines vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Temp Table

Drop table if exists #VaccinatedRatio
Create Table #VaccinatedRatio
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinatedPeople numeric
)
Insert into #VaccinatedRatio
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as TotalVaccinated
from CovidDeaths dea
Join CovidVaccines vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
select *, VaccinatedPeople/Population *100 as VaccinatedRatio from #VaccinatedRatio 
order by VaccinatedRatio asc 

--Creating view to store data for later visualizations

Create View VaccinatedRatio as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as TotalVaccinated
from CovidDeaths dea
Join CovidVaccines vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
