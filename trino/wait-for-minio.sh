#!/bin/bash

MAX_ATTEMPTS=30
ATTEMPT=1
TIMEOUT=2

echo "Aguardando MinIO iniciar...."

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if curl -s http://minio:9000/minio/health/live > /dev/null; then
        echo "MinIO está pronto!"
        exit 0
    fi
    echo "Tentativa $ATTEMPT de $MAX_ATTEMPTS..."
    sleep $TIMEOUT
    ATTEMPT=$((ATTEMPT + 1))
done

echo "Timeout aguardando MinIO. Continuando mesmo assim..."
exit 0 