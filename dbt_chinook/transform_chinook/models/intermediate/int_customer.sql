with customer as (
    SELECT * FROM {{ source('chinook_raw', 'CUSTOMER') }}
),
employee as (
    SELECT * FROM {{ source('chinook_raw', 'EMPLOYEE') }}
)

SELECT 
    c.CUSTOMER_ID,
    c.FIRST_NAME,
    c.LAST_NAME,
    CONCAT(c.FIRST_NAME, ' ', c.LAST_NAME) AS CUSTOMER_FULL_NAME,
    c.EMAIL,
    c.PHONE,
    c.ADDRESS,
    c.COMPANY,
    c.CITY,
    c.STATE,
    c.POSTAL_CODE,
    c.COUNTRY,
    e.EMPLOYEE_ID,
    e.FIRST_NAME AS EMPLOYEE_FIRST_NAME,
    e.LAST_NAME AS EMPLOYEE_LAST_NAME,
    CONCAT(e.FIRST_NAME, ' ', e.LAST_NAME) AS EMPLOYEE_FULL_NAME,
    e.TITLE AS EMPLOYEE_TITLE
FROM customer c
LEFT JOIN employee e ON c.SUPPORT_REP_ID = e.EMPLOYEE_ID