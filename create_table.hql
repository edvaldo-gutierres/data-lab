CREATE TABLE IF NOT EXISTS pessoas (
    nome STRING,
    idade INT
)
STORED AS PARQUET
LOCATION 's3a://raw/exemplo_pessoas'; 