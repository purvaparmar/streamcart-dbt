with cte1 as (
    select
    order_date,
    channel,
    payment_method,
    count(*) as cnt
    from {{ ref('fct_orders') }}
    group by order_date,channel, payment_method
    QUALIFY ROW_NUMBER() OVER(
        partition by order_date, channel
        order by count(*) desc, payment_method asc
    ) = 1
),cte2 as (select
order_date,
channel,
count(distinct order_id) as total_orders,
sum(case when payment_status = 'success' then 1 else 0 end) as successfull_orders,
sum(case when payment_status = 'failed' then 1 else 0 end) as cancelled_orders,
sum(case when payment_status = 'success' then 1 else 0 end)*100.0 / nullif(count(distinct order_id),0) as success_rate_pct,
sum(gross_amount) as total_gross_revenue,
sum(net_amount) as total_net_revenue,
avg(net_amount) as avg_order_value
from {{ ref('fct_orders') }}
group by order_date, channel)
select
cte1.order_date,
cte1.channel,
cte2.total_orders,
cte2.successfull_orders,
cte2.cancelled_orders,
cte2.success_rate_pct,
cte2.total_gross_revenue,
cte2.total_net_revenue,
cte2.avg_order_value,
cte1.payment_method
from cte1
left join cte2 on cte1.order_date = cte2.order_date and cte1.channel = cte2.channel