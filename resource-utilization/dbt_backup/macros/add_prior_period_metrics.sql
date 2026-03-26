{% macro add_prior_period_metrics(metrics, partition_cols, date_col, period_type='day') %}
    {% for metric in metrics %}
    -- Prior {{ period_type }} value
    {{ safe_prior_period(
        metric,
        partition_cols,
        date_col,
        period_type
    ) }} as prior_{{ period_type }}_{{ metric.split('.')[-1] }},
    
    -- {{ period_type | upper }} over {{ period_type | upper }} change
    {{ metric }} - {{ safe_prior_period(
        metric,
        partition_cols,
        date_col,
        period_type
    ) }} as {{ period_type[0:3] }}od_{{ metric.split('.')[-1] }}_change{{ "," if not loop.last else "" }}
    {% endfor %}
{% endmacro %}
