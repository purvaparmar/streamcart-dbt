SELECT

category,

{{ dbt_utils.pivot(
    'channel',
    ['mobile_app', 'web', 'partner_api'],
    agg='sum',
    then_value='net_amount'
) }}

FROM {{ ref('fct_orders') }}

WHERE payment_status = 'success'

GROUP BY category

ORDER BY category