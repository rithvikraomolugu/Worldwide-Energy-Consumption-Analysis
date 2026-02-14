CREATE DATABASE ENERGYDB2;

USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
CID VARCHAR(10) PRIMARY KEY,
Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
country VARCHAR(100),
energy_type VARCHAR(50),
year INT,
emission INT,
per_capita_emission DOUBLE,
FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
countries VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
production INT,
FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
Country VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
consumption INT,
FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

# DATA ANALYSIS QUESTIONS

## General & Comparative Analysis

-- 1) What is the total emission per country for the most recent year available?

SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country;

-- 2) What are the top 5 countries by GDP in the most recent year?

SELECT country,  value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY GDP DESC
LIMIT 5;

-- 3) Compare energy production and consumption by country and year.

SELECT p.country, p.year, SUM(p.production) AS total_production, SUM(c.consumption) AS total_consumption
FROM production AS p
JOIN consumption AS c
ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year;

-- 4) Which energy types contribute most to emissions across all countries?

SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;

## Trend Analysis Over Time

-- 1) How have global emissions changed year over year?

SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- 2) What is the trend in GDP for each country?

SELECT Country, year, Value AS GDP
FROM gdp_3
ORDER BY Country, year;

-- 3) How has population growth affected total emissions?

SELECT e.country, e.year, p.Value AS population, SUM(e.emission) AS total_emission
FROM emission_3 AS e
JOIN population AS p
ON e.country = p.countries AND e.year = p.year
GROUP BY e.country, e.year, p.Value
ORDER BY e.country, e.year;

-- 4) Has energy consumption increased or decreased over the years for major economies?

SELECT c.country, c.year, SUM(c.consumption) AS total_consumption
FROM consumption AS c
JOIN (
    SELECT country
    FROM gdp_3
    WHERE year = (SELECT MAX(year) FROM gdp_3)
    ORDER BY Value DESC
    LIMIT 5
) AS top_countries
ON c.country = top_countries.country
GROUP BY c.country, c.year
ORDER BY c.country, c.year;

-- 5) What is the average yearly change in emissions per capita for each country?

SELECT country, ((MAX(emission_per_capita) - MIN(emission_per_capita)) / (MAX(year) - MIN(year)))*100000 AS avg_yearly_change
FROM (SELECT e.country, e.year, SUM(e.emission) / p.Value AS emission_per_capita
    FROM emission_3 AS e
    JOIN population AS p
    ON e.country = p.countries AND e.year = p.year
    GROUP BY e.country, e.year, p.Value
) AS temp
GROUP BY country;

## Ratio & Per Capita Analysis

-- 1) What is the emission-to-GDP ratio for each country by year?

SELECT e.country, e.year, (SUM(e.emission) / g.Value)*10 AS emission_to_gdp_ratio
FROM emission_3 AS e
JOIN gdp_3 AS g
ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year, g.Value
ORDER BY country, year;

-- 2) What is the energy consumption per capita for each country over the last decade?

SELECT c.country, c.year, (SUM(c.consumption) / p.Value) * 100000 AS consumption_per_capita
FROM consumption AS c
JOIN population AS p
ON c.country = p.countries AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 10 FROM consumption)
GROUP BY c.country, c.year, p.Value
ORDER BY country, year;

-- 3) How does energy production per capita vary across countries?

SELECT pr.country, pr.year, (SUM(pr.production) / p.Value)*100000 AS production_per_capita
FROM production AS pr
JOIN population AS p
ON pr.country = p.countries AND pr.year = p.year
GROUP BY pr.country, pr.year, p.Value
ORDER BY country, year;

-- 4) Which countries have the highest energy consumption relative to GDP?

SELECT c.country, c.year, (SUM(c.consumption) / g.Value)*1000 AS consumption_to_gdp_ratio
FROM consumption AS c
JOIN gdp_3 AS g
ON c.country = g.Country AND c.year = g.year
GROUP BY c.country, c.year, g.Value
ORDER BY consumption_to_gdp_ratio DESC;

-- 5) What is the correlation between GDP growth and energy production growth?

SELECT g.Country, g.year, g.Value - g_prev.Value AS gdp_growth, SUM(p.production) - SUM(p_prev.production) AS production_growth
FROM gdp_3 AS g
JOIN gdp_3 AS g_prev
ON g.Country = g_prev.Country AND g.year = g_prev.year + 1
JOIN production AS p
ON g.Country = p.country AND g.year = p.year
JOIN production AS p_prev
ON p.country = p_prev.country AND p.year = p_prev.year + 1
GROUP BY g.Country, g.year, g.Value, g_prev.Value
ORDER BY g.Country, g.year;

## Global Comparisons

-- 1) What are the top 10 countries by population and how do their emissions compare?

SELECT p.countries AS country, p.Value AS population, SUM(e.emission) AS total_emissions
FROM population AS p
LEFT JOIN emission_3 AS e
ON p.countries = e.country AND p.year = e.year
WHERE p.year = (SELECT MAX(year) FROM emission_3)
GROUP BY p.countries, p.Value
ORDER BY p.Value DESC
LIMIT 10;

-- 2) Which countries have improved (reduced) their per capita emissions the most over the last decade?

SELECT country, MAX(emission_per_capita) - MIN(emission_per_capita) AS reduction
FROM (
    SELECT e.country, e.year, (SUM(e.emission) / p.Value)*1000 AS emission_per_capita
    FROM emission_3 AS e
    JOIN population AS p
	ON e.country = p.countries AND e.year = p.year
    WHERE e.year >= (SELECT MAX(year) - 10 FROM emission_3)
    GROUP BY e.country, e.year, p.Value
) AS temp
GROUP BY country
ORDER BY reduction DESC;

-- 3) What is the global share (%) of emissions by country?

SELECT country, SUM(emission) / (SELECT SUM(emission) FROM emission_3) * 100 AS global_share_percent
FROM emission_3
GROUP BY country
ORDER BY global_share_percent DESC;

-- 4) What is the global average GDP, emission, and population by year?

SELECT g.year, AVG(g.Value) AS avg_gdp, AVG(e.emission) AS avg_emission, AVG(p.Value) AS avg_population
FROM gdp_3 AS g
JOIN emission_3 AS e
ON g.Country = e.country AND g.year = e.year
JOIN population AS p
ON g.Country = p.countries AND g.year = p.year
GROUP BY g.year;