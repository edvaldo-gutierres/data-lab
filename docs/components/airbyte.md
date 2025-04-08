# Airbyte

Airbyte é uma plataforma de integração de dados de código aberto que facilita a movimentação de dados de diversas fontes para destinos como o Data Lake.

## Instalação do Airbyte

No Data Lab, o Airbyte é instalado e gerenciado exclusivamente via Airbyte CLI (abctl), uma ferramenta de linha de comando oficial que simplifica a instalação e o gerenciamento do Airbyte.

### Instalação do abctl

```bash
# Instalação via script oficial
curl -LsfS https://get.airbyte.com | bash -

# Verificar a instalação
abctl version
```

### Comandos Básicos do abctl

```bash
# Instalar o Airbyte localmente
abctl local install --low-resource-mode

# Iniciar o Airbyte
abctl local start

# Parar o Airbyte
abctl local stop

# Ver o status do Airbyte
abctl local status

# Remover o Airbyte
abctl local uninstall
```

### Vantagens do abctl

- Instalação simplificada
- Gerenciamento isolado (não interfere em outros serviços do Data Lab)
- Atualizações facilitadas
- Diagnóstico de problemas

## Funcionalidades

- **Conectores Pré-Construídos**: Mais de 170 conectores para diversas fontes e destinos
- **Normalização**: Transformação de dados em estruturas compatíveis com análise
- **Sincronização Incremental**: Transferência apenas de dados novos ou modificados
- **Interface Amigável**: Configuração e monitoramento através de UI Web

## Configuração

No Data Lab, o Airbyte é executado exclusivamente utilizando o Airbyte CLI (abctl), que gerencia os contêineres Docker automaticamente. Esta abordagem oferece várias vantagens:

- **Instalação simplificada**: O abctl cuida de toda a configuração necessária
- **Gerenciamento isolado**: O Airbyte roda independentemente dos outros serviços do Data Lab
- **Atualizações facilitadas**: O abctl permite atualizar o Airbyte com um único comando
- **Diagnóstico de problemas**: Ferramentas integradas para verificar o status e logs
- **Sem dependência de diretórios locais**: O abctl gerencia seus próprios volumes e configurações

### Armazenamento de Dados

O Airbyte gerenciado pelo abctl não utiliza diretórios no repositório do projeto. Todos os dados são armazenados em:

- **Volumes Docker**: Gerenciados automaticamente pelo abctl
- **Diretório de configuração**: Normalmente em `~/.airbyte`

Isso significa que não é necessário criar ou gerenciar diretórios para o Airbyte no projeto, simplificando a configuração e manutenção.

### Instalação via abctl

O método único para instalar e gerenciar o Airbyte é usando a ferramenta oficial de linha de comando `abctl`.

### 1. Instalar o abctl

```bash
curl -LsfS https://get.airbyte.com | bash -
```

### 2. Instalar o Airbyte

Para ambientes com recursos limitados (como a maioria dos laptops e desktops), recomendamos o modo de baixo recurso:

```bash
abctl local install --low-resource-mode
```

Para ambientes com mais recursos (4+ CPUs dedicadas):

```bash
abctl local install
```

### 3. Obter as credenciais

Após a instalação, você precisa das credenciais para acessar a interface web:

```bash
abctl local credentials
```

Esse comando irá exibir informações como:
```
Credentials:
Email: user@example.com
Password: random_password
Client-Id: 03ef466c-5558-4ca5-856b-4960ba7c161b
Client-Secret: m2UjnDO4iyBQ3IsRiy5GG3LaZWP6xs9I
```

Para definir sua própria senha:

```bash
abctl local credentials --password SuaSenhaForte
```

### 4. Acessar o Airbyte

Após a instalação, o Airbyte estará disponível em:

- **URL**: http://localhost:8000
- **Credenciais**: Use as credenciais obtidas no passo anterior

## Comandos via Makefile

Para simplificar o gerenciamento do Airbyte, disponibilizamos comandos no Makefile:

| Comando | Descrição |
|---------|-----------|
| `make airbyte-install` | Instala o Airbyte no modo de baixo recurso usando abctl |
| `make airbyte-start` | Inicia o Airbyte usando abctl |
| `make airbyte-stop` | Para o Airbyte usando abctl |
| `make airbyte-status` | Verifica o status atual do Airbyte usando abctl |
| `make airbyte-credentials` | Exibe as credenciais do Airbyte |
| `make airbyte-logs` | Exibe os logs do Airbyte usando abctl |

O comando `make up` agora também inicia automaticamente o Airbyte junto com os outros serviços, verificando sua instalação e executando-o quando necessário.

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

### Troubleshooting com abctl

Quando estiver utilizando o Airbyte, os seguintes problemas comuns podem ocorrer:

#### Porta em uso

Se receber erro de que a porta 8000 ou 8001 está em uso:

```bash
# Verificar quais processos estão usando as portas
sudo lsof -i :8000
sudo lsof -i :8001

# Parar os processos (substitua PID pelo ID do processo)
sudo kill -9 PID
```

#### Problemas com containers

```bash
# Ver logs dos containers do Airbyte
abctl local logs

# Reiniciar o Airbyte
abctl local stop
abctl local start

# Atualizar o Airbyte para a versão mais recente
abctl local upgrade
```

#### Problemas de permissão

Se encontrar problemas de permissão de arquivos:

```bash
# Verificar o diretório do Airbyte
ls -la ~/.airbyte

# Corrigir permissões se necessário
sudo chown -R $USER:$USER ~/.airbyte
```

## Comandos Úteis

```bash
# Ver status do Airbyte (abctl)
abctl local status

# Ver logs do Airbyte (abctl)
abctl local logs

# Entrar na interface de linha de comando do Airbyte (abctl)
abctl local console

# Exportar configuração atual do Airbyte (abctl)
abctl local export --file airbyte-config.tar.gz

# Importar configuração do Airbyte (abctl)
abctl local import --file airbyte-config.tar.gz
```

## Recursos Adicionais

- [Documentação Oficial do Airbyte](https://docs.airbyte.com/)
- [Conectores Disponíveis](https://airbyte.com/connectors)
- [Guia de Normalização de Dados](https://docs.airbyte.com/understanding-airbyte/namespaces) 