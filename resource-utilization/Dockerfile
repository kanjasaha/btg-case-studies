FROM apache/airflow:2.11.2

# Install git — required by dbt for dbt deps (package installation)
# The base Airflow image does not include git by default
USER root
RUN apt-get update && apt-get install -y git --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install dbt in its own virtual environment
# Keeps dbt and Airflow dependencies separate — no version conflicts
RUN python -m venv /usr/local/airflow/dbt_venv && \
    /usr/local/airflow/dbt_venv/bin/pip install --no-cache-dir \
    dbt-core \
    dbt-postgres

# Switch back to airflow user — never run production software as root
USER airflow

# Install Airflow Python packages from requirements.txt
COPY airflow/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt