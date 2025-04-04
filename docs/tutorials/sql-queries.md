# Consultas SQL com Trino

Este guia mostra como realizar consultas SQL em tabelas Delta Lake armazenadas no MinIO usando o Trino.

## Pré-requisitos

- Trino em execução (porta 8080)
- DBeaver ou outro cliente SQL
- Tabela Delta Lake já criada no MinIO

## Conexão com Trino

### Via DBeaver

1. Adicione uma nova conexão:
   - Tipo: Trino
   - Host: localhost
   - Port: 8080
   - Username: trino
   - Catalog: hive
   - Schema: default

2. Configurações adicionais:
   - SSL: desativado
   - Kerberos: desativado

## Consultando Tabelas Delta Lake

### 1. Registre a Tabela no Hive Metastore

Primeiro, precisamos registrar a tabela Delta Lake no Hive Metastore. Use o seguinte comando SQL no DBeaver:

```sql
CREATE TABLE hive.default.pessoas (
    nome VARCHAR,
    idade INTEGER
)
WITH (
    external_location = 's3a://raw/exemplo_pessoas',
    format = 'PARQUET'
);
```

### 2. Consultar a Tabela

Para consultar a tabela, você pode usar o seguinte comando SQL:

```sql
SELECT * FROM hive.default.pessoas;
```

Ou se preferir usar o schema `minio`:

```sql
SELECT * FROM minio.default.pessoas;
```

Se você quiser ver apenas a estrutura da tabela, pode usar:

```sql
DESCRIBE hive.default.pessoas;
```

Lembre-se que no DBeaver você precisa estar conectado ao Trino (não ao Hive diretamente) para fazer essas consultas. A conexão deve ser feita com:
- Host: localhost
- Porta: 8080
- Usuário: admin
- Senha: admin

Quer que eu mostre como inserir alguns dados de exemplo para testar a consulta?