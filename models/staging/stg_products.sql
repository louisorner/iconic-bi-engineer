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
    -- assumption of prices being included incorrectly
    , abs(price) as price
    , image
    , gender_affinity
    , case
        when current_stock < 0 then 0
        else current_stock
        end
    as current_stock
FROM {{ source('biengineer', 'raw-products')}}
