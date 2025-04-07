# Perguntas Frequentes (FAQ)

Esta seção contém respostas para as perguntas mais frequentes sobre o uso do Data Lake.

## Geral

### O que é o Data Lake?

Este projeto implementa um data lake completo usando tecnologias open source como MinIO (armazenamento de objetos), Apache Spark (processamento de dados), Dremio (consultas SQL), Delta Lake (formato de tabela com transações ACID), Airflow (orquestração), Airbyte (integração de dados) e OpenMetadata (governança).

### Quais são os requisitos mínimos para executar o Data Lake?

- Docker 20.10 ou superior
- Docker Compose 2.0 ou superior
- 12GB de RAM (recomendado)
- 4 cores de CPU
- 30GB de espaço em disco

### Posso executar o Data Lake sem Docker?

Não recomendamos. O projeto foi projetado para ser executado em contêineres Docker, garantindo assim que todos os componentes funcionem juntos sem problemas de configuração. A instalação manual de cada componente exigiria configurações complexas e compatibilidade entre versões.

## Instalação e Configuração

### O que fazer se uma porta estiver em uso?

Se encontrar um erro como "Ports are not available", siga estas etapas:
1. Identifique qual processo está usando a porta: `sudo lsof -i :9000`
2. Interrompa o processo ou modifique a porta no arquivo `docker-compose.yml`

### Como alterar as credenciais padrão?

Para alterar as credenciais padrão (como usuário/senha do MinIO), edite as variáveis de ambiente correspondentes no arquivo `docker-compose.yml`.

### O Docker não inicia por falta de memória, o que fazer?

Ajuste os recursos alocados ao Docker:
- No Windows/Mac: Docker Desktop > Settings > Resources
- No Linux: Edite o arquivo `/etc/docker/daemon.json`

## MinIO

### Como faço upload de arquivos para o MinIO?

1. Acesse a interface web do MinIO: http://localhost:9001
2. Faça login com as credenciais padrão (minioadmin/minioadmin)
3. Navegue até o bucket desejado (ex: "raw")
4. Clique em "Upload" e selecione os arquivos

### Como criar um novo bucket no MinIO?

1. Acesse a interface web do MinIO: http://localhost:9001
2. Faça login com as credenciais padrão
3. Clique em "Create Bucket"
4. Digite o nome do bucket e clique em "Create"

## Spark

### Como acessar os notebooks Jupyter?

Acesse http://localhost:8888 no seu navegador para acessar a interface do Jupyter Notebook, onde você pode criar e executar notebooks com Spark.

### Os notebooks persistem quando o container é reiniciado?

Sim. Os notebooks são armazenados na pasta `./notebooks` do seu sistema de arquivos local, que é montada como um volume no contêiner.

### Como acessar a UI do Spark?

Acesse http://localhost:4040 no seu navegador quando houver uma aplicação Spark em execução.

## Dremio

### Preciso criar um usuário no primeiro acesso ao Dremio?

Sim. Na primeira vez que acessar o Dremio (http://localhost:9047), você será solicitado a criar um usuário e senha.

### Como conectar o Dremio ao MinIO?

1. No Dremio, clique em "Fontes" no menu lateral
2. Clique em "+" para adicionar uma nova fonte
3. Selecione "S3"
4. Configure com:
   - Nome: MinIO
   - URL de Acesso: http://minio:9000
   - Credenciais: minioadmin/minioadmin
   - Bucket: raw

### O Dremio não está encontrando meus arquivos no MinIO. O que pode ser?

Verifique:
1. Se o bucket foi criado corretamente
2. Se a configuração da fonte S3 no Dremio está correta
3. Se os arquivos foram carregados no bucket correto

## Delta Lake

### Como consultar tabelas Delta Lake no Dremio?

Depois de criar tabelas Delta Lake no MinIO usando o Spark, você pode acessá-las via Dremio navegando até o local onde os arquivos Delta Lake estão armazenados.

### Como atualizar dados em uma tabela Delta Lake?

Use a API DeltaTable do Spark para realizar operações de atualização:

```python
from delta.tables import DeltaTable

deltaTable = DeltaTable.forPath(spark, "s3a://raw/exemplo_delta")
deltaTable.update(
    condition = "id = 1",
    set = { "valor": "novo_valor" }
)
```

## Airflow

### Como acessar a interface do Airflow?

Acesse http://localhost:8080 em seu navegador. Use o usuário `airflow` e senha `airflow` para fazer login.

### Como criar um novo fluxo de trabalho (DAG) no Airflow?

Crie um arquivo Python no diretório `airflow/dags/` com a definição do DAG. Exemplo:

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def hello_world():
    return "Olá, mundo!"

dag = DAG(
    'hello_world',
    start_date=datetime(2023, 1, 1),
    schedule_interval='@daily'
)

task = PythonOperator(
    task_id='hello_task',
    python_callable=hello_world,
    dag=dag
)
```

### Como agendar a execução de um DAG?

Configure o parâmetro `schedule_interval` na definição do DAG:
- `@daily`: uma vez por dia
- `@hourly`: uma vez por hora
- `0 0 * * *`: cron syntax (neste exemplo, meia-noite todos os dias)

### Como conectar o Airflow ao MinIO ou ao Spark?

Para o MinIO, use o operador S3 e configure uma conexão do tipo "Amazon S3":
- Conn Id: minio_s3
- Extra: `{"host": "http://minio:9000", "aws_access_key_id": "minioadmin", "aws_secret_access_key": "minioadmin"}`

Para o Spark, use o SparkSubmitOperator:
```python
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

spark_task = SparkSubmitOperator(
    task_id='processar_dados',
    application='/opt/airflow/dags/scripts/processar_dados.py',
    conn_id='spark_default',
    dag=dag
)
```

## Airbyte

### Como acessar a interface do Airbyte?

Acesse http://localhost:8000 em seu navegador.

### Como configurar uma fonte de dados no Airbyte?

1. Acesse a interface do Airbyte
2. Clique em "Sources" e depois em "+ New source"
3. Selecione o tipo de fonte (banco de dados, API, etc.)
4. Configure os parâmetros de conexão como host, usuário, senha, etc.
5. Teste a conexão e salve a configuração

### Como configurar um destino para os dados no Airbyte?

1. Clique em "Destinations" e depois em "+ New destination"
2. Para salvar no MinIO, selecione "S3" como tipo de destino
3. Configure:
   - Nome: MinIO
   - S3 Endpoint: http://minio:9000
   - Access Key: minioadmin
   - Secret Key: minioadmin
   - Bucket: raw
   - Path: airbyte_data
4. Teste a conexão e salve

### Como criar uma sincronização de dados no Airbyte?

1. Clique em "Connections" e depois em "+ New connection"
2. Selecione a fonte e o destino configurados anteriormente
3. Selecione as tabelas/streams que deseja sincronizar
4. Configure a frequência de sincronização
5. Clique em "Set up connection"

## OpenMetadata

### Como acessar a interface do OpenMetadata?

Acesse http://localhost:8585 em seu navegador. Use o usuário `admin` e senha `admin` para fazer login.

### Como adicionar fontes de dados ao OpenMetadata?

1. Acesse a interface do OpenMetadata
2. Vá para "Settings" > "Services" > "Add New Service"
3. Selecione o tipo de serviço (Dremio, S3, Hive, etc.)
4. Configure os parâmetros de conexão
5. Teste a conexão e salve

### O que são os testes de qualidade no OpenMetadata?

Os testes de qualidade permitem verificar se os dados atendem a determinados critérios, como:
- Valores não nulos
- Unicidade de valores
- Intervalos válidos
- Formatos específicos (email, CEP, etc.)

Você pode configurar esses testes na página de detalhes de uma tabela, na aba "Quality".

### Como visualizar a linhagem (lineage) dos dados?

1. Acesse a página de detalhes de uma tabela ou asset
2. Clique na aba "Lineage"
3. Visualize o grafo de linhagem mostrando a origem e destino dos dados

## Solução de Problemas

### Os serviços falham ao iniciar, o que pode ser?

Verifique:
1. Se o Docker e Docker Compose estão atualizados
2. Se há recursos suficientes (memória, CPU, disco)
3. Se não há conflitos de porta
4. Verifique os logs: `docker-compose logs`

### Os dados não aparecem quando consulto via Dremio, mas estão no MinIO.

Possíveis causas:
1. A fonte S3 no Dremio não está configurada corretamente
2. O Dremio pode não estar reconhecendo o formato dos arquivos
3. Pode ser necessário criar visões ou tabelas virtuais no Dremio

### Como vejo os logs de um serviço específico?

Use os comandos:
```bash
# MinIO
make logs-minio

# Spark
make logs-spark

# Dremio
make logs-dremio

# Hive Metastore
make logs-hive

# Airflow
make logs-airflow

# Airbyte
make logs-airbyte

# OpenMetadata
make logs-openmetadata
```

### Como redefinir tudo e começar do zero?

Para remover completamente os contêineres, volumes e imagens:
```bash
make down
make clean
```

## Contribuição e Desenvolvimento

### Como contribuir para o projeto?

Consulte o [Guia de Contribuição](development/contributing.md) para obter instruções detalhadas sobre como contribuir para o projeto.

### Onde posso encontrar mais documentação sobre os componentes?

- [MinIO](https://docs.min.io/)
- [Apache Spark](https://spark.apache.org/docs/latest/)
- [Dremio](https://docs.dremio.com/)
- [Delta Lake](https://delta.io/documentation/)
- [Apache Airflow](https://airflow.apache.org/docs/)
- [Airbyte](https://docs.airbyte.com/)
- [OpenMetadata](https://docs.open-metadata.org/)
