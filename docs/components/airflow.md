# Apache Airflow

O Apache Airflow é uma plataforma de orquestração de fluxo de trabalho que permite programar, monitorar e gerenciar pipelines de dados complexos.

## Funcionalidades

- **Orquestração**: Agendamento e sequenciamento de tarefas em fluxos de trabalho (DAGs)
- **Monitoramento**: Interface web para visualizar o status e o progresso das tarefas
- **Escalabilidade**: Execução distribuída de tarefas
- **Extensibilidade**: Conectores para diversos sistemas e APIs

## Configuração

No Data Lake, o Airflow é executado em contêineres Docker com a seguinte configuração:

- **Porta da interface web**: 8080
- **Executor**: LocalExecutor
- **Banco de dados**: PostgreSQL
- **Credenciais padrão**: 
  - Usuário: airflow
  - Senha: airflow

## Acesso

A interface web do Airflow pode ser acessada em:

- **URL**: http://localhost:8080

## Estrutura de Diretórios

```
airflow/
├── dags/            # Diretório para armazenar os DAGs (fluxos de trabalho)
├── logs/            # Logs das execuções
├── plugins/         # Plugins personalizados
└── config/          # Arquivos de configuração adicional
```

## Criando um DAG

Para criar um fluxo de trabalho no Airflow, crie um arquivo Python no diretório `airflow/dags/`. Exemplo:

```python
# airflow/dags/exemplo_dag.py
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python_operator import PythonOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'exemplo_dag',
    default_args=default_args,
    description='Um exemplo de DAG',
    schedule_interval=timedelta(days=1),
)

def tarefa_exemplo():
    print("Esta é uma tarefa de exemplo")

task1 = PythonOperator(
    task_id='tarefa_exemplo',
    python_callable=tarefa_exemplo,
    dag=dag,
)
```

## Integrando com Outros Serviços

### Integração com Spark

```python
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

spark_task = SparkSubmitOperator(
    task_id='processar_dados',
    application='/opt/airflow/dags/scripts/processar_dados.py',
    conn_id='spark_default',
    conf={'spark.master': 'spark://spark:7077'},
    dag=dag,
)
```

### Integração com MinIO (S3)

```python
from airflow.providers.amazon.aws.operators.s3 import S3CreateObjectOperator

s3_task = S3CreateObjectOperator(
    task_id='upload_to_minio',
    s3_bucket='raw',
    s3_key='exemplo/dados.csv',
    data='dados,para,upload',
    aws_conn_id='minio_conn',
    dag=dag,
)
```

### Integração com Airbyte

```python
from airflow.providers.http.operators.http import SimpleHttpOperator
import json

airbyte_trigger = SimpleHttpOperator(
    task_id='trigger_airbyte_sync',
    http_conn_id='airbyte_conn',
    endpoint='/api/v1/connections/run',
    data=json.dumps({"connectionId": "your-connection-id"}),
    headers={"Content-Type": "application/json"},
    method='POST',
    dag=dag,
)
```

## Problemas Comuns

- **DAG não aparece na interface**: Verifique se o arquivo Python tem sintaxe correta e define uma variável `dag`
- **Tarefas falham**: Verifique os logs no diretório `airflow/logs/` ou na interface web
- **Problemas de conexão**: Verifique se as conexões para outros serviços estão configuradas corretamente

## Comandos Úteis

```bash
# Ver logs do Airflow
make logs-airflow

# Acessar o container do Airflow
docker exec -it data-lab-airflow-webserver-1 bash

# Executar comandos do Airflow CLI
docker exec -it data-lab-airflow-webserver-1 airflow dags list
```

## Recursos Adicionais

- [Documentação oficial do Apache Airflow](https://airflow.apache.org/docs/)
- [Tutoriais do Airflow](https://airflow.apache.org/docs/apache-airflow/stable/tutorial.html)
- [Melhores práticas para DAGs](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html) 