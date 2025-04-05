{{ config(materialized='table') }}

WITH source_data AS (
    SELECT session_id,
        session_rank,
        event_arrival_time_cet
    FROM {{ ref('stg_extract_udp_srf') }}
),

kpi_calculation AS (
    select distinct
        session_id,
        min(event_arrival_time_cet) as session_start_time,
        max(event_arrival_time_cet) as session_end_time,
        TIMESTAMP_DIFF(max(event_arrival_time_cet),  min(event_arrival_time_cet), SECOND) as session_duration_seconds,
        max(session_rank) as total_events
    from source_data
    group by session_id
)

SELECT * FROM kpi_calculation
