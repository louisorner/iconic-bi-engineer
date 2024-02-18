with int_time_elapsed as (
SELECT item_id
        , user_id
        , event_type
        , discount
        , timestamp
        , TIMESTAMP_DIFF(timestamp, LAG(timestamp) over (partition by user_id, item_id order by timestamp), minute) as time_elapsed
    FROM {{ ref('stg_interactions')}}
), int_sessions as (
 SELECT item_id
    , user_id
    , event_type
    , discount
    , timestamp
    , 1 + SUM(IF(time_elapsed > 60, 1, 0)) over (partition by user_id, item_id order by timestamp ) as session_id
FROM int_time_elapsed
)
SELECT
    i.item_id
    , i.user_id
    , p.name as product_name
    , p.category as product_category
    , MAX(case when i.event_type = 'ProductViewed' then i.timestamp end) as product_viewed
    , MAX(case when i.event_type = 'ProductAdded' then i.timestamp end) as product_added
    , MAX(case when i.event_type = 'CartViewed' then i.timestamp end) as cart_viewed
    , MAX(case when i.event_type = 'CheckoutStarted' then i.timestamp end) as checkout_started
    , MAX(case when i.event_type = 'OrderCompleted' then i.timestamp end) as order_completed
    -- TODO fix discount calc to refer to the highest event in hierarchy
    , MAX(case when i.event_type = 'OrderCompleted' then i.discount end) as discount
    , p.price
FROM
    int_sessions i
LEFT JOIN {{ ref('stg_products')}} p on p.id = i.item_id
GROUP BY
    i.item_id
    , i.user_id
    , i.session_id
    , p.name
    , p.category
    , p.price












