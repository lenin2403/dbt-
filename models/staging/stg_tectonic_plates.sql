{{ config(materialized='view') }}

SELECT
    boundary_id,
    boundary_name,
    boundary_type,
    geometry_type,

    ST_GEOGFROMTEXT(boundary_wkt) AS boundary_geography,

    ROUND(
        ST_LENGTH(ST_GEOGFROMTEXT(boundary_wkt)) / 1000,
        2
    ) AS boundary_length_km,

    source_url,
    ingested_at

FROM {{ source('earthquake_raw', 'tectonic_plate_boundaries') }}

WHERE boundary_id IS NOT NULL
  AND boundary_wkt IS NOT NULL