
with dim_employees as  (
    SELECT 
        e.EMPLOYEE_ID,
        e.EMPLOYEE_FULL_NAME as FULL_NAME,
        e.EMPLOYEE_TITLE as TITLE,
        e.HIRE_DATE,
        e.EMPLOYEE_CITY as CITY,
        e.EMPLOYEE_COUNTRY as COUNTRY,
        e.REPORTS_TO,
        e.MANAGER_FULL_NAME,
        e.MANAGER_TITLE
    FROM {{ ref('int_employees') }} e
)

SELECT * FROM dim_employees