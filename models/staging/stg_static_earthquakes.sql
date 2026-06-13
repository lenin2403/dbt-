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
    network,
    station_count,
    gap,
    distance_to_nearest_station,
    rms_travel_time,
    horizontal_error,
    depth_error,
    magnitude_error,
    magnitude_station_count,
    location_source,
    magnitude_source,
    magnitude_category,
    ingested_at,

    DATE(event_time) AS event_date,
    EXTRACT(YEAR FROM event_time) AS event_year,
    EXTRACT(MONTH FROM event_time) AS event_month,
    EXTRACT(DAY FROM event_time) AS event_day,
    EXTRACT(HOUR FROM event_time) AS event_hour,

    CASE
        WHEN depth_km < 70 THEN 'Shallow'
        WHEN depth_km >= 70 AND depth_km < 300 THEN 'Intermediate'
        ELSE 'Deep'
    END AS depth_category,

    'static_csv' AS data_source

FROM {{ source('earthquake_raw', 'static_earthquake_data') }}

WHERE earthquake_id IS NOT NULL
  AND event_time IS NOT NULL
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL
  AND magnitude IS NOT NULL