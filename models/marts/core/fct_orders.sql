{{
    config(
        materialized = 'incremental',
        unique_key = 'order_line_key',
        incremental_strategy = 'merge',
        on_schema_change = 'sync_all_columns',
        cluster_by = ['order_date'],

        post_hook = [
            "ALTER TABLE {{ this }} CLUSTER BY (order_date)",

            "{% if target.name == 'prod' %}
                GRANT SELECT ON {{ this }} TO ROLE prod_reader
             {% endif %}"
        ]
    )
}}


SELECT
{{ dbt_utils.generate_surrogate_key(
[
'o.order_id',
'o.product_id'
]
) }} AS order_line_key,
o.event_id,
o.order_id,
o.customer_id,
o.customer_name,
o.customer_tier,
o.city,
o.product_id,
o.product_name,
o.category,
o.sub_category,
o.brand,
o.margin_pct,
o.is_low_stock,
o.order_date,
o.channel,
cm.channel_label,
cm.channel_group,
o.currency_code,
o.payment_method,
o.payment_status,
o.quantity,
o.unit_price,
o.discount_pct,
o.gross_amount,
o.net_amount
{% if var('show_margin',false) %}
,o.margin_pct*(1 - coalesce(o.discount_pct,0)/100) as effective_margin_pct
{% endif %}


FROM {{ ref('int_orders_enriched') }} o
left join {{ ref('channel_mapping') }} cm on o.channel = cm.channel_code

{% if is_incremental() %}
WHERE o.order_date > (SELECT MAX(existing.order_date) FROM {{ this }} as existing)
{% endif %}