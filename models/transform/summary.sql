SELECT
    product_category
    , sum(product_viewed) as total_products_viewed
    , sum(product_added) as total_products_added
    , sum(cart_viewed) as total_cart_viewed
    , sum(checkout_started) as total_checkout_started
    , sum(order_completed) as total_orders_completed
    , total_products_viewed + total_products_added + total_cart_viewed + total_checkout_started + total_orders_completed as total_interactions
    , total_orders
    , total_customers_ordered
    , total_revenue
FROM {{ ref('transaction_journey')}}
GROUP BY product_category

-- what if there's any product categories with no data? they should still be included as 0s