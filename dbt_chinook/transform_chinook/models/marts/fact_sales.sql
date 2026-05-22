
WITH invoices AS (
    SELECT * FROM {{ source('chinook_raw', 'INVOICE') }}
),

invoice_lines AS (
    SELECT * FROM {{ source('chinook_raw', 'INVOICE_LINE') }}
),

fact_sales AS (
    SELECT
        
        il.INVOICE_LINE_ID AS FACT_SALES_ID, 
        i.INVOICE_ID,
        i.CUSTOMER_ID,
        il.TRACK_ID,

        TO_NUMBER(TO_CHAR(i.INVOICE_DATE, 'YYYYMMDD')) AS INVOICE_DATE_KEY,

        il.UNIT_PRICE,
        il.QUANTITY,
        
        (il.UNIT_PRICE * il.QUANTITY) AS EXTENDED_AMOUNT

    FROM invoice_lines il
    JOIN invoices i 
        ON il.INVOICE_ID = i.INVOICE_ID
)

SELECT * FROM fact_sales