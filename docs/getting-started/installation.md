# Guia de Instalação

Este guia irá ajudá-lo a configurar o ambiente do Data Lake em sua máquina local.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/) (versão 20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versão 2.0 ou superior)
- [Make](https://www.gnu.org/software/make/) (opcional, mas recomendado)

> **Nota**: Como este projeto utiliza Docker, não é necessário instalar as dependências Python, Spark, Dremio ou outras ferramentas individualmente. Todos os componentes já estão configurados nas imagens Docker correspondentes.

## Instalação

1. Clone o repositório:
```bash
git clone https://github.com/edvaldo-gutierres/data-lab.git
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

Após executar este comando, todos os serviços estarão disponíveis e configurados automaticamente.

## Configuração do Airbyte

O Airbyte é gerenciado separadamente usando a ferramenta `abctl`. Durante a execução de `make up`, o sistema tenta instalar e iniciar o Airbyte automaticamente, mas esse processo pode falhar em alguns ambientes.

Se o Airbyte não iniciar automaticamente, você pode configurá-lo manualmente usando os seguintes comandos:

1. Instale o Airbyte:
```bash
make airbyte-install
```

2. Verifique o status da instalação:
```bash
make airbyte-status
```

3. Se necessário, inicie o Airbyte manualmente:
```bash
make airbyte-start
```

4. Para obter as credenciais de acesso:
```bash
make airbyte-credentials
```

> **Nota**: A primeira instalação do Airbyte pode levar vários minutos para ser concluída, dependendo da velocidade da sua conexão com a internet e do desempenho do seu computador.

## Verificação

Após a instalação, verifique se todos os serviços estão rodando:

```bash
docker ps
```

Você deverá ver os seguintes containers:
- `data-lab-minio-1`
- `data-lab-spark-1`
- `data-lab-dremio-1`
- `data-lab-hive-metastore-1`
- `data-lab-mariadb-1`
- `data-lab-metabase-1`
- `data-lab-metabase-db-1`

Além disso, se o Airbyte estiver em execução, você verá alguns containers adicionais com prefixo `airbyte`.

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

### Dremio
- Interface: [http://localhost:9047](http://localhost:9047)
- No primeiro acesso, será necessário criar uma senha.

### OpenMetadata
- Interface: [http://localhost:8585](http://localhost:8585)

### Airbyte
- Interface: [http://localhost:8000](http://localhost:8000)
- Para obter as credenciais: `make airbyte-credentials`

### Metabase
- Interface: [http://localhost:3000](http://localhost:3000)
- Configuração inicial na primeira execução

## Estrutura de Diretórios

```
.
├── data/              # Dados do MinIO
├── hive/              # Configurações do Hive
├── notebooks/         # Jupyter notebooks
├── spark/             # Configurações do Spark
└── dremio/            # Configurações do Dremio
```

## Próximos Passos

- [Configure seu ambiente](configuration.md)
- Explore o [tutorial de ingestão de dados](../tutorials/data-ingestion.md)
- Aprenda sobre [consultas SQL](../tutorials/sql-queries.md)

## Troubleshooting

### Problemas com o Airbyte

Se você encontrar problemas com o Airbyte:

1. Verifique o status:
```bash
make airbyte-status
```

2. Se não estiver instalado, instale-o:
```bash
make airbyte-install
```

3. Se estiver instalado mas não em execução, inicie-o:
```bash
make airbyte-start
```

4. Verifique os logs para diagnóstico:
```bash
make airbyte-logs
```

5. Se necessário, pare e reinicie o Airbyte:
```bash
make airbyte-stop
make airbyte-start
```

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

# Dremio
make logs-dremio

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