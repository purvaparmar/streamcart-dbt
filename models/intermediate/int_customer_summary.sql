select
customer_id,
customer_name,
email,
phone,
customer_tier,
city,
country_code,
count(order_id) as total_orders,
SUM(gross_amount) as total_gross_revenue,
SUM(net_amount) as total_net_revenue,
SUM(net_amount)/COUNT(order_id) as avg_order_value,
DATEDIFF('day',MAX(order_date),GETDATE()) AS days_since_last_order,
case when COUNT(order_id) >= 10  then 'Platinum'
when COUNT(order_id) >= 5 then 'Gold'
when COUNT(order_id) >= 2 then 'Silver'
else 'Bronze' end as customer_segment
from {{ ref("int_orders_enriched") }}
where payment_status = 'success'
group by customer_id,customer_name,email,phone,customer_tier,city,country_code
