SELECT

c.customer_id,
c.customer_name,
c.email,
c.phone,
c.customer_tier,
c.city,
c.country_code,

c.total_orders,
c.total_gross_revenue,
c.total_net_revenue,

{{ dbt_utils.safe_divide(
    "c.total_net_revenue",
    "c.total_orders"
) }} AS avg_order_value,

c.customer_segment,
c.days_since_last_order,

cc.country_name,
cc.region,
cc.currency_default

FROM {{ ref('int_customer_summary') }} c
LEFT JOIN {{ ref('country_config') }} cc
    ON c.country_code = cc.country_code