# Prior Period Macros

## Overview
These macros help you calculate period-over-period changes (day-over-day, week-over-week, month-over-month) with gap detection.

## Macros

### 1. `safe_prior_period`
Returns the prior period value for a metric, checking for date gaps. Returns 0 if there's a gap.

**Parameters:**
- `metric`: Column to get prior value for (e.g., `r.total_gross_revenue`)
- `partition_cols`: List of columns to partition by (e.g., `['r.account_id', 'r.model_variant']`)
- `date_col`: Date column to order by (e.g., `r.revenue_date`)
- `period_type`: Type of period - `'day'`, `'week'`, or `'month'`

**Example:**
```sql
{{ safe_prior_period(
    'r.total_gross_revenue',
    ['r.account_id', 'r.model_variant', 'r.source_region'],
    'r.revenue_date',
    'day'
) }} as prior_day_gross_revenue
```

### 2. `add_prior_period_metrics`
Generates multiple prior period columns and their changes at once.

**Parameters:**
- `metrics`: List of metrics to calculate (e.g., `['r.total_gross_revenue', 'r.net_revenue']`)
- `partition_cols`: List of columns to partition by
- `date_col`: Date column to order by
- `period_type`: Type of period - `'day'`, `'week'`, or `'month'` (default: `'day'`)

**Example:**
```sql
{{ add_prior_period_metrics(
    metrics=['r.total_gross_revenue', 'r.net_revenue'],
    partition_cols=['r.account_id', 'r.model_variant', 'r.source_region'],
    date_col='r.revenue_date',
    period_type='day'
) }}
```

**Generates:**
```sql
prior_day_total_gross_revenue,
dod_total_gross_revenue_change,
prior_day_net_revenue,
dod_net_revenue_change
```

## Usage in Models

### int_revenue_daily.sql
```sql
with enriched as (
    select
        r.account_id,
        r.model_variant,
        r.source_region,
        r.revenue_date,
        r.total_gross_revenue,
        r.net_revenue,
        
        -- Add day-over-day comparisons
        {{ add_prior_period_metrics(
            metrics=['r.total_gross_revenue', 'r.net_revenue'],
            partition_cols=['r.account_id', 'r.model_variant', 'r.source_region'],
            date_col='r.revenue_date',
            period_type='day'
        ) }}
        
    from revenue r
    ...
)
```

### customer_revenue_monthly.sql
```sql
with_prior_month as (
    select
        m.*,
        
        -- Add month-over-month comparisons
        {{ add_prior_period_metrics(
            metrics=['m.total_gross_revenue', 'm.total_net_revenue'],
            partition_cols=['m.account_id'],
            date_col='m.month_start_date',
            period_type='month'
        ) }}
        
    from monthly m
)
```

## Gap Handling

If a customer/model has no activity in a period, the macro:
- Returns `0` for `prior_*` columns
- Calculates change as: `current_value - 0 = current_value`

This means:
- ✅ No NULL values to handle
- ✅ Always get a numeric result
- ⚠️ Assumes missing = zero (not missing data issue)

## Column Naming Convention

The macro generates standardized column names:
- **Prior value:** `prior_{period}_{metric_name}`
  - Examples: `prior_day_total_gross_revenue`, `prior_month_net_revenue`
- **Change:** `{period_abbr}od_{metric_name}_change`
  - Examples: `dod_total_gross_revenue_change`, `mom_net_revenue_change`
  - Abbreviations: `dod` (day), `weeod` (week), `monod` (month)
