-- Age gap between oldest and youngest customer often reveals data inconsistencies or unrealistic entries.
SELECT
    MIN(birthdate) AS oldest,
    DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest,
    DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age,
    DATEDIFF(year, MIN(birthdate), MAX(birthdate)) AS NoOfYearsDiff
FROM gold.dim_customers;
