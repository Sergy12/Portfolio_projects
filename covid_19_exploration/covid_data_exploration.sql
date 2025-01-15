					----- Tables creation -----
CREATE TABLE covid_deaths (
    iso_code VARCHAR,
    continent VARCHAR,
    location VARCHAR,
    date VARCHAR,
    population INTEGER,
    total_cases FLOAT,
    new_cases FLOAT,
    new_cases_smoothed FLOAT,
    total_deaths FLOAT,
    new_deaths FLOAT,
    new_deaths_smoothed FLOAT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,   
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,  
    reproduction_rate FLOAT,
    icu_patients FLOAT,
    icu_patients_per_million FLOAT,
    hosp_patients FLOAT,
    hosp_patients_per_million FLOAT,        
    weekly_icu_admissions FLOAT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions FLOAT,
    weekly_hosp_admissions_per_million FLOAT
);

CREATE TABLE covid_vaccinations (
    iso_code VARCHAR,
    continent VARCHAR,
    location VARCHAR,
    date VARCHAR,
    total_tests FLOAT,
    new_tests FLOAT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed FLOAT,
    new_tests_smoothed_per_thousand FLOAT,    
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR,
    total_vaccinations FLOAT,
    people_vaccinated FLOAT,
    people_fully_vaccinated FLOAT,
    total_boosters FLOAT,
    new_vaccinations FLOAT,
    new_vaccinations_smoothed FLOAT,
    total_vaccinations_per_hundred FLOAT,     
    people_vaccinated_per_hundred FLOAT,      
    people_fully_vaccinated_per_hundred FLOAT,
    total_boosters_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    new_people_vaccinated_smoothed FLOAT,
    new_people_vaccinated_smoothed_per_hundred FLOAT,
    stringency_index FLOAT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT,
    excess_mortality_cumulative_absolute FLOAT,
    excess_mortality_cumulative FLOAT,
    excess_mortality FLOAT,
    excess_mortality_cumulative_per_million FLOAT
);

					----- Data load -----
ALTER TABLE covid_deaths ALTER COLUMN population SET DATA TYPE BIGINT;

-- PSQL Tool
-- \copy covid_deaths FROM 'C:\Users\Usuario\Downloads\covid_death.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
-- \copy covid_vaccinations FROM 'C:\Users\Usuario\Downloads\covid_vaccination.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT *
FROM covid_vaccinations
WHERE NOT date ~ '^\d{1,2}/\d{1,2}/\d{4}$';

SELECT date, TO_DATE(date, 'MM/DD/YYYY') AS converted_date
FROM covid_vaccinations
LIMIT 10;

-- Transform varchar date to DATE type
ALTER TABLE covid_deaths ADD COLUMN new_date_column DATE;
ALTER TABLE covid_vaccinations ADD COLUMN new_date_column DATE;

UPDATE covid_deaths
SET new_date_column = TO_DATE(date, 'MM/DD/YYYY');
UPDATE covid_vaccinations
SET new_date_column = TO_DATE(date, 'MM/DD/YYYY');

ALTER TABLE covid_deaths DROP COLUMN date;
ALTER TABLE covid_deaths RENAME COLUMN new_date_column TO date;
ALTER TABLE covid_vaccinations DROP COLUMN date;
ALTER TABLE covid_vaccinations RENAME COLUMN new_date_column TO date;


					----- Work -----
----- Daily death rate per infection -----
SELECT location, date, total_cases, total_deaths,
((total_deaths/NULLIF(total_cases, 0))*100) as "percentage of deaths" 
FROM covid_deaths ORDER BY location, date;

----- Daily infection rate per population -----
SELECT location, date, total_cases, population,
((total_cases/NULLIF(population, 0))*100) as "percentage of cases" 
FROM covid_deaths ORDER BY location, date;

----- Countries with highest infection rates per population -----
SELECT location, MAX(total_cases) as "max_infection_count", population,
MAX((total_cases/NULLIF(population, 0))*100) as "percentage of infection" 
FROM covid_deaths WHERE continent IS NOT NULL 
GROUP BY location, population ORDER BY "percentage of infection" DESC NULLS LAST;

----- Countries with highest death count -----
SELECT location, MAX(total_deaths) as "max_death_count", population
FROM covid_deaths WHERE continent IS NOT NULL 
GROUP BY location, population ORDER BY "max_death_count" DESC NULLS LAST;

----- Countries with highest death rates per population -----
SELECT location, MAX(total_deaths) as "max_death_count", population,
MAX((total_deaths/NULLIF(population, 0))*100) as "percentage of deaths" 
FROM covid_deaths WHERE continent IS NOT NULL 
GROUP BY location, population ORDER BY "percentage of deaths" DESC NULLS LAST;

---- Continents death count -----
SELECT continent, MAX(total_deaths) as "max_death_count" 
FROM covid_deaths WHERE continent IS NOT NULL 
GROUP BY continent ORDER BY "max_death_count" DESC;

----- Daily metrics across the world -----
SELECT date, SUM(total_cases) total_cases, SUM(total_deaths) total_deaths, 
((SUM(total_deaths)/NULLIF(SUM(total_cases), 0))*100) as "percentage of deaths per infection"
FROM covid_deaths WHERE continent IS NOT NULL
GROUP BY date ORDER BY date;

----- Daily percentage of vaccination -----
WITH daily_total_vac_cte AS
(
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) daily_total_vac
    FROM covid_deaths cd 
    INNER JOIN covid_vaccinations cv ON cd.location = cv.location AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL
)
SELECT *, (daily_total_vac/NULLIF(population, 0))*100 daily_percentage_vac 
FROM daily_total_vac_cte;

					----- Views -----
CREATE MATERIALIZED VIEW mview_daily_death_rate
AS
	SELECT location, date, total_cases, total_deaths,
	((total_deaths/NULLIF(total_cases, 0))*100) as "percentage of deaths" 
	FROM covid_deaths ORDER BY location, date
WITH NO DATA;
REFRESH MATERIALIZED VIEW mview_daily_death_rate;

CREATE MATERIALIZED VIEW mview_daily_infection_rate
AS
	SELECT location, date, total_cases, population,
	((total_cases/NULLIF(population, 0))*100) as "percentage of cases" 
	FROM covid_deaths ORDER BY location, date
WITH NO DATA;
REFRESH MATERIALIZED VIEW mview_daily_infection_rate;

CREATE VIEW view_continents_death_count
AS
	SELECT continent, MAX(total_deaths) as "max_death_count" 
	FROM covid_deaths WHERE continent IS NOT NULL 
	GROUP BY continent ORDER BY "max_death_count" DESC;

-- Show views
SELECT * FROM mview_daily_death_rate;
SELECT * FROM mview_daily_infection_rate;
SELECT * FROM view_continents_death_count;

					----- Functions -----
CREATE OR REPLACE FUNCTION fn_daily_metrics_world_interval(
	start_date DATE DEFAULT NULL, 
	end_date DATE DEFAULT NULL)
RETURNS 
TABLE(
	date DATE, 
	total_cases DOUBLE PRECISION, 
	total_deaths DOUBLE PRECISION, 
	percentage_of_deaths_per_infection DOUBLE PRECISION) AS
$$
BEGIN
    RETURN QUERY
    SELECT 
        cd.date, 
        SUM(cd.total_cases) AS total_cases, 
        SUM(cd.total_deaths) AS total_deaths, 
        ((SUM(cd.total_deaths)/NULLIF(SUM(cd.total_cases), 0))*100)
    FROM covid_deaths cd
    WHERE cd.continent IS NOT NULL
    AND (start_date IS NULL OR cd.date >= start_date)
    AND (end_date IS NULL OR cd.date <= end_date)
    GROUP BY cd.date
    ORDER BY cd.date;
END;
$$
LANGUAGE plpgsql;

-- Use functions
SELECT * FROM fn_daily_metrics_world_interval();
SELECT * FROM fn_daily_metrics_world_interval(start_date := '2020-01-12', end_date := '2020-12-31')


