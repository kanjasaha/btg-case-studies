{% snapshot customer_details_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='account_id',
      strategy='timestamp',
      updated_at='date_updated',
      invalidate_hard_deletes=True
    )
}}

select
    account_id,
    customer_company_id,
    company_name,
    customer_segment,
    customer_vertical,
    customer_account_size,
    is_active_customer,
    date_updated
from {{ ref('stg_customer_details') }}

{% endsnapshot %}
