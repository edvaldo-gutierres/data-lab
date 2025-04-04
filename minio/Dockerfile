# Usa a imagem oficial do MinIO
FROM minio/minio

# Expondo as portas necessárias:
# 9000 para a API do MinIO e 9001 para o console
EXPOSE 9000 9001

# Define o comando padrão para iniciar o servidor MinIO
# Aqui, o servidor usará o diretório /data para armazenar os dados e o console na porta 9001
CMD ["server", "minio/data", "--console-address", ":9001"]
