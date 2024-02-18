SELECT
    product_category
    , COUNT(product_viewed) as total_products_viewed
    , COUNT(product_added) as total_products_added
    , COUNT(cart_viewed) as total_cart_viewed
    , COUNT(checkout_started) as total_checkout_started
    , COUNT(order_completed) as total_orders_completed
    , COUNT(product_viewed) + COUNT(product_added) + COUNT(cart_viewed) + COUNT(checkout_started) + COUNT(order_completed) as total_interactions
    , SUM(case when product_added is not null and checkout_started is not null then 1 end) as total_orders
    , COUNT(distinct case when order_completed is not null then user_id end) as total_customers_ordered
    , SUM(price) as total_revenue
FROM {{ ref('transaction_journey')}}
GROUP BY product_category

-- TODO
-- what if there's any product categories with no data? they should still be included as 0s