### THE ICONIC BI_Engineer Tech Challenge

### Process
# | Item | Detail
---|---|---
1 | Data Gathering | <ul><li>First</li><li>Second</li></ul>
2 | Data Cleaning | <br>test <br> test 
3 |
4 | 


### Analysis

1. Which event has low transition rate and can you let us know the transition rate across each of the events?

```

```
2. What is the percentage of Cart abandonment across the store, where Cart abandonment consists of events_type (Added to cart and checkout started) but orders are not completed?

```
```

3. Find the average duration between checkout started and order completed and do you find any anomaly in the data?

```
```

### Risks
# | Detail | Proposed Mitigation
---|---|---
1 | The Users table has a column for plural 'addresses' and stores json strings in a list. This model will need to be reworked if users are allowed multiple addresses | Perhaps a slowly changing dimension type 2 could be used in a seperate Address table

### Issues
# | Detail | Action
---|---|---
1 | User email addresses should be unique. There are 442 users sharing 206 emails in this dataset | Treating them as separate users for this analysis based on user_id, but this needs to be rectified
2 | 349 interaction records have no user_id assigned. Based on assumption #3 this should not be allowed. This was not isolated to a subset of timestamps and therefore appears to be a long term issue | As only $107 of revenue is attibuted to OverCompletions within events of this nature, they have been removed from the staged interactions table. A seperate table stg_interaction_missing_user has been added to keep a log of these cases for further investigations
3 | Based on assumption #5, duplicate interactions have been excluded in the staging table. | These cases have been removed from the stg_interactions table and need to be investigated.
4 | Discount amount/percent is not provided. | True revenue amounts do not take discounts into consideration
5 | There are 3 products with both negative current stock amounts and negative pricing. Neither should be allowed. | 1) The current stock of these products has been set to 0. 2) Pricing has been set to the absolute value as this fits into same vicinity of other products with the same name/details. (This needs to be validated) 3) A stg_products_data_issues table has been created to list these issues for further analysis and debugging. 

### Assumptions
# | Detail | Further actions
---|---|---
1 | Products can share the same name and description price yet be unique (perhaps size, variant, colour distinguishes them) | 
2 | Users can interact with the same product on multiple occasions, even after a OrderCompletion takes place. Therefore TransactionJourneys need to be broken up into 'sessions'. For this analysis 60min of elapsed time has been chosen to denote a new session. | I investigated bringing the txn_joruney down to the day granularity as a 'session', but found there were times where the event_types progressed at different hours throughout the day. The 'discount' flag helped to differentiate sessions, as I could see some events at 10am with a TRUE discount, then some more events at 4pm with a FALSE flag as an example.  Hour segments were considered for this session time, but this wouldn't cater for events starting at x1:59 and continuing to x2:00. Perhaps I should keep it as a rolling situation, that if xxx time elapses then it should move to a different session. The discount flag should be consistent per session, so I can use this to confirm my sessions are granular enough. Did some analysis using 60 min as the session time, and found cases of the discount flag changing within two events as low as 1min apart, but only on the ProductView event, not on other events.
3 | Anonymous browsing is disabled. Users need to be logged in to perform any events | 
4 | Total_orders in the User Journey table denotes to completed orders as the description mentions 'placed' orders as opposed to orders initiated but not placed. | 
5 | Two equal events cannot take place at the same second by the same user on the same product. |
6 | Each user only has one address. The field is plural and uses a list of json string, but assuming for this exercise there is only one address per user. |



### Other Observations
# | Details
---|---
1 | Product gender affinity is always set when description mentions gender (men/women)
