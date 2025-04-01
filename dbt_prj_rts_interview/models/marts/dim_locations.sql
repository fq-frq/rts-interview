{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ ref('stg_extract_udp_srf') }}
),
cleaned AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['lower(COUNTRY_CODE)', 'lower(REGION_CODE)', 'lower(CITY)']) }} AS location_id,
        COUNTRY_CODE AS country_code,
        REGION_CODE AS region_code,
        CITY AS city
    FROM source
    QUALIFY row_number() OVER (PARTITION BY lower(COUNTRY_CODE), lower(REGION_CODE), lower(CITY) ORDER BY FULL_ROW_MD5) = 1
)

SELECT * FROM cleaned
