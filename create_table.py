from pyspark.sql import SparkSession

# Criar sessão Spark com configurações do MinIO
spark = SparkSession.builder \
    .appName("CreateTable") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
    .getOrCreate()

# Criar a tabela
spark.sql("""
    CREATE TABLE IF NOT EXISTS pessoas (
        nome STRING,
        idade INT
    )
    USING PARQUET
    LOCATION 's3a://raw/exemplo_pessoas'
""")

# Inserir alguns dados de exemplo
spark.sql("""
    INSERT INTO pessoas VALUES
    ('João', 25),
    ('Maria', 30),
    ('Pedro', 35)
""")

# Verificar os dados
spark.sql("SELECT * FROM pessoas").show()

# Parar a sessão Spark
spark.stop() 