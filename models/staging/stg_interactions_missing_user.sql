{{ config(
    materialized='table'
) }}

SELECT 
    Item_ID as item_id
    , Event_Type as event_type
    , DATETIME(TIMESTAMP_SECONDS(Timestamp)) as timestamp
    , Discount as discount

FROM {{ source('biengineer', 'raw-interactions')}}
WHERE User_ID is  null