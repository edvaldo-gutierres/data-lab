#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Exemplo de Conexão Spark com MinIO
Este script demonstra como conectar o Spark com o MinIO para ler e escrever dados.
"""

from pyspark.sql import SparkSession
from pyspark.sql.types import *
import logging
import sys

# Configuração de logs
logging.getLogger('py4j').setLevel(logging.ERROR)
logging.getLogger('pyspark').setLevel(logging.WARN)

def main():
    try:
        # Configuração do Spark com MinIO
        spark = SparkSession.builder \
            .appName("MinIO Example") \
            .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
            .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
            .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
            .config("spark.hadoop.fs.s3a.path.style.access", "true") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
            .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider") \
            .getOrCreate()

        # Configuração adicional para reduzir logs
        spark.sparkContext.setLogLevel("WARN")

        print("Criando DataFrame de exemplo...")
        # Criando um DataFrame de exemplo
        data = [("João", 25), ("Maria", 30), ("Pedro", 35)]
        schema = StructType([
            StructField("nome", StringType(), True),
            StructField("idade", IntegerType(), True)
        ])

        df = spark.createDataFrame(data, schema)
        print("DataFrame criado:")
        df.show()

        print("\nEscrevendo dados no MinIO...")
        # Escrevendo no MinIO em formato Parquet
        df.write \
            .format("parquet") \
            .mode("overwrite") \
            .save("s3a://datalake/exemplo_pessoas")

        print("\nLendo dados do MinIO...")
        # Lendo do MinIO
        df_read = spark.read \
            .format("parquet") \
            .load("s3a://datalake/exemplo_pessoas")

        print("Dados lidos do MinIO:")
        df_read.show()

        print("\nSchema do DataFrame:")
        df_read.printSchema()

    except Exception as e:
        print(f"Erro durante a execução: {str(e)}", file=sys.stderr)
        raise
    finally:
        # Encerrando a sessão Spark
        spark.stop()

if __name__ == "__main__":
    main()