# Guia de Instalação

Este guia irá ajudá-lo a configurar o ambiente do Data Lake em sua máquina local.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/) (versão 20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versão 2.0 ou superior)
- [Make](https://www.gnu.org/software/make/) (opcional, mas recomendado)

## Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/data-lab.git
cd data-lab
```

2. Inicie os serviços:
```bash
make up
```

Este comando irá:
- Criar a rede Docker necessária
- Construir as imagens Docker
- Iniciar todos os serviços
- Criar o bucket `raw` no MinIO

## Verificação

Após a instalação, verifique se todos os serviços estão rodando:

```bash
docker ps
```

Você deverá ver os seguintes containers:
- `data-lab-minio-1`
- `data-lab-spark-1`
- `data-lab-trino-1`
- `data-lab-hive-metastore-1`
- `data-lab-mariadb-1`

## Acessando os Serviços

### MinIO
- Console: [http://localhost:9001](http://localhost:9001)
- API: [http://localhost:9000](http://localhost:9000)
- Credenciais: minioadmin/minioadmin

### Jupyter Notebook
- Interface: [http://localhost:8888](http://localhost:8888)
- Sem senha

### Spark UI
- Interface: [http://localhost:4040](http://localhost:4040)

### Trino
- Interface: [http://localhost:8080](http://localhost:8080)
- Sem senha

## Estrutura de Diretórios

```
.
├── data/              # Dados do MinIO
├── hive/              # Configurações do Hive
├── notebooks/         # Jupyter notebooks
├── spark/            # Configurações do Spark
└── trino/            # Configurações do Trino
```

## Próximos Passos

- [Configure seu ambiente](configuration.md)
- Explore o [tutorial de ingestão de dados](../tutorials/data-ingestion.md)
- Aprenda sobre [consultas SQL](../tutorials/sql-queries.md)

## Troubleshooting

### Portas em Uso

Se alguma porta estiver em uso, você verá um erro como:
```
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:9000
```

Solução:
1. Identifique o processo usando a porta:
```bash
sudo lsof -i :9000
```

2. Pare o processo ou altere a porta no `docker-compose.yml`

### Problemas de Memória

Se o Docker não iniciar por falta de memória:

1. Ajuste os recursos do Docker:
   - Windows/Mac: Docker Desktop > Settings > Resources
   - Linux: Edite `/etc/docker/daemon.json`

2. Recomendações mínimas:
   - RAM: 8GB
   - CPU: 4 cores
   - Disco: 20GB

### Logs dos Serviços

Para verificar logs:

```bash
# MinIO
make logs-minio

# Spark
make logs-spark

# Trino
make logs-trino

# Hive Metastore
make logs-hive
```

## Desinstalação

Para remover completamente:

```bash
# Para os serviços
make down

# Remove volumes e imagens
make clean
```
