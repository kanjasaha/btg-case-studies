{% snapshot model_availability_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='availability_key',
      strategy='check',
      check_cols=['is_region_active'],
      invalidate_hard_deletes=True
    )
}}

select
    -- Create composite unique key
    model_variant || '|' || source_region as availability_key,
    model_variant,
    source_region,
    is_region_active,
    snapshot_date,
    loaded_at
from {{ ref('stg_config_model_region_availability') }}

{% endsnapshot %}
