-- models/intermediate/int_tracks.sql

WITH tracks AS (
    SELECT * FROM {{ source('chinook_raw', 'TRACK') }}
),

albums AS (
    SELECT * FROM {{ source('chinook_raw', 'ALBUM') }}
),

artists AS (
    SELECT * FROM {{ source('chinook_raw', 'ARTIST') }}
),

genres AS (
    SELECT * FROM {{ source('chinook_raw', 'GENRE') }}
),

media_types AS (
    SELECT * FROM {{ source('chinook_raw', 'MEDIA_TYPE') }}
)


SELECT
    -- 1. Claves / IDs
    t.TRACK_ID,
    t.ALBUM_ID,
    t.GENRE_ID,
    t.MEDIA_TYPE_ID,
    -- 2. Atributos del Track
    t.NAME AS TRACK_NAME,
    t.COMPOSER,
    t.MILLISECONDS,
    -- Agregamos un cálculo analítico directo: duración en segundos
    ROUND(t.MILLISECONDS / 1000, 2) AS SECONDS,
    t.BYTES,
    t.UNIT_PRICE,
    -- 3. Información desnormalizada (Los Joins)
    al.TITLE AS ALBUM_TITLE,
    art.NAME AS ARTIST_NAME,
    g.NAME AS GENRE_NAME,
    mt.NAME AS MEDIA_TYPE_NAME

FROM tracks t
LEFT JOIN albums al       ON t.ALBUM_ID = al.ALBUM_ID  
LEFT JOIN artists art     ON al.ARTIST_ID = art.ARTIST_ID
LEFT JOIN genres g        ON t.GENRE_ID = g.GENRE_ID
LEFT JOIN media_types mt  ON t.MEDIA_TYPE_ID = mt.MEDIA_TYPE_ID
