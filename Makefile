.PHONY: network build-dremio build-spark up down logs-dremio logs-spark logs-airflow logs-airbyte logs-openmetadata clean help create-bucket create-dirs

# Variáveis
DOCKER_COMPOSE := docker-compose
MINIO_CONTAINER := minio
SPARK_CONTAINER := spark
DREMIO_CONTAINER := dremio
AIRFLOW_CONTAINER := airflow-webserver
AIRBYTE_CONTAINER := airbyte-webapp
OPENMETADATA_CONTAINER := openmetadata
NETWORK_NAME := datalake-network
MINIO_ENDPOINT := http://localhost:9000
MINIO_ACCESS_KEY := minioadmin
MINIO_SECRET_KEY := minioadmin

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Comandos principais
help:
	@echo "$(YELLOW)Comandos disponíveis:$(NC)"
	@echo "  $(GREEN)make up$(NC)               - Inicia todos os serviços"
	@echo "  $(GREEN)make down$(NC)             - Para todos os serviços"
	@echo "  $(GREEN)make logs-dremio$(NC)      - Mostra logs do Dremio"
	@echo "  $(GREEN)make logs-spark$(NC)       - Mostra logs do Spark"
	@echo "  $(GREEN)make logs-airflow$(NC)     - Mostra logs do Airflow"
	@echo "  $(GREEN)make logs-airbyte$(NC)     - Mostra logs do Airbyte"
	@echo "  $(GREEN)make logs-openmetadata$(NC) - Mostra logs do OpenMetadata"
	@echo "  $(GREEN)make clean$(NC)            - Remove containers e imagens"

# Cria a rede Docker
network:
	@echo "Criando rede Docker... "
	@docker network create $(NETWORK_NAME) || true

# Constrói a imagem do Dremio (se necessário)
build-dremio:
	@echo "Verificando imagem Dremio... "
	@# Não precisa construir imagem para o Dremio, já usa a oficial

# Constrói a imagem do Spark
build-spark:
	@echo "Construindo imagem Spark... "
	docker build -t my-spark -f spark/Dockerfile .

# Cria diretórios necessários
create-dirs:
	@echo "$(YELLOW)Criando diretórios para os serviços...$(NC)"
	mkdir -p airflow/dags airflow/logs airflow/plugins airflow/config
	mkdir -p airbyte/workspace airbyte/config
	@echo "$(GREEN)Diretórios criados com sucesso!$(NC)"

# Cria o bucket raw no MinIO
create-bucket:
	@echo "$(YELLOW)Criando bucket 'raw' no MinIO...$(NC)"
	@until docker exec $(MINIO_CONTAINER) mc alias set myminio $(MINIO_ENDPOINT) $(MINIO_ACCESS_KEY) $(MINIO_SECRET_KEY) 2>/dev/null; do \
		echo "Aguardando MinIO iniciar..."; \
		sleep 2; \
	done
	@docker exec $(MINIO_CONTAINER) mc mb myminio/raw || true
	@echo "$(GREEN)Bucket 'raw' criado com sucesso!$(NC)"

# Inicia todos os serviços
up: network build-dremio build-spark create-dirs
	@echo "Iniciando serviços..."
	$(DOCKER_COMPOSE) up -d
	@make create-bucket
	@echo "$(GREEN)Todos os serviços iniciados!$(NC)"
	@echo "$(YELLOW)MinIO:$(NC)          http://localhost:9000 (API)"
	@echo "$(YELLOW)MinIO Console:$(NC)  http://localhost:9001"
	@echo "$(YELLOW)Jupyter:$(NC)        http://localhost:8888"
	@echo "$(YELLOW)Spark UI:$(NC)       http://localhost:4040"
	@echo "$(YELLOW)Dremio:$(NC)         http://localhost:9047"
	@echo "$(YELLOW)Airflow:$(NC)        http://localhost:8080"
	@echo "$(YELLOW)Airbyte:$(NC)        http://localhost:8000"
	@echo "$(YELLOW)OpenMetadata:$(NC)   http://localhost:8585"

# Para todos os serviços
down:
	@echo "Parando serviços..."
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Todos os serviços parados!$(NC)"

# Mostra logs do Dremio
logs-dremio:
	@echo "Logs do Dremio..."
	docker logs $(DREMIO_CONTAINER)

# Mostra logs do Spark
logs-spark:
	@echo "Logs do Spark..."
	docker logs $(SPARK_CONTAINER)

# Mostra logs do Airflow
logs-airflow:
	@echo "Logs do Airflow..."
	docker logs $(AIRFLOW_CONTAINER)

# Mostra logs do Airbyte
logs-airbyte:
	@echo "Logs do Airbyte..."
	docker logs $(AIRBYTE_CONTAINER)

# Mostra logs do OpenMetadata
logs-openmetadata:
	@echo "Logs do OpenMetadata..."
	docker logs $(OPENMETADATA_CONTAINER)

# Limpa tudo
clean: down
	@echo "$(YELLOW)Removendo imagens...$(NC)"
	-docker rmi my-spark
	@echo "$(YELLOW)Removendo volumes...$(NC)"
	-docker volume rm data-lab_airflow-postgres-db-volume data-lab_airbyte-db-volume data-lab_openmetadata-mysql-data
	@echo "$(GREEN)Limpeza concluída!$(NC)"
