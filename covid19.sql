--selecionando os dados que irei utilizar

select location, date, total_cases, new_cases, total_deaths, population
from projetoPortfolio..covid_mortes$
order by 1,2


-- N�mero total de casos vs n�mero total de mortes
--demonstra a probabilidade de morte em caso de contra��o da covid.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From projetoPortfolio..covid_mortes$
where location like '%brazil%'
order by 1,2

-- Popula��o vs n�mero de casos
-- demonstra a porcentagem de pessoas infectadas em rela��o � popula��o
Select Location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
from projetoPortfolio..covid_mortes$
where location like '%brazil%'
order by 1,2

-- pa�ses com a maior porcentagem de infectados por popula��o 

select Location, MAX(total_cases) as highestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
from projetoPortfolio..covid_mortes$
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- pa�ses com os maiores n�meros de mortes 

select location, MAX(total_deaths) as HighestDeathCount
from projetoPortfolio..covid_mortes$
Where continent is not null
group by location
order by HighestDeathCount desc

-- Analisando os continentes em rela��o ao n�mero m�ximo de mortes
select continent, MAX(total_deaths) as HighestDeathCount
from projetoPortfolio..covid_mortes$
Where continent is not null
group by continent
order by HighestDeathCount desc

--Analisando o n�mero de mortes por continente em rela��o � sua popula��o
select continent, MAX(total_deaths) as HighestDeathCount, MAX(population) as population, MAX((total_deaths/population))*100 as DeathPercentage
from projetoPortfolio..covid_mortes$
where continent is not null
group by continent
order by  DeathPercentage desc

--N�meros globais 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From projetoPortfolio..covid_mortes$
where continent is not null 
order by 1,2

-- olhando a porcentagem de vacinados em rela��o a popula��o mundial
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

-- Criando View para armazenar dados para futuras vizualiza��es

Create View PercentPopulationVaccinated as
Select mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by mor.Location Order by mor.location, mor.Date) as RollingPeopleVaccinated
From projetoPortfolio..covid_mortes$ mor
Join projetoPortfolio..covid_vacinacao$ vac
	On mor.location = vac.location
	and mor.date = vac.date
where mor.continent is not null 


