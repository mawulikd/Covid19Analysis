
USE Covid19;

---Cleaning data by removing all countries without continents
DELETE
FROM CovidVaccination
WHERE continent is NULL;

--Change datatypes that prevents us from using aggregate functions
ALTER TABLE CovidDeaths
ALTER COLUMN new_cases numeric;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2;

--Finding Death Percentage Globally
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
--WHERE location like '%Ghana%'
ORDER BY 1,2;
GROUP BY 
        location,date,total_cases,total_deaths
ORDER BY DeathPercentage DESC

---Finding the period when the highest covid death percentage in a country of your choice occurred (Ghana in this case)
SELECT date, max((total_deaths/total_cases)*100) DeathPercentage
FROM CovidDeaths
WHERE location like '%Ghana%'
GROUP BY date
ORDER BY max((total_deaths/total_cases)*100) DESC

--Finding the total cases on a global level(country by country)
SELECT location, max(total_cases) totalcases
FROM CovidDeaths
GROUP BY location 
ORDER BY max(total_cases) DESC

--Finding the Infection Rate on a global level(country by country) and alternatively your home country or any country of your choice
SELECT location,population,max(total_cases) HighestInfectionCount, MAX((total_cases/population)*100) HighestInfectionRatePerCountry
FROM CovidDeaths
--WHERE location like '&Ghana%'
GROUP BY 
        location,
		population
ORDER BY MAX((total_cases/population)*100) DESC

-- Finding the death count and death rate on a global level(country by country) and alternatively your home country or any country of your choice
SELECT location,max(cast(total_deaths as INT)) HighestDeathCount, MAX((total_deaths/population)*100) HighestDeathRatePerCountry
FROM CovidDeaths
--WHERE location like '%Ghana%'
GROUP BY 
        location
--ORDER BY max(total_deaths) DESC
--ORDER BY MAX((total_deaths/population)*100) DESC

--Finding the Continents with the highest death counts(PERSONAL FACT CHECK please ignore)
SELECT continent, sum(new_deaths) DeathCount
FROM CovidDeaths
--WHERE continent  like '%north%'
GROUP BY continent

--Finding total cases,deaths and Death percentage from covid on a global level and alternatively your home country or any country of your choice
SELECT continent,sum(new_cases) totalcases,sum(new_deaths) totaldeaths,(sum(new_deaths)/sum(new_cases)*100) AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%Ghana%'
GROUP BY continent
--ORDER BY 1,2
ORDER BY 4 DESC

 --Finding cumulative number of people vaccinated per day globally9country by country). alternatively group by function can be used to find the
 --total vaccinated outright
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations, 
sum(CV.new_vaccinations) OVER (partition by CD.location ORDER BY CD.location,CD.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location=CV.location
and CD.date=Cv.date
--where CD.location like '%Ghana%'
--GROUP BY CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
--ORDER BY 2,3 DESC


---Common table expression for the query above
WITH popvsvacc(continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as
(
  SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
sum(CV.new_vaccinations) OVER (partition by CD.location ORDER BY CD.location,CD.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location=CV.location
and CD.date=Cv.date
--where CD.location like '%Ghana%'
--GROUP BY CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
--ORDER BY 2,3
)
SELECT *,rollingpeoplevaccinated/population*100 Percentageofrollingpeoplevaccinated
FROM popvsvacc

---Temporary table created for the query above
CREATE TABLE RPV(
continent varchar(50),
location varchar(50),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
);

INSERT INTO RPV
 SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
sum(CV.new_vaccinations) OVER (partition by CD.location ORDER BY CD.location,CD.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location=CV.location
and CD.date=Cv.date
--where CD.location like '%Ghana%'
--GROUP BY CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
--ORDER BY 2,3

--View created for query above
CREATE VIEW PercentPopulationVaccinated as
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
sum(CV.new_vaccinations) OVER (partition by CD.location ORDER BY CD.location,CD.date) RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location=CV.location
and CD.date=Cv.date
--where CD.location like '%Ghana%'
--GROUP BY CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
--ORDER BY 2,3





