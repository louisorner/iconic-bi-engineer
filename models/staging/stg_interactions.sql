{{ config(
    materialized='table'
) }}

WITH incl_row_num as (
    SELECT 
        Item_ID as item_id
        , User_ID as user_id
        , Event_Type as event_type
        , DATETIME(TIMESTAMP_SECONDS(Timestamp)) as timestamp
        , Discount as discount
        , ROW_NUMBER() over (PARTITION BY Item_ID, User_ID, Event_Type, discount, timestamp ORDER BY timestamp) as row_num
    FROM {{ source('biengineer', 'raw-interactions')}}
    WHERE User_ID is not null
)
SELECT 
  item_id
  , user_id
  , event_type
  , timestamp
  , discount
FROM incl_row_num
-- only include unique records. Analysis showed duplicates were only on the ProductViewed events
WHERE row_num = 1