
with dim_track as  (
    SELECT 
        t.TRACK_ID,
        t.TRACK_NAME,
        t.ALBUM_TITLE,
        t.ARTIST_NAME,
        t.GENRE_NAME,
        t.MEDIA_TYPE_NAME,
        t.COMPOSER,
        t.SECONDS,
        t.BYTES
    FROM {{ ref('int_tracks') }} t
)

SELECT * FROM dim_track