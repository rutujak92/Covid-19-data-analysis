USE `PortfolioDatabaae`;
select * 
from coviddeaths_2
order by location,date;


ALTER TABLE covidvaccinations_2
add COLUMN  new_date DATE;

ALTER TABLE coviddeaths_2
add COLUMN  new_date DATE;

SET SQL_SAFE_UPDATES = 0;

update coviddeaths_2
set new_date = str_to_date(`date`, '%m/%d/%Y');
select * 
from covidvaccinations_2;

/*death rate of covid 
-- shows likelihood of dying if you contract covid in your country
*/


select location,new_date,date, total_cases , total_deaths , (total_deaths/total_cases)*100 as death_rate
from coviddeaths_2
order by location, new_date ;


/* looking at total cases vs population 
shows what percentage of population was infected
*/

select location,new_date,date, total_cases , population , (total_cases/population)*100 as percent_of_population_infected
from coviddeaths_2
where location like '%afghan%'
order by location, new_date ;

/* looking for country with highest infection rates
*/


select location,max(total_cases) as highest_infection_count,
 max((total_cases)/(population)) *100 as percent_population_infected
from coviddeaths_2
group by location
order by percent_population_infected desc;

-- looking for country with highest death rates

select location,max(cast(total_deaths as SIGNED)) as death_count
from coviddeaths_2
where continent != ''
group by location
order by death_count desc;

/* looking for continent with highest death rates
*/
select continent,max(cast(total_deaths as SIGNED)) as death_count
from coviddeaths_2
where continent != ''
group by continent
order by death_count desc;

-- showing continents with highest death count per population

select continent,max(total_cases) as highest_infection_count,
 max((total_cases)/(population)) *100 as percent_population_infected
from coviddeaths_2
where continent != ''
group by continent
order by percent_population_infected desc;

-- global numbers
select new_date, sum(new_cases) as total_cases,sum(cast(new_deaths as SIGNED)) as total_deaths,
sum(cast(new_deaths as SIGNED))/sum(new_cases)*100 as DeathPercentage
from coviddeaths_2
group by new_date
order by new_date;


-- join tables
select *
from coviddeaths_2 dea
join covidvaccinations  vac
on dea.location = vac.location and dea.date = vac.date;

-- population that recievd vaccines
select dea.continent, dea.location, dea.date, vac.new_vaccinations
from coviddeaths_2 dea
join covidvaccinations  vac
on dea.location = vac.location and dea.date = vac.date
where dea.location in ('India');

-- population vs new vaccinations 
	select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as UNSIGNED)) over (partition by dea.location order by dea.location,dea.date)
    as rolling_people_vaccinated
	from coviddeaths_2 dea
	join covidvaccinations  vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.location in ('India')
	order by location;
    
    
    
-- percent population vaccinated 
-- using cte and partition by clause
    select *, (rolling_people_vaccinated/population)*100
    from
    (
    select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as UNSIGNED)) over (partition by dea.location order by dea.location,dea.date)
    as rolling_people_vaccinated
	from coviddeaths_2 dea
	join covidvaccinations  vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.location in ('India')
    ) popsvsvac;
	

    --  create view to store data for later visualizations
    

SELECT * FROM covidvaccinations;

