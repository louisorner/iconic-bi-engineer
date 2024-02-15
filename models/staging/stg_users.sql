{{ config(
    materialized='table'
) }}

SELECT 
    id
    , username
    , email
    , first_name
    , last_name
    , JSON_EXTRACT_SCALAR(addresses, '$[0].address1') AS address1
    , JSON_EXTRACT_SCALAR(addresses, '$[0].city') AS city
    , JSON_EXTRACT_SCALAR(addresses, '$[0].state') AS state
    , JSON_EXTRACT_SCALAR(addresses, '$[0].zipcode') AS zipcode
    , JSON_EXTRACT_SCALAR(addresses, '$[0].country') AS country
    , age
    , gender
    , persona
    , discount_persona
FROM {{ source('biengineer', 'raw-users')}}