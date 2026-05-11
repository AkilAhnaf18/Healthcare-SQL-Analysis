-- ================================================================
-- NY State Hospital Inpatient Discharges — 2016
-- SQL Analysis Queries
-- ================================================================


-- ----------------------------------------------------------------
-- DATA CLEANING VIEW
-- Sits on top of the raw table — source data is never modified
-- ----------------------------------------------------------------

DROP VIEW IF EXISTS discharges_clean;

CREATE VIEW discharges_clean AS
SELECT
    health_service_area,
    hospital_county,
    facility_name,
    age_group,
    CASE WHEN gender = 'U' THEN 'Unknown' ELSE gender END AS gender,
    race,
    ethnicity,
    CASE WHEN type_of_admission = 'Not Available' THEN 'Unknown'
         ELSE type_of_admission END AS type_of_admission,
    patient_disposition,
    discharge_year,
    emergency_department_indicator,
    ccs_diagnosis_code,
    ccs_diagnosis_description,
    ccs_procedure_code,
    ccs_procedure_description,
    apr_drg_description,
    apr_severity_of_illness_code,
    apr_severity_of_illness_description,
    apr_risk_of_mortality,
    apr_medical_surgical_description,
    payment_typology_1,
    CAST(TRIM(REPLACE(length_of_stay, ' +', '')) AS INTEGER) AS length_of_stay,
    total_charges,
    total_costs,
    CASE WHEN total_costs = 0 OR total_charges < 1 THEN 1 ELSE 0 END AS bad_cost_flag
FROM discharges;


-- ----------------------------------------------------------------
-- 1. TOP 15 PRIMARY DIAGNOSES BY DISCHARGE VOLUME
-- ----------------------------------------------------------------

SELECT
    ccs_diagnosis_description AS diagnosis,
    COUNT(*) AS total_cases,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM discharges_clean), 2) AS pct_of_total
FROM discharges_clean
GROUP BY ccs_diagnosis_description
ORDER BY total_cases DESC
LIMIT 15;


-- ----------------------------------------------------------------
-- 2. AVERAGE COST AND CHARGES BY AGE GROUP
-- ----------------------------------------------------------------

SELECT
    age_group,
    COUNT(*) AS total_cases,
    ROUND(AVG(total_costs), 2) AS avg_cost,
    ROUND(AVG(total_charges), 2) AS avg_charges,
    ROUND(AVG(total_charges) - AVG(total_costs), 2) AS avg_markup
FROM discharges_clean
WHERE bad_cost_flag = 0
GROUP BY age_group
ORDER BY avg_cost DESC;


-- ----------------------------------------------------------------
-- 3. LENGTH OF STAY AND COST BY ADMISSION TYPE
-- ----------------------------------------------------------------

SELECT
    type_of_admission,
    COUNT(*) AS total_cases,
    ROUND(AVG(length_of_stay), 1) AS avg_length_of_stay,
    ROUND(AVG(total_costs), 2) AS avg_cost
FROM discharges_clean
WHERE bad_cost_flag = 0
GROUP BY type_of_admission
ORDER BY avg_length_of_stay DESC;


-- ----------------------------------------------------------------
-- 4. AVERAGE COST AND STAY BY SEVERITY OF ILLNESS
-- ----------------------------------------------------------------

SELECT
    apr_severity_of_illness_code AS severity_code,
    apr_severity_of_illness_description AS severity,
    COUNT(*) AS total_cases,
    ROUND(AVG(length_of_stay), 1) AS avg_stay,
    ROUND(AVG(total_costs), 2) AS avg_cost,
    ROUND(AVG(total_charges), 2) AS avg_charges
FROM discharges_clean
WHERE bad_cost_flag = 0
GROUP BY apr_severity_of_illness_code, apr_severity_of_illness_description
ORDER BY severity_code ASC;


-- ----------------------------------------------------------------
-- 5. MOST EXPENSIVE DIAGNOSES BY AVERAGE COST
--    Minimum 1,000 cases to filter statistical noise
-- ----------------------------------------------------------------

SELECT
    ccs_diagnosis_description AS diagnosis,
    COUNT(*) AS total_cases,
    ROUND(AVG(total_costs), 2) AS avg_cost,
    ROUND(AVG(length_of_stay), 1) AS avg_stay
FROM discharges_clean
WHERE bad_cost_flag = 0
GROUP BY ccs_diagnosis_description
HAVING COUNT(*) >= 1000
ORDER BY avg_cost DESC
LIMIT 15;


-- ----------------------------------------------------------------
-- 6. AVERAGE COST AND CHARGES BY REGION
-- ----------------------------------------------------------------

SELECT
    health_service_area,
    COUNT(*) AS total_cases,
    ROUND(AVG(total_costs), 2) AS avg_cost,
    ROUND(AVG(total_charges), 2) AS avg_charges,
    ROUND(AVG(length_of_stay), 1) AS avg_stay
FROM discharges_clean
WHERE bad_cost_flag = 0
GROUP BY health_service_area
ORDER BY avg_cost DESC;


-- ----------------------------------------------------------------
-- 7. CASE VOLUME AND AVERAGE COST BY PAYMENT TYPE
-- ----------------------------------------------------------------

SELECT
    payment_typology_1 AS payment_type,
    COUNT(*) AS total_cases,
    ROUND(AVG(total_costs), 2) AS avg_cost,
    ROUND(AVG(total_charges), 2) AS avg_charges
FROM discharges_clean
WHERE bad_cost_flag = 0
    AND payment_typology_1 IS NOT NULL
GROUP BY payment_typology_1
ORDER BY total_cases DESC;