.PHONY: network build-trino build-spark up down logs-trino logs-spark clean help create-bucket

# Variáveis
DOCKER_COMPOSE := docker-compose
MINIO_CONTAINER := minio
SPARK_CONTAINER := spark
TRINO_CONTAINER := trino
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
	@echo "  $(GREEN)make up$(NC)        - Inicia todos os serviços"
	@echo "  $(GREEN)make down$(NC)      - Para todos os serviços"
	@echo "  $(GREEN)make logs-trino$(NC) - Mostra logs do Trino"
	@echo "  $(GREEN)make logs-spark$(NC) - Mostra logs do Spark"
	@echo "  $(GREEN)make clean$(NC)     - Remove containers e imagens"

# Cria a rede Docker
network:
	@echo "Criando rede Docker... "
	@docker network create $(NETWORK_NAME) || true

# Constrói a imagem do Trino
build-trino:
	@echo "Construindo imagem Trino... "
	docker build -t my-trino -f trino/Dockerfile .

# Constrói a imagem do Spark
build-spark:
	@echo "Construindo imagem Spark... "
	docker build -t my-spark -f spark/Dockerfile .

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
up: network build-trino build-spark
	@echo "Iniciando serviços..."
	$(DOCKER_COMPOSE) up -d
	@make create-bucket
	@echo "$(GREEN)Todos os serviços iniciados!$(NC)"
	@echo "$(YELLOW)MinIO:$(NC)     http://localhost:9000"
	@echo "$(YELLOW)Jupyter:$(NC)   http://localhost:8888"
	@echo "$(YELLOW)Spark UI:$(NC)  http://localhost:4040"
	@echo "$(YELLOW)Trino UI:$(NC)  http://localhost:8080"

# Para todos os serviços
down:
	@echo "Parando serviços..."
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Todos os serviços parados!$(NC)"

# Mostra logs do Trino
logs-trino:
	@echo "Logs do Trino..."
	docker logs $(TRINO_CONTAINER)

# Mostra logs do Spark
logs-spark:
	@echo "Logs do Spark..."
	docker logs $(SPARK_CONTAINER)

# Limpa tudo
clean: down
	@echo "$(YELLOW)Removendo imagens...$(NC)"
	-docker rmi my-trino my-spark
	@echo "$(GREEN)Limpeza concluída!$(NC)"
