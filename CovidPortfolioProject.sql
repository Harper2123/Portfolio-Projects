--select * from CovidDeaths order by 3,4;

--select * from CovidVaccinations order by 3,4;


--Selecting Data that we will use From CovidDeaths
select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1,2;


-- Looking at Total Cases vs Total Deaths
--Likelihood of Death if you contract covid in India
select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from CovidDeaths
where location like '%India%'
order by 1,2;

--Looking at Total cases vs Population
--What percentage of population got Covid
select location, date, population, total_cases, ((total_cases/population)*100) as CovidPercentage
from CovidDeaths
where location like '%India%'
order by 1,2;

-- Looking at countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, (max((total_cases/population))*100) as CovidPercentage
from CovidDeaths
group by location, population
order by CovidPercentage desc;

-- Showing Countries with Highest Death Count per population
select location, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Let's look continent wise Death count
select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- Let's look at Global Values

select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Ordering by Death Percent
select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 4 desc;


-- Looking at Total Population vs Vaccinations
-- We will Use CTE for this task

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3;
)

select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopvsVac;


-- Creating Views to store data for later visualizations

-- To store Percentage of Population Vaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

-- To store Total Deaths
create view GlobalDeath as
select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null