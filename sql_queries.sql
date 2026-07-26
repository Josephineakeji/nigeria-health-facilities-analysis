-- Preview the datasets

SELECT *
FROM nigeriahealthfacilities
LIMIT 5;

SELECT *
FROM populationdata
LIMIT 5;


-- Remove veterinary clinics from the analysis

DELETE FROM nigeriahealthfacilities
WHERE category = 'Veterinary Clinic';


-- Q1. Compare the total number of health facilities across states

SELECT
    p.state_name,
    p.total_population,
    COUNT(n.id) AS total_facilities
FROM populationdata AS p
LEFT JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    p.total_population DESC;


-- Q2. Compare functional and non-functional health facilities by state

SELECT
    p.state_name,
    p.total_population,
    COUNT(n.id) AS total_facilities,
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS functional_facilities,
    COUNT(n.id) -
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS non_functional_facilities
FROM populationdata AS p
LEFT JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    functional_facilities DESC;


-- Q3. Identify the states with the highest number of non-functional health facilities

SELECT
    p.state_name,
    p.total_population,
    COUNT(n.id) AS total_facilities,
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS functional_facilities,
    COUNT(n.id) -
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS non_functional_facilities,
    DENSE_RANK() OVER (
        ORDER BY
            COUNT(n.id) -
            SUM(
                CASE
                    WHEN n.functional_status = 'Functional'
                    THEN 1
                    ELSE 0
                END
            ) DESC
    ) AS non_functional_facility_rank
FROM populationdata AS p
LEFT JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    non_functional_facility_rank;


-- Q4. Which states have the largest populations but the weakest healthcare access?

SELECT
    p.state_name,
    p.total_population,
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS functional_facilities,
    ROUND(
        SUM(
            CASE
                WHEN n.functional_status = 'Functional'
                THEN 1
                ELSE 0
            END
        ) * 100000.0
        / p.total_population,
        2
    ) AS functional_facilities_per_100k
FROM populationdata AS p
JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    p.total_population DESC,
    functional_facilities_per_100k ASC;


-- Q5. Calculate the national population-weighted average for total and functional facility access

WITH state_to_facility AS
(
    SELECT
        n.state_name,
        COUNT(*) AS total_facilities,
        SUM(
            CASE
                WHEN n.functional_status = 'Functional'
                THEN 1
                ELSE 0
            END
        ) AS functional_facility_count
    FROM nigeriahealthfacilities AS n
    GROUP BY
        n.state_name
)

SELECT
    SUM(s.total_facilities) AS total_facilities,
    SUM(p.total_population) AS total_population,
    SUM(s.functional_facility_count) AS functional_facilities,
    ROUND(
        SUM(s.total_facilities) * 100000.0
        / SUM(p.total_population),
        2
    ) AS national_weighted_facility_average,
    ROUND(
        SUM(s.functional_facility_count) * 100000.0
        / SUM(p.total_population),
        2
    ) AS national_weighted_functional_facility_average
FROM state_to_facility AS s
JOIN populationdata AS p
    ON s.state_name = p.state_name;


-- Q6. Calculate the number of people served by one functional health facility in each state

SELECT
    p.state_name,
    p.total_population,
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS functional_facilities,
    ROUND(
        p.total_population * 1.0
        / NULLIF(
            SUM(
                CASE
                    WHEN n.functional_status = 'Functional'
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        0
    ) AS people_per_functional_facility
FROM populationdata AS p
JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    p.total_population DESC,
    people_per_functional_facility ASC;


-- Q7. Identify the 10 most underserved states based on people per functional health facility

SELECT
    p.state_name,
    p.total_population,
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS functional_facilities,
    ROUND(
        p.total_population * 1.0
        / NULLIF(
            SUM(
                CASE
                    WHEN n.functional_status = 'Functional'
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        0
    ) AS people_per_functional_facility
FROM populationdata AS p
JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    people_per_functional_facility DESC
LIMIT 10;


-- Q8. What percentage of Nigeria's population lives in the 10 most underserved states?

WITH state_access_rankings AS
(
    SELECT
        p.state_name,
        p.total_population AS population,
        SUM(
            CASE
                WHEN n.functional_status = 'Functional'
                THEN 1
                ELSE 0
            END
        ) AS functional_facilities,
        SUM(
            CASE
                WHEN n.functional_status = 'Functional'
                THEN 1
                ELSE 0
            END
        ) * 100000.0
        / p.total_population AS functional_facilities_per_100k,
        DENSE_RANK() OVER (
            ORDER BY
                SUM(
                    CASE
                        WHEN n.functional_status = 'Functional'
                        THEN 1
                        ELSE 0
                    END
                ) * 100000.0
                / p.total_population
        ) AS healthcare_access_rank
    FROM populationdata AS p
    JOIN nigeriahealthfacilities AS n
        ON p.state_name = n.state_name
    GROUP BY
        p.state_name,
        p.total_population
)

SELECT
    SUM(population) AS population_in_bottom_10_states,
    ROUND(
        SUM(population) * 100.0
        / (
            SELECT SUM(total_population)
            FROM populationdata
        ),
        2
    ) AS percentage_of_national_population
FROM state_access_rankings
WHERE healthcare_access_rank <= 10;


-- Q9. Identify states where population size does not align with healthcare access

SELECT
    p.state_name,
    p.total_population AS population,
    SUM(
        CASE
            WHEN n.functional_status = 'Functional'
            THEN 1
            ELSE 0
        END
    ) AS functional_facilities,
    ROUND(
        SUM(
            CASE
                WHEN n.functional_status = 'Functional'
                THEN 1
                ELSE 0
            END
        ) * 100000.0
        / p.total_population,
        2
    ) AS functional_facilities_per_100k,
    RANK() OVER (
        ORDER BY
            p.total_population DESC
    ) AS population_rank,
    RANK() OVER (
        ORDER BY
            SUM(
                CASE
                    WHEN n.functional_status = 'Functional'
                    THEN 1
                    ELSE 0
                END
            ) * 100000.0
            / p.total_population
    ) AS healthcare_access_rank,
    RANK() OVER (
        ORDER BY
            p.total_population DESC
    ) +
    RANK() OVER (
        ORDER BY
            SUM(
                CASE
                    WHEN n.functional_status = 'Functional'
                    THEN 1
                    ELSE 0
                END
            ) * 100000.0
            / p.total_population
    ) AS combined_priority_score
FROM populationdata AS p
JOIN nigeriahealthfacilities AS n
    ON p.state_name = n.state_name
GROUP BY
    p.state_name,
    p.total_population
ORDER BY
    combined_priority_score;