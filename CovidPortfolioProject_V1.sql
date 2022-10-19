use PortfolioProject


--Select * from PortfolioProject..CovidVaccinations order by 3,4

--Select * from PortfolioProject..CovidDeaths order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths order by 1,2


--Looking at Total Cases vs Tptal Deaths

Select Location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths where location like '%Turkey%'
order by 1,2




--Looking at Total Cases vs Population 
--Show what percentage of population got Covid 

Select Location,date,total_cases,population ,(total_deaths/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths 
where location like '%Turkey%'
order by 1,2


---Looking at countries with highest infection rate compared to Population

Select Location,population,max(total_cases) as HighestInfectionCount ,max((total_deaths/population))*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%Turkey%'
group by location,population
order by 1,2

Select Location,population,max(total_cases) as HighestInfectionCount ,max((total_deaths/population))*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where location like '%Turkey%'
group by location,population
order by 1,2




Select Location,population,max(total_cases) as HighestInfectionCount ,max((total_deaths/population))*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
group by location,population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select location,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
group by location
order by TotalDeathCount desc 

Select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
group by location
order by TotalDeathCount desc 



--if we break things down by continent

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc 

--Showing continent with the highest death count per population

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount  desc

--GLOBAL NUMBERS

Select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , 
sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


Select dea.continent ,dea.location ,dea.date ,dea.population , vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (PARTITION by dea.location)

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	order by 1,2

	Select dea.continent ,dea.location ,dea.date ,dea.population , vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated ,
(RollingPeopleVaccinated/population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	order by 1,2



	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
