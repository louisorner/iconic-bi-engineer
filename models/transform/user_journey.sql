SELECT
    u.id as user_id
    , u.username
    , u.email
    , u.first_name
    , u.last_name
    , u.address1
    , u.country
    , u.city
    , u.state
    , u.zipcode
    , SUM(case when i.event_type = 'OrderCompleted' then 1 else 0 end) as total_orders
FROM {{ ref('stg_users')}} u
LEFT JOIN {{ ref('stg_interactions')}} i on u.id = i.user_id
GROUP BY
    u.id
    , u.username
    , u.email
    , u.first_name
    , u.last_name
    , u.address1
    , u.country
    , u.city
    , u.state
    , u.zipcode