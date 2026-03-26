{% macro optimize_table() %}
  
  {% if target.type == 'postgres' %}
    ANALYZE {{ this }};
  
  {% elif target.type == 'redshift' %}
    ANALYZE {{ this }};
    VACUUM {{ this }};
  
  {% elif target.type == 'snowflake' %}
    -- Snowflake auto-optimizes, no action needed
    SELECT 1;
  
  {% elif target.type == 'bigquery' %}
    -- BigQuery auto-optimizes, no action needed  
    SELECT 1;
  
  {% else %}
    -- Unknown database type
    {{ log("Warning: Unknown database type " ~ target.type, info=True) }}
    SELECT 1;
  
  {% endif %}

{% endmacro %}
