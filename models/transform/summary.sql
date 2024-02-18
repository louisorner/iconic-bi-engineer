SELECT 
  p.category as product_category
  , SUM(case when i.event_type = 'ProductViewed' then 1 end) as total_products_viewed
  , SUM(case when i.event_type = 'ProductAdded' then 1 end) as total_products_added
  , SUM(case when i.event_type = 'CartViewed' then 1 end) as total_cart_viewed
  , SUM(case when i.event_type = 'CheckoutStarted' then 1 end) as total_checkout_started
  , SUM(case when i.event_type = 'OrderCompleted' then 1 end) as total_orders_completed
  , COUNT(*) as total_interactions
  -- total_orders is defined by total cases of ProductAdded AND CheckoutStarted both occuring. Using session modeling, the latter implies the former has already taken place, therefore this metric can be found purely from total CheckoutStarteds
  -- TODO Model this more carefully from more realistic usage of the platform
  , SUM(case when i.event_type = 'CheckoutStarted' then 1 end) as total_orders
  , COUNT(distinct case when i.event_type = 'OrderCompleted' then i.user_id end) as total_customers_ordered
  , SUM(case when i.event_type = 'OrderCompleted' then p.price end) as total_revenue
FROM {{ ref('stg_interactions')}} i
LEFT JOIN {{ ref('stg_products')}} p on p.id = i.item_id
GROUP BY p.category

-- The below has been disabled as the session concept has lowered the true ProductViewed and ProductAdded events (e.g. from multiple of these events occuring in the same session before a final OrderCompleted event)

-- SELECT
--     product_category
--     , COUNT(product_viewed) as total_products_viewed
--     , COUNT(product_added) as total_products_added
--     , COUNT(cart_viewed) as total_cart_viewed
--     , COUNT(checkout_started) as total_checkout_started
--     , COUNT(order_completed) as total_orders_completed
--     , COUNT(product_viewed) + COUNT(product_added) + COUNT(cart_viewed) + COUNT(checkout_started) + COUNT(order_completed) as total_interactions
--     , SUM(case when product_added is not null and checkout_started is not null then 1 end) as total_orders
--     , COUNT(distinct case when order_completed is not null then user_id end) as total_customers_ordered
--     , SUM(case when order_completed is not null then price end) as total_revenue
-- FROM {{ ref('transaction_journey')}}
-- GROUP BY product_category

-- TODO
-- what if there's any product categories with no data? they should still be included as 0s