#!/bin/bash

# Aguarda o MinIO iniciar
until curl -s http://localhost:9000/minio/health/live; do
    echo "Aguardando MinIO iniciar..."
    sleep 1
done

# Configura o cliente mc (MinIO Client)
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Verifica se o bucket 'raw' existe
if ! mc ls myminio/raw >/dev/null 2>&1; then
    echo "Criando bucket 'raw'..."
    mc mb myminio/raw
    echo "Bucket 'raw' criado com sucesso!"
else
    echo "Bucket 'raw' já existe."
fi

# Mantém o container rodando
tail -f /dev/null 