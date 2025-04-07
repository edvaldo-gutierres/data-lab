# Delta Lake

O Delta Lake é um formato de armazenamento de dados de código aberto que proporciona transações ACID, controle de versão e outras funcionalidades avançadas para data lakes modernos.

## O que é Delta Lake?

Delta Lake é uma camada de armazenamento que traz confiabilidade aos data lakes. Ele oferece:

- **Transações ACID**: Garante a consistência dos dados mesmo em caso de falhas
- **Controle de Versão**: Mantém histórico de alterações para rastreabilidade e viagens no tempo
- **Gerenciamento de Schema**: Permite evolução e aplicação de schema
- **Atualizações e Exclusões**: Suporta operações de atualização e exclusão como em bancos de dados tradicionais
- **Otimizações de Desempenho**: Compactação de arquivos, índices Z-order e outros recursos de otimização

## Pré-requisitos

Para trabalhar com Delta Lake neste projeto, você precisa:

- Data Lake em execução (MinIO, Spark e Dremio)
- Conhecimento básico de SQL e Apache Spark

## Criando uma Tabela Delta Lake

### Usando PySpark

Você pode criar uma tabela Delta Lake usando PySpark nos notebooks Jupyter disponíveis:

```python
# Configuração da conexão com MinIO
spark.conf.set("spark.hadoop.fs.s3a.endpoint", "http://minio:9000")
spark.conf.set("spark.hadoop.fs.s3a.access.key", "minioadmin")
spark.conf.set("spark.hadoop.fs.s3a.secret.key", "minioadmin")
spark.conf.set("spark.hadoop.fs.s3a.path.style.access", "true")
spark.conf.set("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
spark.conf.set("spark.delta.logStore.class", "org.apache.spark.sql.delta.storage.S3SingleDriverLogStore")

# Criar DataFrame de exemplo
data = [
  {"id": 1, "nome": "João", "idade": 30},
  {"id": 2, "nome": "Maria", "idade": 25},
  {"id": 3, "nome": "Pedro", "idade": 40}
]
df = spark.createDataFrame(data)

# Salvar como tabela Delta Lake
df.write.format("delta").mode("overwrite").save("s3a://raw/pessoas_delta")

# Registrar a tabela no catálogo do Spark
spark.sql("CREATE TABLE pessoas_delta USING DELTA LOCATION 's3a://raw/pessoas_delta'")
```

### Usando SQL no Spark

Você também pode criar tabelas Delta Lake usando SQL no Spark:

```sql
CREATE TABLE pessoas_delta (
  id INT,
  nome STRING,
  idade INT
)
USING DELTA
LOCATION 's3a://raw/pessoas_delta';

INSERT INTO pessoas_delta VALUES 
  (1, 'João', 30),
  (2, 'Maria', 25),
  (3, 'Pedro', 40);
```

## Operações com Delta Lake

### Consultas

```python
# Consulta básica
df = spark.read.format("delta").load("s3a://raw/pessoas_delta")
df.show()

# Consulta com SQL
spark.sql("SELECT * FROM pessoas_delta WHERE idade > 25").show()
```

### Atualizações

O Delta Lake suporta operações de atualização:

```python
# Atualizar dados
from delta.tables import DeltaTable

deltaTable = DeltaTable.forPath(spark, "s3a://raw/pessoas_delta")
deltaTable.update(
    condition = "idade > 30",
    set = { "idade": "idade + 1" }
)
```

### Exclusões

```python
# Excluir dados
deltaTable.delete("nome = 'Pedro'")
```

### Viagem no Tempo (Time Travel)

O Delta Lake permite consultar versões anteriores dos dados:

```python
# Consultar versão anterior (por número de versão)
df_v1 = spark.read.format("delta").option("versionAsOf", 0).load("s3a://raw/pessoas_delta")
df_v1.show()

# Consultar versão anterior (por timestamp)
df_ts = spark.read.format("delta").option("timestampAsOf", "2023-04-01T00:00:00.000Z").load("s3a://raw/pessoas_delta")
df_ts.show()
```

## Acesso via Dremio

Depois de criar tabelas Delta Lake, você pode acessá-las via Dremio:

1. Abra a interface web do Dremio (http://localhost:9047)
2. Configure uma fonte S3 apontando para o MinIO, conforme descrito em [Consultas SQL](sql-queries.md)
3. Navegue até a pasta `raw/pessoas_delta`
4. O Dremio detectará automaticamente os arquivos Delta Lake e permitirá consultas SQL

## Otimizações

### Compactação de Arquivos (Compaction)

```python
# Compactar arquivos pequenos
deltaTable.optimize().executeCompaction()
```

### Índice Z-Order

```python
# Criar índice Z-order para otimizar consultas por idade
deltaTable.optimize().executeZOrderBy("idade")
```

## Melhores Práticas

1. **Particionamento**: Particione dados grandes por data, região ou outra dimensão relevante
2. **Compactação Regular**: Execute compactação regularmente para evitar muitos arquivos pequenos
3. **Vacuum Periódico**: Remova arquivos não utilizados para economizar espaço
4. **Evolução de Schema**: Use evolução de schema para adicionar campos sem quebrar aplicações existentes

## Solução de Problemas

- **Erro de Acesso Negado**: Verifique as credenciais do MinIO
- **Arquivos não Visíveis no Dremio**: Certifique-se de que o _delta_log está acessível
- **Problemas de Performance**: Considere otimizar a tabela ou melhorar o particionamento

## Recursos Adicionais

- [Documentação Oficial do Delta Lake](https://delta.io)
- [Delta Lake no Apache Spark](https://docs.delta.io/latest/delta-intro.html)
- [Github do Projeto Delta Lake](https://github.com/delta-io/delta)
