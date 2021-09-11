--selecionando os dados que irei utilizar

select location, date, total_cases, new_cases, total_deaths, population
from projetoPortfolio..covid_mortes$
order by 1,2


-- Número total de casos vs número total de mortes
--demonstra a probabilidade de morte em caso de contração da covid.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From projetoPortfolio..covid_mortes$
where location like '%brazil%'
order by 1,2

-- População vs número de casos
-- demonstra a porcentagem de pessoas infectadas em relação à população
Select Location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
from projetoPortfolio..covid_mortes$
where location like '%brazil%'
order by 1,2

-- países com a maior porcentagem de infectados por população 

select Location, MAX(total_cases) as highestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
from projetoPortfolio..covid_mortes$
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- países com os maiores números de mortes 

select location, MAX(total_deaths) as HighestDeathCount
from projetoPortfolio..covid_mortes$
Where continent is not null
group by location
order by HighestDeathCount desc

-- Analisando os continentes em relação ao número máximo de mortes
select continent, MAX(total_deaths) as HighestDeathCount
from projetoPortfolio..covid_mortes$
Where continent is not null
group by continent
order by HighestDeathCount desc

--Analisando o número de mortes por continente em relação à sua população
select continent, MAX(total_deaths) as HighestDeathCount, MAX(population) as population, MAX((total_deaths/population))*100 as DeathPercentage
from projetoPortfolio..covid_mortes$
where continent is not null
group by continent
order by  DeathPercentage desc

--Números globais 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From projetoPortfolio..covid_mortes$
where continent is not null 
order by 1,2

-- olhando a porcentagem de vacinados em relação a população mundial
select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (Partition by mor.Location Order by mor.location, mor.Date) as RollingPeopleVaccinated
From projetoPortfolio..covid_mortes$ mor
Join projetoPortfolio..covid_vacinacao$ vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null 
order by 2,3

-- cte para calculo de partion by em queries anteriores

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--usando temp table para calculo de partion by em queries anteriores

Insert into #PercentPopulationVaccinated
Select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by mor.Location Order by mor.location, mor.Date) as RollingPeopleVaccinated
From projetoPortfolio..covid_mortes$ mor
Join projetoPortfolio..covid_vacinacao$ vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Criando View para armazenar dados para futuras vizualizações

Create View PercentPopulationVaccinated as
Select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by mor.Location Order by mor.location, mor.Date) as RollingPeopleVaccinated
From projetoPortfolio..covid_mortes$ mor
Join projetoPortfolio..covid_vacinacao$ vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null 


