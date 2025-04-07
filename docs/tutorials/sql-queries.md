# Consultas SQL com Dremio

Este guia mostra como realizar consultas SQL em tabelas Delta Lake armazenadas no MinIO usando o Dremio.

## Pré-requisitos

- Dremio em execução (porta 9047)
- Tabela Delta Lake já criada no MinIO

## Acessando o Dremio

O Dremio possui uma interface web integrada que permite realizar consultas SQL diretamente no navegador. Para acessar:

1. Abra seu navegador e acesse [http://localhost:9047](http://localhost:9047)
2. Na primeira vez, você precisará criar um usuário e senha
3. Após o login, você será direcionado para o dashboard do Dremio

## Configurando Fontes de Dados

Para consultar dados no MinIO:

1. No menu lateral, clique em "Fontes"
2. Clique em "+" para adicionar uma nova fonte
3. Selecione "S3"
4. Configure:
   - Nome: MinIO
   - URL de Acesso: http://minio:9000
   - Credenciais: minioadmin/minioadmin
   - Bucket: raw

## Consultando Tabelas Delta Lake

### 1. Navegue até os dados

1. Expanda a fonte "MinIO" no painel lateral
2. Navegue até a pasta onde estão armazenados os dados Delta Lake
3. Clique no conjunto de dados para visualizar uma prévia

### 2. Executar Consultas SQL

1. Clique em "Nova Consulta" no menu superior
2. Digite sua consulta SQL, por exemplo:

```sql
SELECT * FROM MinIO.raw.exemplo_pessoas;
```

3. Clique no botão "Executar" para ver os resultados

## Usando DBeaver (Opcional)

Se preferir usar o DBeaver ou outro cliente SQL, você pode se conectar ao Dremio da seguinte maneira:

1. Adicione uma nova conexão:
   - Tipo: Dremio
   - Host: localhost
   - Port: 9047
   - Username: seu_usuario (criado no primeiro acesso)
   - Catalog: hive
   - Schema: default

2. Configure:
   - SSL: desativado
   - Kerberos: desativado

3. Comandos SQL de exemplo no DBeaver:

```sql
-- Consultar dados
SELECT * FROM MinIO.raw.exemplo_pessoas;

-- Ver estrutura
DESCRIBE MinIO.raw.exemplo_pessoas;
```

## Exemplos de Consultas

```sql
-- Filtrar por condição
SELECT * FROM MinIO.raw.exemplo_pessoas 
WHERE idade > 30;

-- Agregações
SELECT 
  AVG(idade) as media_idade,
  COUNT(*) as total_pessoas
FROM MinIO.raw.exemplo_pessoas;
```