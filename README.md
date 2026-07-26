# Mapping Health Facility Access Gaps Across Nigerian States


## Problem Statement

Nigeria's health facilities are not evenly distributed across the country relative to population, but there is no simple, accessible way to see which states are underserved, since facility data exists only as an unorganized list of individual records with no population context attached. This project cleans and aggregates Nigeria's national health facility registry, combines it with state-level population data, and calculates facility-to-population ratios to identify which states have the lowest access relative to the number of people they serve, in relation to SDG target 3.8 (access to essential healthcare services) and SDG target 3.d (national health system capacity).


## Project Background

Nigeria's health system carries a well documented and widely discussed burden of disease, malaria, maternal and child health challenges, and a growing non-communicable disease load. Far less attention is given to a more basic, structural question underneath all of that: can people actually reach a functioning health facility in the first place?. Health outcomes are shaped not only by disease prevalence but by whether care is physically accessible, and in a country as large and populous as Nigeria, that access is unlikely to be evenly distributed.

This project was built to answer that question directly, using Nigeria's own national health facility registry. The registry itself is a raw, unaggregated list of individual facilities with no population context attached. 

The result is a population-adjusted view of facility access across Nigeria's 36 states and the FCT, built to answer a specific, actionable question: not just which states have the fewest facilities, but which states are underserved once population size is properly accounted for, and where a facility gap would affect the greatest number of people. This connects directly to SDG target 3.8, on access to essential healthcare services, and is intended as a starting point for prioritizing where future health infrastructure investment could have the greatest impact.


## Dataset

1. Nigeria Health Facilities (facility-level registry)	Humanitarian Data Exchange (HDX)	

**Source:** https://data.humdata.org/dataset/3b4a119a-309c-4d3f-900f-18a1f6ca2dfa/resource/4658aa59-0554-4fac-8473-377da4b7a0e9/download/nigeriahealthfacilities.csv

2. Nigeria Population by State (2022 projections)	UNFPA, via HDX

**Source:** https://data.humdata.org/dataset/cod-ps-nga




## Tools Used

**Python (pandas)**: data cleaning, standardization, exploratory checks

**PostgreSQL**: data storage, aggregation, ranking, and querying

**Power BI**: interactive three-page dashboard and geographic visualization

## Methodology

**Data Import and Initial Exploration**

Two datasets were loaded into Python for review:
Nigeria Health Facilities (NHF): 15 columns, including facility ID, name, global ID, alternate name, functional status, facility type (primary, secondary, tertiary), ward code, category (a more detailed facility type description), timestamp of the record, LGA name and code, state name and code, and a reference link (FID).
Population data: 60 columns, including year (2022), ISO3 country code, country name and code, state name (ADM1_EN) and state code (ADM1_PCODE), total population by sex, and population broken down further by 5-year age bands.

**Data Cleaning (Python)**

Reduced the population dataset to three relevant columns: year, ADM1_EN (renamed to state_name), and T_TL (renamed to total_population).
Removed the alternate name column and an accessibility-related column from the NHF dataset, both over 90% empty and not relevant to this analysis.
Verified data types across both datasets.
Checked for duplicate records; none were found.
Filled blank values in the category column with "Unknown" rather than dropping them, to avoid losing legitimate facility records with incomplete metadata.
Standardized state names across both datasets so that every state is spelled identically, enabling a reliable join.
Exported both cleaned datasets to PostgreSQL for querying.

**Analysis (SQL)**

Key queries run against the cleaned data in PostgreSQL:

How are health facilities distributed across Nigeria's states relative to their populations?
How many health facilities are functional versus non-functional in each state?
Which states have the highest number of non-functional health facilities?
Which states have the largest populations but the weakest access to functional healthcare facilities?
What is the national population-weighted average of total health facility access compared to functional health facility access?
How many people does a single functional health facility serve in each state?
Which are the 10 most underserved states based on population per functional health facility?
What percentage of Nigeria's total population lives in the 10 most underserved states?
Which states have the greatest mismatch between population size and healthcare service availability?

**Visualization (Power BI)**

A three-page interactive dashboard was built
**PowerBI Link**: https://app.powerbi.com/view?r=eyJrIjoiOGMwZTUxMmYtYWYzMS00MTk2LThjNjgtNDM2ZmRhYmExNGY0IiwidCI6ImQyNzc2ODVlLTE0YjQtNDRkYi1hMGI1LTI0MTRiYmJmN2YzMCJ9

**Overview page**

<img width="668" height="380" alt="image" src="https://github.com/user-attachments/assets/e6f0b2e6-580b-42f3-add1-d5340c45eb48" />

**Most affected states page**

<img width="668" height="379" alt="image" src="https://github.com/user-attachments/assets/d414eb2f-9201-4a93-800f-54988bf4854a" />

**Priority states page**

<img width="671" height="373" alt="image" src="https://github.com/user-attachments/assets/bd86e4ab-011b-444c-baa5-900d2fac1f8a" />

**All visuals are powered by DAX measures built**


## Key Analytical Findings

#### How many facilities are functional versus non-functional?
Nationally:
Total facilities: 46,132
Functional: 34,272 (74.3%)
Non-functional: 11,860 (25.7%)

#### Which states have the highest number of non-functional facilities?
State includes:
Adamawa
Plateau
Kebbi
Zamfara
Taraba

#### Which states have large populations but weak facility access?
States includes:
Kano
Kaduna
Bauchi
Jigawa
Rivers

#### What is the national population-weighted average facility access?
Total facilities: 21.28 per 100k
Functional facilities: 15.81 per 100k

The gap between the two reflects the share of registered facilities that are not operational.

#### What share of Nigeria's population lives in the 10 most underserved states?
37.6% of Nigeria's population, roughly 82 million people.



## Key Insights

1. Some of Nigeria's most populous states, including Kano and Kaduna, rank among the weakest in functional facility access, while smaller states like Niger rank well above the national average, confirming that population size alone cannot predict service availability.

2. Over 25% of Nigeria's registered health facilities are non-functional, meaning they cannot serve the population despite being counted, a direct barrier to the access SDG target 3.8 measures.

3. The ten highest-priority states, identified by combining population size and facility access rate has a total of 82 million people, 37.6% of Nigeria's total population.

4. The best-served states, Osun, Nasarawa, Benue, Cross River, and Abia, are not the states typically assumed to be most developed, showing the relevance of measuring facility access.

5. States with too few facilities (Rivers, Zamfara, Jigawa) are largely different from states with the most non-functional facilities (Adamawa, Plateau, Taraba), meaning some states need new investment while others need restoration.

## Recommendations

- Prioritize new facility investment and functionality restoration in the ten highest-priority states (Kano, Rivers, Jigawa, Kaduna, Sokoto, Bauchi, Katsina, Zamfara, Kebbi, and Delta), where the combination of population size and low access means investment would reach the greatest number of people.

- Treat non-functional facility restoration as a distinct, cost-effective intervention alongside new construction, since reactivating an existing facility is typically less resource-intensive than building a new one, and states like Adamawa and Plateau show this is where the more immediate gains may lie.
  

## Why This Project Matters

Health outcomes cannot improve faster than people can reach care. Before addressing disease burden, health systems research has to answer a more basic question, is care physically reachable in the first place, and for whom is it not. This project answers that question for Nigeria using the country's own facility registry and turns a raw, difficult-to-use list of individual facility records into a specific, ranked, and human-scaled answer. This transformation, from unusable raw data to a decision-ready finding applies public health data analysis. 


## Strategic Value

This project demonstrates skills in:
* **Public health data analysis**
* **Data cleaning and standardization** of real, unaggregated registry data
* **SQL analytical querying**, including aggregation, ranking, and population-weighted calculations
* **Dashboard storytelling**, structuring a multi-page report around a clear narrative arc
* **Health systems and equity-focused interpretation**, framing findings against SDG target 3.8




