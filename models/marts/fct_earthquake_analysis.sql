{{ config(materialized='table') }}

WITH static_earthquakes AS (

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
        magnitude_category,
        depth_category,
        event_date,
        event_year,
        event_month,
        event_day,
        event_hour,
        data_source,
        ingested_at
    FROM {{ ref('stg_static_earthquakes') }}

),

realtime_earthquakes AS (

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
        magnitude_category,
        depth_category,
        event_date,
        event_year,
        event_month,
        event_day,
        event_hour,
        data_source,
        ingested_at
    FROM {{ ref('stg_realtime_earthquakes') }}

),

combined_earthquakes AS (

    SELECT * FROM static_earthquakes

    UNION ALL

    SELECT * FROM realtime_earthquakes

)

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
    magnitude_category,
    depth_category,
    event_date,
    event_year,
    event_month,
    event_day,
    event_hour,
    data_source,
    ingested_at,

    CASE
        WHEN magnitude >= 5.0 THEN TRUE
        ELSE FALSE
    END AS is_significant_earthquake,

    CASE
        WHEN depth_category = 'Shallow' AND magnitude >= 4.0 THEN TRUE
        ELSE FALSE
    END AS is_potentially_high_impact

FROM combined_earthquakes