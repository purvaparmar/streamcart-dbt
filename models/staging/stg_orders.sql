{{
    config(
        materialized = 'incremental',
        unique_key = 'event_id',
        incremental_strategy = 'merge'
    )

}}



WITH cte AS(
    SELECT 
    *
    FROM {{ source('raw_streamcart','RAW_ORDERS')}}
),cte2 AS(
SELECT 
DATA,
_LOADED_AT,
_SOURCE,
order_items.value as item
FROM cte,
    LATERAL FLATTEN(input => DATA:order.items) as order_items
), cte3 as (

select

TRIM(DATA:event_id::STRING) AS event_id,
LOWER(TRIM(DATA:event_type::STRING)) AS event_type,
TRY_TO_TIMESTAMP(
    DATA:occurred_at::STRING,
    'DD/MM/YYYY HH24:MI:SS'
) AS occurred_at, 

{% if target.name == 'prod' %}

TRIM(DATA:customer.id::STRING) AS customer_id,
INITCAP(TRIM(DATA:customer.name::STRING)) AS customer_name,
LOWER(TRIM(DATA:customer.email::STRING)) AS email,

{% else %}

TRIM(DATA:customer.id::STRING) AS customer_id,
'Customer_' || TRIM(DATA:customer.id::STRING) AS customer_name,
MD5(LOWER(TRIM(DATA:customer.email::STRING))) AS email,

{% endif %}

RIGHT(REGEXP_REPLACE(DATA:customer.phone::STRING, '[^0-9]', ''),10) AS phone,



COALESCE(INITCAP(LOWER(DATA:customer.tier::STRING)), 'Standard') AS customer_tier,

INITCAP(LOWER(TRIM(DATA:customer.address.city::STRING))) AS city,
INITCAP(LOWER(TRIM(DATA:customer.address.state::STRING))) AS state,
UPPER(TRIM(DATA:customer.address.country::STRING)) AS country_code,
TRIM(DATA:order.order_id::STRING) AS order_id,
LOWER(REPLACE(DATA:order.channel::STRING,' ','_')) AS channel,
{{ parse_date_flexible_sc("DATA:order.placed_at::STRING", "'DD/MM/YYYY'","'YYYY-MM-DD'") }} AS order_date,
upper(trim(DATA:order.currency::STRING)) AS currency_code,
{{ clean_amount("DATA:order.total_amount::STRING") }}
AS order_total,item:product_id::STRING AS product_id,
NULLIF(item:qty::INTEGER,0) AS quantity,
{{ clean_amount("item:unit_price::STRING") }} AS unit_price,
CASE WHEN item:discount_pct::FLOAT > 60 THEN NULL ELSE item:discount_pct::FLOAT END AS discount_pct,
LOWER(REPLACE(DATA:payment.method::STRING,' ','_')) AS payment_method,
LOWER(DATA:payment.status::STRING) AS payment_status,
DATA:metadata.is_test_event::STRING AS is_test_event,
_LOADED_AT,
ROW_NUMBER() OVER(PARTITION BY DATA:event_id::STRING ORDER BY _LOADED_AT DESC) AS rn FROM cte2
)

SELECT

event_id,
event_type,
occurred_at,
customer_id,
customer_name,
email,
phone,
customer_tier,
city,
country_code,
order_id,
channel,
order_date,
currency_code,
order_total,
product_id,
quantity,
unit_price,
quantity * unit_price AS gross_amount,
discount_pct,
payment_method,
payment_status,

{{ safe_net_amount("gross_amount","discount_pct")}} as net_amount,
_LOADED_AT

FROM cte3

WHERE rn = 1

AND LOWER(is_test_event) <> 'true'

{% if var('lookback_days', none) is not none %}
AND _LOADED_AT >= DATEADD(
    day,
    -{{ var('lookback_days') }},
    CURRENT_TIMESTAMP()
)
{% endif %}

{% if is_incremental() %}
AND _LOADED_AT > (SELECT MAX(existing._LOADED_AT) FROM {{ this }} AS existing)
{% endif %}