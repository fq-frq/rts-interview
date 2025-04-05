{{ config(materialized='table') }}

WITH source_data AS (
    SELECT 
        business_unit,
        backend_system,
        product,
        event_type,
        cookie_id,                                     
        event_arrival_time_cet,
        session_id,
        full_row_md5,
        url,
        content_id,
        referrer,
        user_agent,
        event_timestamp,
        screen_resolution,
        language,
        application_type,
        event_arrival_time_utc,
        event_arrival_date_utc,
        content_title_pretty,
        content_page_type,
        country_code,
        region_code,
        city,
        is_bot

    FROM {{ ref('stg_extract_udp_srf') }}
),

foreign_keys_calculate AS (
    SELECT 
        business_unit,
        backend_system,
        product,
        event_type,
        cookie_id,                                          
        event_arrival_time_cet,
        session_id,
        full_row_md5,
        url,
        {{ dbt_utils.generate_surrogate_key(['lower(trim(content_page_type))', 'trim(content_title_pretty)']) }} as content_id,
        referrer,
        user_agent,
        event_timestamp,
        screen_resolution,
        {{ dbt_utils.generate_surrogate_key(['trim(language)']) }} as language_id,
        application_type,
        event_arrival_time_utc,
        event_arrival_date_utc,
        {{ dbt_utils.generate_surrogate_key(['upper(trim(country_code))', 'upper(trim(region_code))', 'upper(trim(city))']) }} as location_id,
        is_bot
    FROM source_data
)

SELECT * FROM foreign_keys_calculate
