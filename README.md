# Data Lake com MinIO, Spark e Trino

Este projeto implementa um data lake utilizando MinIO como armazenamento de objetos, Apache Spark para processamento de dados e Trino para consultas SQL. O ambiente é containerizado usando Docker e inclui um Hive Metastore para gerenciamento de metadados.

## Arquitetura

O projeto consiste nos seguintes componentes:

- **MinIO**: Servidor de armazenamento de objetos compatível com S3
- **Apache Spark**: Framework para processamento distribuído de dados
- **Trino**: Motor de consulta SQL distribuído
- **Hive Metastore**: Gerenciamento de metadados para tabelas
- **MariaDB**: Banco de dados para o Hive Metastore

## Estrutura do Projeto

```
.
├── data/                  # Dados do MinIO
├── hive/                  # Configurações do Hive Metastore
│   ├── Dockerfile        # Imagem do Hive Metastore
│   ├── entrypoint.sh     # Script de inicialização
│   ├── hive-site.xml     # Configurações do Hive
│   ├── logs/             # Logs do Hive
│   └── warehouse/        # Diretório de warehouse do Hive
├── notebooks/            # Jupyter notebooks
├── scripts/              # Scripts Python
│   ├── download_from_minio.py  # Script para download de arquivos
│   └── requirements.txt        # Dependências Python
├── spark/                # Configurações do Spark
│   └── Dockerfile       # Imagem do Spark
├── trino/                # Configurações do Trino
│   ├── Dockerfile       # Imagem do Trino
│   └── etc/             # Configurações do Trino
│       ├── catalog/     # Configurações dos catalogs
│       │   ├── hive.properties    # Configuração do catalog Hive
│       │   └── minio.properties   # Configuração do catalog MinIO
│       ├── config.properties      # Configurações gerais
│       └── jvm.config             # Configurações da JVM
├── docker-compose.yml    # Configuração dos serviços
├── Makefile             # Comandos de automação
└── README.md            # Documentação do projeto
```

## Requisitos

- Docker
- Docker Compose
- Make

## Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd data-lab
```

2. Inicie os serviços:
```bash
make up
```

## Serviços Disponíveis

- **MinIO Console**: http://localhost:9001
  - Usuário: minioadmin
  - Senha: minioadmin

- **Jupyter Notebook**: http://localhost:8888
  - Acesso direto sem senha

- **Spark UI**: http://localhost:4040
  - Interface web do Spark

- **Trino UI**: http://localhost:8080
  - Interface web do Trino

## Comandos Disponíveis

- `make up`: Inicia todos os serviços
- `make down`: Para todos os serviços
- `make logs-trino`: Mostra logs do Trino
- `make logs-spark`: Mostra logs do Spark
- `make clean`: Remove containers e imagens

## Armazenamento

O MinIO é configurado com um bucket padrão chamado `raw` para armazenamento de dados brutos. Os dados são persistidos localmente no diretório `data/`.

## Processamento de Dados

O ambiente está configurado para suportar:

1. **Ingestão de Dados**:
   - Upload direto para o MinIO
   - Processamento via Spark
   - Armazenamento em formato Delta Lake

2. **Consultas**:
   - SQL via Trino
   - Processamento distribuído via Spark
   - Notebooks Jupyter para análise

## Configurações

### MinIO
- Endpoint: http://localhost:9000
- Credenciais: minioadmin/minioadmin
- Bucket padrão: raw

### Spark
- Versão: 3.3.0
- Delta Lake: 2.3.0
- Portas: 8888 (Jupyter), 4040 (UI)

### Trino
- Versão: 423
- Porta: 8080
- Catalogs: minio, hive

### Hive Metastore
- Versão: 3.1.3
- Porta: 9083
- Banco de dados: MariaDB

## Desenvolvimento

Para desenvolvimento local:

1. Os notebooks Jupyter estão disponíveis em `notebooks/`
2. Os dados podem ser acessados via MinIO ou diretamente no filesystem
3. O Hive Metastore gerencia os metadados das tabelas
4. O Trino permite consultas SQL sobre os dados

## Troubleshooting

### Logs
- MinIO: `docker logs data-lab-minio-1`
- Spark: `docker logs data-lab-spark-1`
- Trino: `docker logs data-lab-trino-1`
- Hive: `docker logs data-lab-hive-metastore-1`

### Problemas Comuns
1. Se o Hive Metastore falhar ao iniciar:
   - Verifique os logs do MariaDB
   - Confirme se o banco de dados foi criado
   - Verifique as configurações no hive-site.xml

2. Se o Trino não conseguir se conectar ao MinIO:
   - Verifique se o bucket 'raw' existe
   - Confirme as credenciais do MinIO
   - Verifique a conectividade entre os containers

## Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para detalhes.

## Acesso aos Serviços

### MinIO
1. **Console Web**:
   - URL: http://localhost:9001
   - Credenciais: minioadmin/minioadmin
   - Funcionalidades:
     - Upload/download de arquivos
     - Gerenciamento de buckets
     - Visualização de objetos
     - Configurações de acesso

2. **API S3**:
   - Endpoint: http://localhost:9000
   - Credenciais: minioadmin/minioadmin
   - Exemplo de uso com AWS CLI:
     ```bash
     aws s3 --endpoint-url http://localhost:9000 ls s3://raw/
     ```

### Jupyter Notebook
1. **Interface Web**:
   - URL: http://localhost:8888
   - Acesso direto sem senha
   - Funcionalidades:
     - Criação de notebooks
     - Execução de código Python
     - Visualização de dados
     - Integração com Spark

2. **Exemplo de Código**:
   ```python
   from pyspark.sql import SparkSession
   
   spark = SparkSession.builder \
       .appName("MinIO Example") \
       .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
       .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
       .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
       .getOrCreate()
   ```

### Spark UI
1. **Interface Web**:
   - URL: http://localhost:4040
   - Funcionalidades:
     - Monitoramento de jobs
     - Visualização de executors
     - Métricas de performance
     - Logs de aplicação

2. **Histórico de Jobs**:
   - URL: http://localhost:18080
   - Requer configuração adicional do History Server

### Trino
1. **Interface Web**:
   - URL: http://localhost:8080
   - Credenciais: admin/(sem senha)
   - Funcionalidades:
     - Editor SQL
     - Visualização de queries
     - Monitoramento de performance
     - Gerenciamento de catalogs

2. **Exemplo de Consulta**:
   ```sql
   -- Listar schemas disponíveis
   SHOW SCHEMAS FROM minio;
   
   -- Listar tabelas
   SHOW TABLES FROM minio.default;
   
   -- Consultar dados
   SELECT * FROM minio.default.minha_tabela;
   ```

3. **CLI**:
   ```bash
   docker exec -it data-lab-trino-1 trino
   ```

### Hive Metastore
1. **API Thrift**:
   - Endpoint: thrift://localhost:9083
   - Usado internamente pelo Spark e Trino
   - Não requer acesso direto

2. **Beeline**:
   ```bash
   docker exec -it data-lab-hive-metastore-1 beeline -u jdbc:hive2://localhost:10000
   ```

### MariaDB (Hive Metastore)
1. **CLI**:
   ```bash
   docker exec -it data-lab-mariadb-1 mysql -u hive -p
   # Senha: hive
   ```

2. **Consultas Úteis**:
   ```sql
   -- Listar bancos de dados
   SHOW DATABASES;
   
   -- Usar o banco metastore
   USE metastore_db;
   
   -- Listar tabelas
   SHOW TABLES;
   ``` 