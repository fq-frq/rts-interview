{{ config(materialized='table') }}

WITH source_data AS (
    SELECT country_code,
        region_code,
        city 
    FROM {{ ref('stg_extract_udp_srf') }}
),

cleaned AS (
    SELECT DISTINCT
        upper(trim(country_code)) AS country_code,
        upper(trim(region_code)) AS region_code,
        upper(trim(city)) AS city
    FROM source_data
),

add_pk AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['country_code', 'region_code', 'city']) }} AS location_id,
        country_code,
        region_code,
        city
    FROM cleaned
)

SELECT * FROM add_pk
