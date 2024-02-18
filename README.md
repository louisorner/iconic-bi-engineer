### THE ICONIC BI_Engineer Tech Challenge

### Process
Num | Item | Detail
---|---|---
1 | Data Gathering | <ul><li>Zip file was extracted and saved in GCP Cloud Storage</li><li>Created datasets and raw tables in BigQuery from these extracts</li><li>TODO: Create python script to directly point to zip on GitHub and extract filed into Cloud Storage, run using Cloud Run/Function</li></ul>
2 | Data Cleaning | See info below on Risks, Issues, Assumptions
3 | Data Transformation | <ul><li>DBT was used to create models to transform raw datasets into staging tables and transforms these into further views</li><li></li></ul>
4 | Data Analysis | See below on analysis
5 | Data Visualisation | See attached PowerBI dashboard screenshots


### Analysis

1. Which event has low transition rate and can you let us know the transition rate across each of the events?

The movement from ProductAdd events to Cart Viewed events has the lowest transition rate.

```
select 
  sum(case when product_added is not null and product_viewed is not null then 1 end)/sum(case when product_viewed is not null then 1 end) as product_viewed_to_product_added
  , sum(case when cart_viewed is not null and product_added is not null then 1 end)/sum(case when product_added is not null then 1 end) as product_added_to_cart_viewed
  , sum(case when checkout_started is not null and cart_viewed is not null then 1 end)/sum(case when cart_viewed is not null then 1 end) as cart_viewed_to_checkout_started
  , sum(case when order_completed is not null and checkout_started is not null then 1 end)/sum(case when checkout_started is not null then 1 end) as checkout_started_to_order_completed
from `iconic-interview-20240213.dbt_biengineer.transaction_journey`
;
```
Row	| product_viewed_to_product_added | product_added_to_cart_viewed | cart_viewed_to_checkout_started | checkout_started_to_order_completed
---|---|---|---|---
1 | 0.16264933829495537 | 0.15105577774910764 | 0.20018570740766214 | 0.50004298117424573


2. What is the percentage of Cart abandonment across the store, where Cart abandonment consists of events_type (Added to cart and checkout started) but orders are not completed?

```
select 
    sum(case when checkout_started is not null and product_added is not null and order_completed is null then 1 end)/sum(case when checkout_started is not null then 1 end) as cart_abndnd_pct
from `iconic-interview-20240213.dbt_biengineer.transaction_journey``
;

The cart abandonment rate is rounded to 50%

```
Row | cart_abndnd_pct
---|---
1 | 0.49995701882575


3. Find the average duration between checkout started and order completed and do you find any anomaly in the data?

- 2.51 seconds is the average duration between checkout started and order completed.
- This time duration is distributed well across the discrete second options between it's minimum (0) and maximum (5)
- These durations do not feel consistent with general checkout processes considering how quick they are, and how they're never longer than 5 seconds.
- There are cases of 0 second durations, which could only realistically be explained with auto-order user actions which start and end the checkout function in one step with pre-saved information.

```
select 
  avg(TIMESTAMP_DIFF(order_completed, checkout_started, second)) as avg_diff
  , min(TIMESTAMP_DIFF(order_completed, checkout_started, second)) as min_diff
  , max(TIMESTAMP_DIFF(order_completed, checkout_started, second)) as max_diff
  , sum(case when TIMESTAMP_DIFF(order_completed, checkout_started, second) = 0 then 1 end) as count_0s
  , sum(case when TIMESTAMP_DIFF(order_completed, checkout_started, second) = 1 then 1 end) as count_1s
  , sum(case when TIMESTAMP_DIFF(order_completed, checkout_started, second) = 2 then 1 end) as count_2s
  , sum(case when TIMESTAMP_DIFF(order_completed, checkout_started, second) = 3 then 1 end) as count_3s
  , sum(case when TIMESTAMP_DIFF(order_completed, checkout_started, second) = 4 then 1 end) as count_4s
  , sum(case when TIMESTAMP_DIFF(order_completed, checkout_started, second) = 5 then 1 end) as count_5s   
from `iconic-interview-20240213.dbt_biengineer.transaction_journey`
where order_completed is not null
;
```

Row	| avg_diff | min_diff | max_diff | count_0s | count_1s | count_2s | count_3s | count_4s | count_5s
---|---|---|---|---|---|---|---|---|---
1 | 2.5098848203541348 | 0 | 5 | 984 | 951 | 969 | 958 | 938 | 1017

### Risks
Num | Detail | Proposed Mitigation
---|---|---
1 | The Users table has a column for plural 'addresses' and stores json strings in a list. This model will need to be reworked if users are allowed multiple addresses | Perhaps a slowly changing dimension type 2 could be used in a seperate Address table
2 | This case study and datasets present a linear flow of the product ordering process. | Further analysis and datapoints would be needed to consider the seperation of ProductView/ProductAdd (individual items) against CartView/CheckoutStarted/OrderCompleted events (grouping of items)

### Issues
Num | Detail | Action
---|---|---
1 | User email addresses should be unique. There are 442 users sharing 206 emails in this dataset | Treating them as separate users for this analysis based on user_id, but this needs to be rectified (unless partnered accounts are allowed) 
2 | 349 interaction records have no user_id assigned. Based on assumption #3 this should not be allowed. This was not isolated to a subset of timestamps and therefore appears to be a long term issue | As only $107 of revenue is attibuted to OverCompletions within events of this nature, they have been removed from the staged interactions table and subsequent analysis. A seperate table stg_interaction_missing_user has been added to keep a log of these cases for further investigations
3 | Based on assumption #5, duplicate interactions have been excluded in the staging table. These were limited to ProductAdd events | These cases have been removed from the stg_interactions table and need to be investigated.
4 | Discount amount/percent is not provided. | True revenue amounts do not take discounts into consideration
5 | There are 3 products with both negative current stock amounts and negative pricing. Neither should be allowed. | 1) The current stock of these products has been set to 0. 2) Pricing has been set to the absolute value as this fits into same vicinity of other products with the same name/details. (This needs to be validated) 3) A stg_products_data_issues table has been created to list these issues for further analysis and debugging. 

### Assumptions
Num | Detail | Further actions
---|---|---
1 | Products can share the same name and description price yet be unique (perhaps size, variant, colour distinguishes them) | 
2 | Users can interact with the same product on multiple occasions, even after a OrderCompletion takes place. Therefore TransactionJourneys need to be broken up into 'sessions'. For this analysis 60min of elapsed time has been chosen to denote a new session. | <ul><li>I investigated bringing the txn_joruney down to the day granularity as a 'session', but found there were times where the event_types progressed at different hours throughout the day. </li><li>The 'discount' flag helped to differentiate sessions, as I could see some events at 10am with a TRUE discount, then some more events at 4pm with a FALSE flag as an example. </li><li>Hour segments were considered for this session time, but this wouldn't cater for events starting at x1:59 and continuing to x2:00. </li><li>Perhaps I should keep it as a rolling situation, that if xxx time elapses then it should move to a different session. </li><li>The discount flag should be consistent per session, so I can use this to confirm my sessions are granular enough. </li><li>Did some analysis using 60 min as the session time, and found cases of the discount flag changing within two events as low as 1min apart, but only on the ProductView event, not on other events.</li></ul>
3 | Anonymous browsing is disabled. Users need to be logged in to perform any events | 
4 | Total_orders in the User Journey table denotes to completed orders as the description mentions 'placed' orders as opposed to orders initiated but not placed. | 
5 | Two equal events cannot take place at the same second by the same user on the same product. |
6 | Each user only has one address. The field is plural and uses a list of json string, but assuming for this exercise there is only one address per user. |

