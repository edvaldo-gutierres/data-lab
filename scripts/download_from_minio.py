#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script para baixar arquivos do MinIO para um diretório local
"""

import os
from minio import Minio
import argparse

def download_from_minio(bucket_name, object_name, local_path):
    """
    Baixa um arquivo do MinIO para um diretório local
    
    Args:
        bucket_name (str): Nome do bucket
        object_name (str): Nome do objeto no MinIO
        local_path (str): Caminho local onde o arquivo será salvo
    """
    try:
        # Inicializa o cliente MinIO
        minio_client = Minio(
            "localhost:9000",
            access_key="minioadmin",
            secret_key="minioadmin",
            secure=False
        )
        
        # Cria o diretório local se não existir
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        
        # Baixa o arquivo
        minio_client.fget_object(
            bucket_name,
            object_name,
            local_path
        )
        
        print(f"Arquivo baixado com sucesso para: {local_path}")
        
    except Exception as e:
        print(f"Erro ao baixar arquivo: {str(e)}")

def list_objects(bucket_name, prefix=""):
    """
    Lista todos os objetos em um bucket
    
    Args:
        bucket_name (str): Nome do bucket
        prefix (str): Prefixo para filtrar objetos
    """
    try:
        # Inicializa o cliente MinIO
        minio_client = Minio(
            "localhost:9000",
            access_key="minioadmin",
            secret_key="minioadmin",
            secure=False
        )
        
        # Lista os objetos
        objects = minio_client.list_objects(bucket_name, prefix=prefix, recursive=True)
        
        print(f"\nObjetos no bucket '{bucket_name}':")
        for obj in objects:
            print(f"- {obj.object_name}")
            
    except Exception as e:
        print(f"Erro ao listar objetos: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description='Download files from MinIO')
    parser.add_argument('--bucket', required=True, help='Nome do bucket')
    parser.add_argument('--object', help='Nome do objeto (opcional)')
    parser.add_argument('--local-path', help='Caminho local para salvar (opcional)')
    parser.add_argument('--list', action='store_true', help='Listar objetos do bucket')
    
    args = parser.parse_args()
    
    if args.list:
        list_objects(args.bucket)
        return
        
    if not args.object or not args.local_path:
        print("Para download, --object e --local-path são obrigatórios")
        return
        
    download_from_minio(args.bucket, args.object, args.local_path)

if __name__ == "__main__":
    main() 