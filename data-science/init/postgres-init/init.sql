-- Create Airflow database
CREATE DATABASE airflow;

-- Create a user for Airflow
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

-- Create a database for ML applications if needed
CREATE DATABASE ml_data;
CREATE USER ml_user WITH PASSWORD 'ml_password';
GRANT ALL PRIVILEGES ON DATABASE ml_data TO ml_user;

-- Setup permissions
ALTER USER postgres WITH SUPERUSER;

