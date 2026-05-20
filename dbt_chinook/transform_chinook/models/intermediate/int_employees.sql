-- models/intermediate/int_employees.sql

WITH employees_raw AS (
    SELECT * FROM {{ source('chinook_raw', 'EMPLOYEE') }}
)

SELECT
    e.EMPLOYEE_ID,
    e.FIRST_NAME AS EMPLOYEE_FIRST_NAME,
    e.LAST_NAME AS EMPLOYEE_LAST_NAME,
    CONCAT(e.FIRST_NAME, ' ', e.LAST_NAME) AS EMPLOYEE_FULL_NAME,
    e.TITLE AS EMPLOYEE_TITLE,
    e.BIRTH_DATE,
    e.HIRE_DATE,
    e.CITY AS EMPLOYEE_CITY,
    e.COUNTRY AS EMPLOYEE_COUNTRY,
    e.REPORTS_TO,
    m.FIRST_NAME AS MANAGER_FIRST_NAME,
    m.LAST_NAME AS MANAGER_LAST_NAME,
    -- we used COALESCE if the employee is the CEO, so it doesn't have a manager, we will show "CEO / no manager"
    COALESCE(CONCAT(m.FIRST_NAME, ' ', m.LAST_NAME), 'CEO / no manager') AS MANAGER_FULL_NAME,
    m.TITLE AS MANAGER_TITLE

FROM employees_raw e
LEFT JOIN employees_raw m 
    ON e.REPORTS_TO = m.EMPLOYEE_ID