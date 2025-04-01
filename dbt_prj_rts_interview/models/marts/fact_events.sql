{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ ref('stg_extract_udp_srf') }}
),
cleaned AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['SESSION_ID', 'EVENT_ARRIVAL_TIME_CET', 'ITEM_URN']) }} AS event_id,
        EVENT_ARRIVAL_TIME_CET AS event_timestamp,
        SESSION_ID AS session_id,
        USER_ID AS user_id,
        PROFILE_ID AS profile_id,
        DEVICE_ID AS device_id,
        DEVICE_TYPE AS device_type,
        USER_AGENT AS user_agent,
        {{ dbt_utils.generate_surrogate_key(['lower(COUNTRY_CODE)', 'lower(REGION_CODE)', 'lower(CITY)']) }} AS location_id,
        PAGE_ID AS page_id,
        CONTENT_PAGE_TYPE AS page_type,
        CONCAT(NAVIGATION_PATH_SRG_MOD_1, ' > ', NAVIGATION_PATH_SRG_MOD_2, ' > ', NAVIGATION_PATH_SRG_MOD_3, ' > ', NAVIGATION_PATH_SRG_MOD_4) AS navigation_path,
        CONTENT_ID AS content_id,
        CONTENT_CATEGORY_1 AS content_category,
        CONTENT_TITLE_PRETTY AS content_title,
        SPLIT(ITEM_URN, ':')[-1] AS media_id, -- Extract media ID from URN
        MEDIA_CHANNEL AS media_channel,
        MEDIA_IS_LIVESTREAM AS media_is_livestream,
        MEDIA_EPISODE_LENGTH AS media_duration,
        MEDIA_SEGMENT_LENGTH AS media_watched_duration,
        TYPE AS event_type,
        REFERRER AS referrer_url,
        IS_BOT AS is_bot
    FROM source
)

SELECT * FROM cleaned
