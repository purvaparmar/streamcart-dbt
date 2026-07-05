select
o.event_id,
o.event_type,
o.occurred_at,
o.customer_id,
o.customer_name,
o.email,
o.phone,
o.customer_tier,
o.city,
o.country_code,
o.order_id,
o.channel,
o.order_date,
o.currency_code,
o.order_total,
o.product_id,
o.quantity,
o.unit_price,
o.gross_amount,
o.discount_pct,
o.payment_method,
o.payment_status,
o.net_amount,
p.product_name,
p.category,
p.sub_category,
p.brand,
p.margin_pct,
p.is_low_stock,
CASE WHEN o.discount_pct > 0 THEN TRUE ELSE FALSE END AS is_discounted
from {{ ref('stg_orders') }} o
join  {{ ref('stg_products') }} p
on o.product_id = p.product_id
where o.event_type = 'order_placed'

