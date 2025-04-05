{{ config(materialized='table') }}

SELECT * FROM {{ ref('int_sessions') }}
