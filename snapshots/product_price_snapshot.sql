{% snapshot product_price_snapshot %}

{{
    config(
        target_schema = 'snapshots',
        unique_key = 'product_id',
        strategy = 'check',
        check_cols = ['list_price','is_available']
    )

}}
WITH CTE AS(
    SELECT
    TRIM(DATA:product_id::STRING) AS product_id,
    DATA:pricing.list_price::FLOAT AS list_price,
    {{ standardise_boolean("DATA:is_available::STRING") }} AS is_available,
    ROW_NUMBER() OVER (
            PARTITION BY TRIM(DATA:product_id::STRING)
            ORDER BY _LOADED_AT DESC
        ) AS rn
    FROM {{ source('raw_streamcart','RAW_PRODUCTS') }}
)
SELECT product_id,
    list_price,
    is_available FROM CTE where rn = 1


{% endsnapshot %}