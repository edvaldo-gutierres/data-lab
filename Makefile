.PHONY: network build-dremio build-spark up down logs-dremio logs-spark logs-airflow logs-openmetadata clean help create-bucket create-dirs airbyte-install airbyte-start airbyte-stop airbyte-status airbyte-logs airbyte-credentials logs-metabase metabase-reset

# Variáveis
DOCKER_COMPOSE := docker-compose
MINIO_CONTAINER := minio
SPARK_CONTAINER := spark
DREMIO_CONTAINER := dremio
AIRFLOW_CONTAINER := airflow-webserver
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
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@echo "  $(GREEN)make network$(NC)           - Cria a rede Docker"
	@echo "  $(GREEN)make build-dremio$(NC)      - Constrói a imagem do Dremio"
	@echo "  $(GREEN)make build-spark$(NC)       - Constrói a imagem do Spark"
	@echo "  $(GREEN)make up$(NC)                - Inicia todos os serviços"
	@echo "  $(GREEN)make down$(NC)              - Para todos os serviços"
	@echo "  $(GREEN)make logs-dremio$(NC)       - Mostra logs do Dremio"
	@echo "  $(GREEN)make logs-spark$(NC)        - Mostra logs do Spark"
	@echo "  $(GREEN)make logs-airflow$(NC)      - Mostra logs do Airflow"
	@echo "  $(GREEN)make logs-openmetadata$(NC) - Mostra logs do OpenMetadata"
	@echo "  $(GREEN)make clean$(NC)             - Limpa tudo (remove imagens e volumes)"
	@echo "  $(GREEN)make create-bucket$(NC)     - Cria bucket no MinIO"
	@echo "  $(GREEN)make create-dirs$(NC)       - Cria diretórios necessários"
	@echo "  $(GREEN)make airbyte-install$(NC)   - Instala o Airbyte usando abctl"
	@echo "  $(GREEN)make airbyte-start$(NC)     - Inicia o Airbyte usando abctl"
	@echo "  $(GREEN)make airbyte-stop$(NC)      - Para o Airbyte usando abctl"
	@echo "  $(GREEN)make airbyte-status$(NC)    - Verifica o status do Airbyte usando abctl"
	@echo "  $(GREEN)make airbyte-credentials$(NC) - Mostra credenciais do Airbyte"
	@echo "  $(GREEN)make airbyte-logs$(NC)      - Mostra logs do Airbyte usando abctl"
	@echo "  $(GREEN)make logs-metabase$(NC)      - Mostra logs do Metabase"
	@echo "  $(GREEN)make metabase-reset$(NC)     - Reinicia o Metabase"

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
	@echo "$(YELLOW)Iniciando os containers...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@make create-bucket
	@echo "$(GREEN)Verificando Airbyte via abctl...$(NC)"
	@if ! command -v abctl &> /dev/null; then \
		echo "$(RED)abctl não está instalado. Instalando...$(NC)"; \
		curl -LsfS https://get.airbyte.com | bash -; \
	fi
	@if abctl local status 2>/dev/null | grep -q "not.*installed"; then \
		echo "$(YELLOW)Instalando Airbyte via abctl...$(NC)"; \
		abctl local install --low-resource-mode; \
	elif abctl local status 2>/dev/null | grep -q "not.*running"; then \
		echo "$(YELLOW)Reinstalando Airbyte...$(NC)"; \
		abctl local install --low-resource-mode; \
	else \
		echo "$(GREEN)Airbyte já está em execução via abctl!$(NC)"; \
	fi
	@echo "$(GREEN)Airbyte disponível em: http://localhost:8000$(NC)"
	@echo "$(GREEN)Para obter as credenciais, execute: make airbyte-credentials$(NC)"
	@echo "$(GREEN)Containers iniciados com sucesso!$(NC)"
	@echo "$(YELLOW)MinIO:$(NC)          http://localhost:9000 (API)"
	@echo "$(YELLOW)MinIO Console:$(NC)  http://localhost:9001"
	@echo "$(YELLOW)Jupyter:$(NC)        http://localhost:8888"
	@echo "$(YELLOW)Spark UI:$(NC)       http://localhost:4040"
	@echo "$(YELLOW)Dremio:$(NC)         http://localhost:9047"
	@echo "$(YELLOW)Airflow:$(NC)        http://localhost:8080"
	@echo "$(YELLOW)OpenMetadata:$(NC)   http://localhost:8585"
	@echo "$(YELLOW)Airbyte:$(NC)        http://localhost:8000"

# Para todos os serviços
down:
	@echo "Parando serviços..."
	$(DOCKER_COMPOSE) down
	@echo "$(YELLOW)Parando Airbyte via abctl...$(NC)"
	@if command -v abctl &> /dev/null; then \
		if abctl local status 2>/dev/null | grep -q "running"; then \
			abctl local uninstall; \
			echo "$(GREEN)Airbyte parado com sucesso!$(NC)"; \
		else \
			echo "$(YELLOW)Airbyte já está parado.$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)abctl não encontrado. Ignorando Airbyte.$(NC)"; \
	fi
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

# Mostra logs do OpenMetadata
logs-openmetadata:
	@echo "Logs do OpenMetadata..."
	docker logs $(OPENMETADATA_CONTAINER)

# Mostra logs do Metabase
logs-metabase:
	@echo "Logs do Metabase..."
	docker logs -f data-lab-metabase-1

# Comandos do Airbyte via abctl
airbyte-install:
	@echo "$(YELLOW)Instalando Airbyte via abctl...$(NC)"
	@if ! command -v abctl &> /dev/null; then \
		echo "$(RED)abctl não está instalado. Instalando...$(NC)"; \
		curl -LsfS https://get.airbyte.com | bash -; \
	fi
	@abctl local install --low-resource-mode

airbyte-start:
	@echo "$(YELLOW)Iniciando Airbyte via abctl...$(NC)"
	@if ! command -v abctl &> /dev/null; then \
		echo "$(RED)abctl não está instalado. Instalando...$(NC)"; \
		curl -LsfS https://get.airbyte.com | bash -; \
	fi
	@if abctl local status 2>/dev/null | grep -q "not.*installed"; then \
		echo "$(YELLOW)Instalando Airbyte...$(NC)"; \
		abctl local install --low-resource-mode; \
	elif abctl local status 2>/dev/null | grep -q "not.*running"; then \
		echo "$(YELLOW)Reinstalando Airbyte...$(NC)"; \
		abctl local install --low-resource-mode; \
	else \
		echo "$(GREEN)Airbyte já está em execução!$(NC)"; \
	fi

airbyte-stop:
	@echo "$(YELLOW)Parando Airbyte via abctl...$(NC)"
	@abctl local uninstall

airbyte-status:
	@echo "$(YELLOW)Status do Airbyte via abctl:$(NC)"
	@abctl local status

airbyte-credentials:
	@echo "$(YELLOW)Credenciais do Airbyte via abctl:$(NC)"
	@abctl local credentials

airbyte-logs:
	@echo "$(YELLOW)Mostrando logs do Airbyte via abctl...$(NC)"
	abctl local logs

# Reinicia o Metabase
metabase-reset:
	@echo "Removendo banco de dados do Metabase..."
	$(DOCKER_COMPOSE) down metabase metabase-db
	docker volume rm data-lab_metabase-db-data || true
	@echo "Reiniciando Metabase..."
	$(DOCKER_COMPOSE) up -d metabase-db metabase
	@echo "Metabase reiniciado com sucesso!"

# Limpa tudo
clean: down
	@echo "$(YELLOW)Removendo imagens...$(NC)"
	-docker rmi my-spark
	@echo "$(YELLOW)Removendo volumes...$(NC)"
	-docker volume rm data-lab_airflow-postgres-db-volume data-lab_openmetadata-mysql-data
	@echo "$(YELLOW)Verificando Airbyte...$(NC)"
	@if command -v abctl &> /dev/null; then \
		if abctl local status 2>/dev/null | grep -q "installed"; then \
			echo "$(YELLOW)Removendo Airbyte via abctl...$(NC)"; \
			abctl local uninstall; \
		fi; \
	fi
	@echo "$(GREEN)Limpeza concluída!$(NC)"
