
WITH date_spine AS (
    SELECT 
        SEQ4() AS day_offset 
    FROM TABLE(GENERATOR(ROWCOUNT => 11000))
),

calculated_dates AS (
    SELECT 
        DATEADD(day, day_offset, '2000-01-01'::DATE) AS full_date
    FROM date_spine
),

final_attributes AS (
    SELECT
        TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS DATE_KEY,
        full_date as FULL_DATE,
        
        EXTRACT(year FROM full_date) AS YEAR,
        EXTRACT(quarter FROM full_date) AS QUARTER,
        CONCAT('Q', EXTRACT(quarter FROM full_date)) AS QUARTER_NAME,
        
        EXTRACT(month FROM full_date) AS MONTH_NUMBER,
        TO_CHAR(full_date, 'MMMM') AS MONTH_NAME, 
        TO_CHAR(full_date, 'MON') AS MONTH_SHORT_NAME,

        EXTRACT(week FROM full_date) AS WEEK_OF_YEAR,
        EXTRACT(day FROM full_date) AS DAY_OF_MONTH,
        EXTRACT(dayofweek FROM full_date) AS DAY_OF_WEEK_NUMBER,
        TO_CHAR(full_date, 'DAY') AS DAY_NAME, 
        
        CASE 
            WHEN EXTRACT(dayofweek FROM full_date) IN (6, 0) THEN TRUE 
            ELSE FALSE 
        END AS IS_WEEKEND
    FROM calculated_dates
    WHERE full_date <= '2030-12-31'::DATE
)

SELECT * FROM final_attributes 
ORDER BY FULL_DATE ASC