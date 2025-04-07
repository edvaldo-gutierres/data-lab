# Airbyte

Airbyte é uma plataforma de integração de dados de código aberto que facilita a movimentação de dados de diversas fontes para destinos como o Data Lake.

## Funcionalidades

- **Conectores Pré-Construídos**: Mais de 170 conectores para diversas fontes e destinos
- **Normalização**: Transformação de dados em estruturas compatíveis com análise
- **Sincronização Incremental**: Transferência apenas de dados novos ou modificados
- **Interface Amigável**: Configuração e monitoramento através de UI Web

## Configuração

No Data Lake, o Airbyte é executado em contêineres Docker com a seguinte configuração:

- **Porta da interface web**: 8000
- **Banco de dados**: PostgreSQL
- **Volumes**:
  - `./airbyte/workspace`: Armazena dados das sincronizações
  - `./airbyte/config`: Armazena configurações do Airbyte

## Acesso

A interface web do Airbyte pode ser acessada em:

- **URL**: http://localhost:8000

## Configurando Conectores

### Exemplo: Configurando um Conector de Origem (PostgreSQL)

1. Acesse a interface web do Airbyte
2. Clique em "Sources" no menu lateral e depois em "+ New source"
3. Selecione "PostgreSQL" como tipo
4. Preencha as informações de conexão:
   - Nome: `postgres_origem`
   - Host: `postgres_host`
   - Porta: `5432`
   - Usuário e senha
   - Base de dados: `meu_banco`
5. Teste a conexão e clique em "Set up source"

### Exemplo: Configurando um Conector de Destino (MinIO/S3)

1. Acesse a interface web do Airbyte
2. Clique em "Destinations" no menu lateral e depois em "+ New destination"
3. Selecione "S3" como tipo
4. Preencha as informações:
   - Nome: `minio_destino`
   - S3 Endpoint: `http://minio:9000`
   - Bucket: `raw`
   - Access Key: `minioadmin`
   - Secret Key: `minioadmin`
   - Formato dos dados: `JSON` ou `Parquet`
5. Teste a conexão e clique em "Set up destination"

### Configurando uma Conexão

1. Clique em "Connections" e depois em "New connection"
2. Selecione a origem e o destino configurados anteriormente
3. Configure a sincronização:
   - Namespace: pasta onde os dados serão salvos (ex: `airbyte_syncs`)
   - Stream prefixo: prefixo para os arquivos (ex: `postgres_`)
   - Frequência de sincronização: intervalo de atualização
4. Selecione as tabelas/streams para sincronizar
5. Configure o modo de sincronização (full refresh ou incremental)
6. Clique em "Set up connection"

## Integração com Outras Ferramentas

### Integração com Airflow

O Airbyte pode ser orquestrado pelo Airflow para automatizar a execução de sincronizações. Exemplo:

```python
# airflow/dags/airbyte_sync.py
from airflow import DAG
from airflow.providers.http.operators.http import SimpleHttpOperator
from datetime import datetime, timedelta
import json

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'airbyte_sync',
    default_args=default_args,
    description='Executa uma sincronização do Airbyte',
    schedule_interval=timedelta(days=1),
)

# Substitua CONNECTION_ID pelo ID da sua conexão
trigger_airbyte_sync = SimpleHttpOperator(
    task_id='trigger_airbyte_sync',
    http_conn_id='airbyte_conn',
    endpoint='/api/v1/connections/run',
    data=json.dumps({"connectionId": "CONNECTION_ID"}),
    headers={"Content-Type": "application/json"},
    method='POST',
    dag=dag,
)
```

### Processamento com Spark

Os dados sincronizados pelo Airbyte podem ser processados pelo Spark:

```python
# Exemplo de processamento de dados do Airbyte com Spark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Processar Dados Airbyte") \
    .getOrCreate()

# Carregar dados sincronizados pelo Airbyte
df = spark.read.format("json") \
    .load("s3a://raw/airbyte_syncs/postgres_tabela")

# Processar dados
resultado = df.select("coluna1", "coluna2") \
    .filter("coluna1 > 0")

# Salvar resultado em formato Delta Lake
resultado.write.format("delta") \
    .mode("overwrite") \
    .save("s3a://raw/dados_processados")
```

## Problemas Comuns

- **Erro de Conexão**: Verifique as credenciais e configurações da fonte/destino
- **Falha na Sincronização**: Verifique os logs na interface do Airbyte
- **Arquivos não Aparecem no MinIO**: Verifique permissões e configurações do bucket

## Comandos Úteis

```bash
# Ver logs do Airbyte
make logs-airbyte

# Acessar o container do Airbyte
docker exec -it data-lab-airbyte-webapp-1 bash
```

## Recursos Adicionais

- [Documentação Oficial do Airbyte](https://docs.airbyte.com/)
- [Conectores Disponíveis](https://airbyte.com/connectors)
- [Guia de Normalização de Dados](https://docs.airbyte.com/understanding-airbyte/namespaces) 