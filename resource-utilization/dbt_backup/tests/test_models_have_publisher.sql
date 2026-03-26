-- Test: All model variants should have a publisher
-- If this returns rows, some models are missing publisher info

select
    model_variant,
    model_family,
    'Missing publisher' as issue
from {{ ref('stg_config_model_dimensions') }}
where model_publisher is null
   or trim(model_publisher) = ''
