{{ config(materialized='table') }}

WITH source_data AS (
    SELECT content_id,
    content_title,
    content_title_pretty,
    content_category_1,
    content_category_2,
    content_category_3,
    content_category_4,
    content_page_type,
    content_page_elements,
    content_publication_datetime,
    content_modification_datetime,
    content_publication_version
    FROM {{ ref('stg_extract_udp_srf') }}
),

cleaned AS (
    SELECT content_id,
    content_title,
    trim(content_title_pretty) as content_title_pretty,
    content_category_1,
    content_category_2,
    content_category_3,
    content_category_4,
    lower(trim(content_page_type)) as content_page_type,
    content_page_elements,
    content_publication_datetime,
    content_modification_datetime,
    content_publication_version
    FROM source_data
),

enriched AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['content_page_type', 'content_title_pretty']) }} AS content_id, --no data for this field so we generate it for the demo in order to analyze. In real, we need to get it from the business
        content_title,
        content_title_pretty,
        content_category_1,
        content_category_2,
        content_category_3,
        content_category_4,
        content_page_type,
        content_page_elements,
        content_publication_datetime,
        CAST( DATE_FROM_UNIX_DATE(CAST(start + (finish - start) * RAND() AS INT64)) as DATETIME ) as content_modification_datetime, --no data for this field so we generate it for the demo in order to analyze. In real, we need to get it from the business
        content_publication_version
    FROM cleaned,
    UNNEST([STRUCT(UNIX_DATE('2010-01-01') AS start, UNIX_DATE('2025-01-01') AS finish)])
    QUALIFY row_number() OVER (PARTITION BY content_id ORDER BY content_modification_datetime DESC) = 1
)

SELECT * FROM enriched
