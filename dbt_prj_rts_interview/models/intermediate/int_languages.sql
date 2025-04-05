{{ config(materialized='table') }}

WITH source_data AS (
    select language,
    from {{ ref('stg_extract_udp_srf') }}
),

cleaned AS (
    select distinct
        lower(trim(language)) as language,
    from source_data
),

enriched AS (
    select
        {{ dbt_utils.generate_surrogate_key(['c.language']) }} AS language_id,
        c.language,
        coalesce(
            concat(lc.language, ' (', cc.name, ')'),
            lc.language
        ) as language_full_name
    from cleaned c
    inner join {{ ref('language_codes') }} lc on split(c.language, '-')[SAFE_OFFSET(0)] = lc.code
    left join {{ ref('country_codes') }} cc on split(c.language, '-')[SAFE_OFFSET(1)] = lower(cc.code)
)

SELECT * FROM enriched
