{{ config(
    materialized='table'
) }}

SELECT 
    id
    , url
    , name
    , category
    , style
    , description
    , price
    , image
    , gender_affinity
    , current_stock
FROM {{ source('biengineer', 'raw-products')}}
WHERE price < 0 or current_stock < 0