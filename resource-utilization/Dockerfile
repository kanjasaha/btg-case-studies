FROM apache/airflow:2.11.2

# Install dbt in its own virtual environment
# Keeps dbt and Airflow dependencies separate — no version conflicts
USER root
RUN python -m venv /usr/local/airflow/dbt_venv && \
    /usr/local/airflow/dbt_venv/bin/pip install --no-cache-dir \
    dbt-core \
    dbt-postgres

# Switch back to airflow user — never run production software as root
USER airflow

# Install Airflow Python packages from requirements.txt
COPY airflow/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt