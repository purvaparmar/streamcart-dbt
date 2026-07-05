WITH source_data AS (
select
*
from {{ source('raw_streamcart', 'RAW_PRODUCTS') }}
),
product_data as (


select 
TRIM(DATA:product_id::STRING) AS product_id,
TRIM(DATA:name::STRING) AS product_name,
INITCAP(LOWER(DATA:brand::STRING)) AS brand,
INITCAP(LOWER(DATA:category::STRING)) AS category,
LOWER(TRIM(DATA:sub_category::STRING)) AS sub_category,

{{ standardise_boolean("DATA:is_available::STRING") }} AS is_available,

DATA:pricing.cost_price::FLOAT AS cost_price,
DATA:pricing.list_price::FLOAT AS list_price,
DATA:pricing.currency::STRING AS currency,

DATA:specs.warranty_yr::INTEGER AS warranty_yr,
DATA:specs.weight_kg::FLOAT AS weight_kg,
DATA:stock.qty_on_hand::INTEGER AS qty_on_hand,
DATA:stock.reorder_lvl::INTEGER AS reorder_lvl,
UPPER(TRIM(DATA:stock.warehouse::STRING)) AS warehouse,

ARRAY_TO_STRING(DATA:tags, ', ') AS tags,

ROUND((DATA:pricing.list_price::FLOAT - DATA:pricing.cost_price::FLOAT) / NULLIF(DATA:pricing.list_price::FLOAT,0) * 100, 2) AS margin_pct,

CASE WHEN DATA:stock.qty_on_hand::INTEGER <= DATA:stock.reorder_lvl::INTEGER THEN TRUE ELSE FALSE END AS is_low_stock,
_LOADED_AT,
ROW_NUMBER() OVER(
            PARTITION BY TRIM(DATA:product_id::STRING)
            ORDER BY _LOADED_AT DESC
        ) AS rn

FROM source_data



)
SELECT *
FROM product_data
WHERE rn = 1