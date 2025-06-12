FROM docker-remote.jfrog.booking.com/python:3.11-slim

# Add system packages that might be useful for dbt and general development
RUN apt-get update \
    && apt-get install -y \
        git \
        bash-completion \
        build-essential \
        curl \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project
COPY . .

# Create non-root user for better security
RUN useradd -m -s /bin/bash dbtuser

# Set the dbt profiles directory to our dbt_project subfolder
ENV DBT_PROFILES_DIR=/app/dbt_project

# Fix permissions for the non-root user
RUN chown -R dbtuser:dbtuser /app
RUN chmod -R 755 /app

# Switch to non-root user
USER dbtuser

# Set the working directory to dbt_project for dbt commands
WORKDIR /app/dbt_project