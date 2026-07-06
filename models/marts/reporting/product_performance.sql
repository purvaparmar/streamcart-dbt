WITH cte AS (

    SELECT
        o.product_id,

        MAX(o.product_name) AS product_name,
        MAX(o.category) AS category,
        MAX(o.sub_category) AS sub_category,
        MAX(o.brand) AS brand,
        MAX(o.margin_pct) AS margin_pct,
        MAX(o.is_low_stock) AS is_low_stock,

        SUM(COALESCE(o.quantity, 0)) AS total_units_sold,
        SUM(COALESCE(o.net_amount, 0)) AS total_net_revenue,
        AVG(o.discount_pct) AS avg_discount_pct,

        MAX(p.qty_on_hand) AS qty_on_hand,
        MAX(p.reorder_lvl) AS reorder_level,
        MAX(p.warehouse) AS warehouse_code

    FROM {{ ref('fct_orders') }} o

    LEFT JOIN {{ ref('stg_products') }} p
        ON o.product_id = p.product_id

    WHERE LOWER(o.payment_status) = 'success'

    GROUP BY o.product_id

)

SELECT

    product_id,
    product_name,
    category,
    sub_category,
    brand,
    margin_pct,
    is_low_stock,

    total_units_sold,
    total_net_revenue,
    avg_discount_pct,

    RANK() OVER (
        PARTITION BY category
        ORDER BY total_net_revenue DESC
    ) AS revenue_rank,

    qty_on_hand,
    reorder_level,
    warehouse_code

FROM cte