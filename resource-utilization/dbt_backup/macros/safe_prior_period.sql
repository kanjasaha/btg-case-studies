{% macro safe_prior_period(metric, partition_cols, date_col, period_type) %}
    case 
        when lag({{ date_col }}) over (
            partition by {{ partition_cols | join(', ') }}
            order by {{ date_col }}
        ) = {{ date_col }} - interval '1 {{ period_type }}'
        then lag({{ metric }}) over (
            partition by {{ partition_cols | join(', ') }}
            order by {{ date_col }}
        )
        else 0
    end
{% endmacro %}
