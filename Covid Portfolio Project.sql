select *
From PortfolioProject..CovidD
Where continent is not  null
order by 3,4

--select *
--From PortfolioProject..CovidVcaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidD
order by 1,2

--looking at Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidD
Where location like '%Nigeria%'
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
order by 1,2

--Looking at Countries with Highest Infection rate compared to Population
Select continent,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
group by continent, population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount	
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
Where continent is not null
group by continent
order by TotalDeathCount DESC

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount	
--From PortfolioProject..CovidD
----Where location like '%Nigeria%'
--Where continent is null
--group by location
--order by TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount	
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
Where continent is not null
group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases*100) as DeathPercentage
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases*100) as DeathPercentage
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location)
From PortfolioProject..CovidD dea
Join PortfolioProject..CovidVcaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidD dea
Join PortfolioProject..CovidVcaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidD dea
Join PortfolioProject..CovidVcaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,                                                           
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidD dea
Join PortfolioProject..CovidVcaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidD dea
Join PortfolioProject..CovidVcaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated

Create view PercentDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount	
From PortfolioProject..CovidD
--Where location like '%Nigeria%'
Where continent is not null
group by continent
--order by TotalDeathCount DESC

Select * 
From PercentDeathCount


	










