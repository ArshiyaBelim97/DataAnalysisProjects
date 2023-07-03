/****** Script for SelectTopNRows command from SSMS  ******/

--select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  order by 1,2


--looking at the total cases vs total deaths
--shows likelihood of dying if you contract with covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  order by 1,2


--Looking at total cases vs population
--shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  order by 1,2

--looking at countries with higher infection rate compared to population
SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  Group by location, population
  order by PercentPopulationInfected desc

--Let's break things down by continent
SELECT location, Max(cast(total_deaths as int)) as TotalDeaths
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is null
  Group by location
  order by TotalDeaths desc


--showing the countries with the highest death ount per population
SELECT location, Max(cast(total_deaths as int)) as TotalDeaths
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  Group by location
  order by TotalDeaths desc


--Showingn the continent with the hiegest death count per population
SELECT continent, Max(cast(total_deaths as int)) as TotalDeaths
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  Group by continent
  order by TotalDeaths desc

--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
  FROM [PorfolioProect].[dbo].[CovidDeaths]
  Where continent is not null
  --Group By date
  order by 1,2


--Join both tables 
Select *
From [PorfolioProect].[dbo].[CovidDeaths] dea
Join [PorfolioProect].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date = vac.date

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [PorfolioProect].[dbo].[CovidDeaths] dea
Join [PorfolioProect].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date = vac.date
   Where dea.continent is not null
   order by 2,3

--Use CTE
with PopvsVac (Continent, Location,Date,Popuation,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [PorfolioProect].[dbo].[CovidDeaths] dea
Join [PorfolioProect].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date = vac.date
   Where dea.continent is not null
   --order by 2,3
   )
   Select *, (RollingPeopleVaccinated/Popuation)*100
   From PopvsVac


--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locaton nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [PorfolioProect].[dbo].[CovidDeaths] dea
Join [PorfolioProect].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date = vac.date
   --Where dea.continent is not null
   --order by 2,3
 Select *, (RollingPeopleVaccinated/Population)*100
   From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [PorfolioProect].[dbo].[CovidDeaths] dea
Join [PorfolioProect].[dbo].[CovidVaccinations] vac
   on dea.location=vac.location
   and dea.date = vac.date
   Where dea.continent is not null
   --order by 2,3

Select * 
From PercentPopulationVaccinated