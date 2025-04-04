FROM minio/minio:latest

# Instala o MinIO Client (mc) e curl
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc && \
    apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Copia o script de inicialização
COPY minio-init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/minio-init.sh

# Define o script de inicialização como entrypoint
ENTRYPOINT ["/usr/local/bin/minio-init.sh"] 