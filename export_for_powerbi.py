import sqlite3
import pandas as pd

conn = sqlite3.connect("data/healthcare.db")

# Cost by age group
cost_by_age = pd.read_sql("""
    SELECT age_group, COUNT(*) AS total_cases,
        ROUND(AVG(total_costs), 2) AS avg_cost,
        ROUND(AVG(total_charges), 2) AS avg_charges
    FROM discharges_clean
    WHERE bad_cost_flag = 0
    GROUP BY age_group
    ORDER BY avg_cost DESC
""", conn)
cost_by_age.to_csv("data/powerbi_cost_by_age.csv", index=False)

# Cost by severity
cost_by_severity = pd.read_sql("""
    SELECT apr_severity_of_illness_description AS severity,
        apr_severity_of_illness_code AS severity_code,
        COUNT(*) AS total_cases,
        ROUND(AVG(total_costs), 2) AS avg_cost,
        ROUND(AVG(length_of_stay), 1) AS avg_stay
    FROM discharges_clean
    WHERE bad_cost_flag = 0
        AND apr_severity_of_illness_code != 0
    GROUP BY severity, severity_code
    ORDER BY severity_code ASC
""", conn)
cost_by_severity.to_csv("data/powerbi_cost_by_severity.csv", index=False)

# Cost by region
cost_by_region = pd.read_sql("""
    SELECT health_service_area AS region,
        COUNT(*) AS total_cases,
        ROUND(AVG(total_costs), 2) AS avg_cost,
        ROUND(AVG(total_charges), 2) AS avg_charges,
        ROUND(AVG(length_of_stay), 1) AS avg_stay
    FROM discharges_clean
    WHERE bad_cost_flag = 0
        AND health_service_area IS NOT NULL
    GROUP BY region
    ORDER BY avg_cost DESC
""", conn)
cost_by_region.to_csv("data/powerbi_cost_by_region.csv", index=False)

# Cost by admission type
cost_by_admission = pd.read_sql("""
    SELECT type_of_admission,
        COUNT(*) AS total_cases,
        ROUND(AVG(total_costs), 2) AS avg_cost,
        ROUND(AVG(length_of_stay), 1) AS avg_stay
    FROM discharges_clean
    WHERE bad_cost_flag = 0
    GROUP BY type_of_admission
    ORDER BY total_cases DESC
""", conn)
cost_by_admission.to_csv("data/powerbi_cost_by_admission.csv", index=False)

# Cost by payment type
cost_by_payment = pd.read_sql("""
    SELECT payment_typology_1 AS payment_type,
        COUNT(*) AS total_cases,
        ROUND(AVG(total_costs), 2) AS avg_cost
    FROM discharges_clean
    WHERE bad_cost_flag = 0
        AND payment_typology_1 IS NOT NULL
        AND payment_typology_1 NOT IN ('Unknown', 'Miscellaneous/Other')
    GROUP BY payment_type
    ORDER BY total_cases DESC
""", conn)
cost_by_payment.to_csv("data/powerbi_cost_by_payment.csv", index=False)

# Top diagnoses
top_diagnoses = pd.read_sql("""
    SELECT ccs_diagnosis_description AS diagnosis,
        COUNT(*) AS total_cases,
        ROUND(AVG(total_costs), 2) AS avg_cost
    FROM discharges_clean
    WHERE ccs_diagnosis_description != 'Liveborn'
    GROUP BY diagnosis
    ORDER BY total_cases DESC
    LIMIT 14
""", conn)
top_diagnoses.to_csv("data/powerbi_top_diagnoses.csv", index=False)

conn.close()
print("✓ All CSVs exported to data/ folder")