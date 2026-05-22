
with dim_customer as  (
    SELECT 
        c.CUSTOMER_ID,
        c.CUSTOMER_FULL_NAME as FULL_NAME,
        c.COMPANY,
        c.CITY,
        c.STATE,
        c.COUNTRY,
        c.POSTAL_CODE,
        c.EMAIL,
        c.EMPLOYEE_ID as SUPPORT_REP_ID,
        c.EMPLOYEE_FULL_NAME as SUPPORT_REP_NAME
    FROM {{ ref('int_customer') }} c
)

SELECT * FROM dim_customer