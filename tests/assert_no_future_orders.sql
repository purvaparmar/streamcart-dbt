select
* from 
{{ ref('stg_orders') }}
where order_date > GETDATE()