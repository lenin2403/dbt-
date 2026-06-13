{{ config(materialized='view') }}

SELECT
    earthquake_id,
    event_time,
    updated_time,
    latitude,
    longitude,
    depth_km,
    magnitude,
    magnitude_type,
    place,
    type,
    status,
    tsunami,
    significance,
    alert,
    felt,
    cdi,
    mmi,
    url,
    detail_url,
    ingestion_source,
    ingested_at,

    DATE(event_time) AS event_date,
    EXTRACT(YEAR FROM event_time) AS event_year,
    EXTRACT(MONTH FROM event_time) AS event_month,
    EXTRACT(DAY FROM event_time) AS event_day,
    EXTRACT(HOUR FROM event_time) AS event_hour,

    CASE
        WHEN magnitude < 2.0 THEN 'Micro'
        WHEN magnitude >= 2.0 AND magnitude < 4.0 THEN 'Minor'
        WHEN magnitude >= 4.0 AND magnitude < 5.0 THEN 'Light'
        WHEN magnitude >= 5.0 AND magnitude < 6.0 THEN 'Moderate'
        ELSE 'Strong'
    END AS magnitude_category,

    CASE
        WHEN depth_km < 70 THEN 'Shallow'
        WHEN depth_km >= 70 AND depth_km < 300 THEN 'Intermediate'
        ELSE 'Deep'
    END AS depth_category,

    'realtime_api' AS data_source

FROM {{ source('earthquake_raw', 'realtime_earthquake_data') }}

WHERE earthquake_id IS NOT NULL
  AND event_time IS NOT NULL
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL