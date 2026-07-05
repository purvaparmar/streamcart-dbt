--just a base cte
with cte1 as (
    select
        order_id,
        order_date,
        month(order_date) as order_month,
        year(order_date)  as order_year,
        category,
        channel,
        gross_amount,
        net_amount,
        discount_pct
    from {{ ref('fct_orders') }}
    where payment_status = 'success'

--now month wise aggregation
), cte2 as (
    select
        order_year,
        order_month,
        COUNT(DISTINCT order_id)       as total_orders,
        SUM(gross_amount)               as total_gross_revenue,
        SUM(net_amount)                 as total_net_revenue,
        SUM(gross_amount - net_amount)  as total_discount_given,
        AVG(discount_pct)               as avg_discount_pct
    from cte1
    group by 1,2

), cte3 as (
    select
        order_year,
        order_month,
        category as top_category,
        sum(net_amount) as category_net_revenue
    from cte1
    group by order_year, order_month, category
    QUALIFY ROW_NUMBER() OVER(
        PARTITION BY order_year, order_month
        ORDER BY SUM(net_amount) DESC, category ASC
    ) = 1

), cte4 as (
    select
        order_year,
        order_month,
        channel as top_channel,
        count(distinct order_id) as channel_order_count
    from cte1
    group by order_year, order_month, channel
    QUALIFY ROW_NUMBER() OVER(
        PARTITION BY order_year, order_month
        ORDER BY COUNT(DISTINCT order_id) DESC, channel ASC
    ) = 1
)

select
    cte2.order_year,
    cte2.order_month,
    cte2.total_orders,
    cte2.total_gross_revenue,
    cte2.total_net_revenue,
    cte2.total_discount_given,
    cte2.avg_discount_pct,
    cte3.top_category,
    cte4.top_channel
from cte2
left join cte3 on cte2.order_year = cte3.order_year and cte2.order_month = cte3.order_month
left join cte4 on cte2.order_year = cte4.order_year and cte2.order_month = cte4.order_month
order by cte2.order_year, cte2.order_month