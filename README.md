# Worldwide Energy Consumption Analysis

## Overview 
This project analyzes global energy consumption, production, carbon emissions, GDP, and population trends using SQL. The study examines how economic growth and energy demand are interconnected and evaluates environmental impacts across countries. Through structured database design and analytical queries, the project provides insights to support sustainable energy and policy decisions.

## Objectives
- Analyze energy consumption and production patterns across countries
- Evaluate carbon emission trends and major emitting nations
- Study the relationship between GDP growth and energy usage
- Calculate emission-to-GDP and per capita metrics
- Compare countries for efficiency and sustainability insights

## Database Structure
The ENERGYDB2 database follows a relational model:

- **Country** table acts as the central entity with primary key (CID)
- **Emission_3**, **Production**, **Consumption**, **GDP_3**, and **Population** tables reference the Country table via foreign keys
- Relationships follow a One-to-Many (1:N) model, where one country can have multiple yearly records in related tables

## Key Insights
- Major economies show higher energy consumption and emissions
- Coal contributes significantly to global emissions
- Energy consumption generally increases with GDP growth
- Emission levels depend more on economic intensity than population alone


## Tools Used
SQL, Relational Database Design, Data Analysis
