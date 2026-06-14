{{ config(materialized='table') }}

WITH earthquakes AS (

    SELECT *
    FROM {{ ref('fct_earthquake_analysis') }}
    WHERE latitude IS NOT NULL
      AND longitude IS NOT NULL

),

plate_distances AS (

    SELECT
        e.*,

        p.boundary_name AS nearest_plate_boundary,
        p.boundary_type AS nearest_plate_boundary_type,
        p.boundary_length_km AS nearest_plate_boundary_length_km,

        ROUND(
            ST_DISTANCE(
                ST_GEOGPOINT(e.longitude, e.latitude),
                p.boundary_geography
            ) / 1000,
            2
        ) AS distance_to_plate_boundary_km,

        ROW_NUMBER() OVER (
            PARTITION BY e.earthquake_id, e.data_source, e.event_time
            ORDER BY ST_DISTANCE(
                ST_GEOGPOINT(e.longitude, e.latitude),
                p.boundary_geography
            )
        ) AS plate_rank

    FROM earthquakes e
    CROSS JOIN {{ ref('stg_tectonic_plates') }} p

)

SELECT
    * EXCEPT(plate_rank),

    CASE
        WHEN distance_to_plate_boundary_km <= 250 THEN TRUE
        ELSE FALSE
    END AS is_near_plate_boundary

FROM plate_distances

WHERE plate_rank = 1