SELECT
{{ dbt_utils.generate_surrogate_key(['order_id','product_id']) }} as order_line_key,
*

FROM {{ ref('fct_orders') }}