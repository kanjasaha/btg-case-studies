{% test assert_column_within_range(model, column_name, min_value=0, max_value=100) %}

    /*
        Custom generic test: assert_column_within_range
        
        Checks that a numeric column's values fall within an expected min/max range.
        Returns rows that VIOLATE the range — dbt fails if any rows are returned.
        
        Usage in schema.yml:
        
            - name: error_rate_pct
              tests:
                - assert_column_within_range:
                    min_value: 0
                    max_value: 100
        
            - name: active_minute_pct
              tests:
                - assert_column_within_range:
                    min_value: 0
                    max_value: 100
        
        Exam notes:
        - Custom generic tests must accept model and column_name as first two args
        - dbt auto-supplies model (relation object) and column_name (string)
        - Additional args like min_value and max_value have defaults
        - Test passes when 0 rows are returned, fails when >0 rows returned
        - Lives in macros/ folder, applied in schema.yml like any generic test
    */

    select
        {{ column_name }},
        '{{ column_name }} = ' || {{ column_name }}::text || 
        ' is outside range [{{ min_value }}, {{ max_value }}]'  as failure_reason
    from {{ model }}
    where
        {{ column_name }} is not null
        and (
            {{ column_name }} < {{ min_value }}
            or {{ column_name }} > {{ max_value }}
        )

{% endtest %}
