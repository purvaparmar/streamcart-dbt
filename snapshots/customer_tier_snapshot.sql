{% snapshot customer_tier_snapshot %}
{{
    config(
        target_schema = 'snapshots',
        unique_key = 'customer_id',
        updated_at = '_LOADED_AT',
        strategy = 'timestamp'
    )
}}

WITH CTE AS (
    SELECT
    TRIM(DATA:customer.id::STRING) AS customer_id,
    INITCAP(TRIM(DATA:customer.name::STRING)) AS customer_name,
    INITCAP(LOWER(DATA:customer.tier::STRING)) AS customer_tier,
    INITCAP(LOWER(TRIM(DATA:customer.address.city::STRING))) AS city,
    _LOADED_AT,
    ROW_NUMBER() OVER(PARTITION BY TRIM(DATA:customer.id::STRING) ORDER BY _LOADED_AT DESC) AS rn

    FROM  {{ source('raw_streamcart','RAW_ORDERS')}}
)
SELECT
customer_id,
customer_name,
customer_tier,
city,
_LOADED_AT
FROM CTE
WHERE rn = 1

{% endsnapshot %}

