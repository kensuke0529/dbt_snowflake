{{ config(materialized='table') }}

with customer_history as (
    select * from {{ ref('int_customer_purchase_history') }}
),

customer_segments as (
    select 
        customer_id,
        customer_email,
        customer_first_name,
        customer_last_name,
        customer_country,
        total_orders,
        total_spent,
        last_order_date,

        case
            when total_orders > 10 then 'VIP'
            when total_orders between 5 and 10 then 'Loyal'
            else 'New'
        end as customer_segment,

        case
            when last_order_date >= dateadd(day, -30, current_date) then 'Active'
            else 'Inactive'
        end as customer_activity_status

    from customer_history
)

select * from customer_segments
