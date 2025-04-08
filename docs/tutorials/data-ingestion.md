# Tutorial de Ingestão de Dados

Este tutorial demonstra como ingerir dados de diferentes fontes para o data lake usando Airbyte.

## Pré-requisitos

- Ambiente Data Lab em execução (`make up`)
- Acesso à interface do Airbyte (http://localhost:8000)
- Credenciais do Airbyte (execute `make airbyte-credentials`)

## Visão Geral do Processo

O fluxo de ingestão de dados com Airbyte consiste em três etapas principais:

1. **Configurar uma fonte de dados** (Source) - de onde virão os dados
2. **Configurar um destino** (Destination) - para onde irão os dados
3. **Criar uma conexão** (Connection) - configurar como os dados serão movidos da fonte para o destino

## 1. Configurando uma Fonte de Dados

Neste exemplo, vamos configurar uma fonte de dados usando a API pública do GitHub como exemplo.

1. Acesse a interface do Airbyte em http://localhost:8000
2. Faça login com as credenciais obtidas via `make airbyte-credentials`
3. No menu lateral, clique em "Sources"
4. Clique no botão "+ New source"
5. Selecione "GitHub" na lista de conectores disponíveis
6. Configure a fonte:
   - **Source name**: `github-source`
   - **GitHub Personal Access Token**: [Gere um token no GitHub](https://github.com/settings/tokens)
   - **GitHub Repository Owner**: seu nome de usuário ou organização
   - **GitHub Repository**: nome do repositório (ex: "data-lab")
   - **Start Date**: data a partir da qual você deseja coletar dados (formato YYYY-MM-DD)
7. Clique em "Set up source"

## 2. Configurando um Destino para o MinIO

Agora vamos configurar o MinIO como destino para armazenar os dados no formato do Data Lake.

1. No menu lateral, clique em "Destinations"
2. Clique no botão "+ New destination"
3. Selecione "S3" na lista de conectores disponíveis
4. Configure o destino:
   - **Destination name**: `minio-destination`
   - **S3 Bucket Name**: `raw`
   - **S3 Bucket Path**: `airbyte-data`
   - **S3 Endpoint**: `http://minio:9000` (use este endereço pois o Airbyte está na mesma rede Docker)
   - **Access Key ID**: `minioadmin`
   - **Secret Access Key**: `minioadmin`
   - **S3 Bucket Region**: pode deixar em branco
   - **Format**: `JSON Lines (Newline-delimited JSON)` ou `Parquet` (recomendado para análises)
5. Clique em "Set up destination"

## 3. Criando uma Conexão

Com a fonte e o destino configurados, vamos criar uma conexão entre eles:

1. No menu lateral, clique em "Connections"
2. Clique no botão "+ New connection"
3. Selecione a fonte que criamos (`github-source`)
4. Selecione o destino que criamos (`minio-destination`)
5. Configure a conexão:
   - **Replication frequency**: Escolha a frequência (ex: "Every 24 hours")
   - **Destination Namespace**: `github`
   - **Streams to replicate**: Selecione as tabelas/streams que deseja sincronizar (ex: "Issues", "Pull Requests")
   - Para cada stream, selecione o modo de sincronização:
     - **Full Refresh | Overwrite**: substitui todos os dados a cada sincronização
     - **Full Refresh | Append**: adiciona os dados a cada sincronização
     - **Incremental | Append**: sincroniza apenas novos dados (recomendado para performance)
6. Clique em "Set up connection"

## 4. Executando uma Sincronização

Depois de configurar a conexão, você pode executar manualmente uma sincronização:

1. Na lista de conexões, encontre a conexão que acabou de criar
2. Clique no botão "..." (três pontos) e selecione "Sync now"
3. Uma sincronização será iniciada. Você pode acompanhar o progresso na interface.

## 5. Acessando os Dados no MinIO

Após a conclusão da sincronização, os dados estarão disponíveis no MinIO:

1. Acesse o Console do MinIO em http://localhost:9001
2. Faça login com as credenciais minioadmin/minioadmin
3. Navegue até o bucket `raw`
4. Os dados estarão na pasta `airbyte-data/github`

## 6. Processando Dados com Spark

Agora que os dados estão no Data Lake, você pode processá-los com Spark:

1. Acesse o Jupyter Notebook em http://localhost:8888
2. Crie um novo notebook Python 3
3. Execute o seguinte código para ler os dados JSON do MinIO:

```python
from pyspark.sql import SparkSession

# Inicializar Spark com suporte a S3
spark = SparkSession.builder \
    .appName("Processar Dados GitHub") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .getOrCreate()

# Ler dados do Airbyte no formato JSON Lines
df = spark.read.json("s3a://raw/airbyte-data/github/issues")

# Mostrar esquema dos dados
df.printSchema()

# Mostrar primeiras linhas
df.show(5)

# Fazer algumas análises
print(f"Total de registros: {df.count()}")

# Exemplo: Contar issues por status
df.groupBy("state").count().show()

# Salvar dados em formato Delta Lake para análises futuras
df.write.format("delta") \
    .mode("overwrite") \
    .save("s3a://raw/processed/github/issues")
```

## Automatizando com Airflow

Para automatizar o processo de sincronização, você pode usar o Airflow. Acesse http://localhost:8080 e crie um DAG que chame a API do Airbyte.

## Próximos Passos

- Experimente configurar outras fontes de dados como bancos de dados, APIs ou arquivos
- Explore transformações mais avançadas com Spark
- Configure o Dremio para consultar dados diretamente do MinIO
- Implemente um pipeline de dados completo com Airflow

## Troubleshooting

- **Falha na sincronização**: Verifique os logs na interface do Airbyte
- **Dados não aparecem no MinIO**: Verifique as configurações do destino S3/MinIO
- **Erro de conexão com a fonte**: Verifique credenciais e configurações de rede
- **Problemas com o Airbyte**: Execute `make airbyte-logs` para ver os logs detalhados
