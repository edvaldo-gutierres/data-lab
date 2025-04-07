# Guia de Configuração

Este documento fornece instruções sobre como configurar o ambiente do Data Lake.

> **Nota**: Como este projeto utiliza Docker, todas as configurações já estão definidas nos arquivos Docker Compose e Dockerfile. Não é necessário configurar manualmente os serviços.

## Configuração do Ambiente Docker

O ambiente Docker já está pré-configurado e pronto para uso. Caso precise personalizar alguma configuração, você pode editar os seguintes arquivos:

- `docker-compose.yml`: Configurações dos serviços Docker
- `Dockerfile`: Configurações específicas para construção das imagens
- `.env` (opcional): Variáveis de ambiente personalizadas

## Configuração de Serviços Docker

O projeto utiliza o Docker Compose para gerenciar seus serviços. Aqui estão os detalhes de configuração para cada serviço, que já vêm pré-configurados:

### MinIO
- **Imagem**: `minio/minio`
- **Portas**: 9000 e 9001
- **Variáveis de Ambiente**:
  - `MINIO_ROOT_USER`: Usuário root do MinIO (padrão: minioadmin)
  - `MINIO_ROOT_PASSWORD`: Senha root do MinIO (padrão: minioadmin)
- **Comando**: `server /data --console-address ":9001"`
- **Volumes**: Monta o diretório local `./data` no contêiner

### Spark
- **Imagem**: `my-spark`
- **Portas**: 8888 e 4040
- **Volumes**: Monta o diretório local `./notebooks` no contêiner
- **Dependências**: Depende do serviço MinIO

### Dremio
- **Imagem**: `dremio/dremio-oss`
- **Porta**: 9047
- **Dependências**: Depende dos serviços MinIO e Hive Metastore

### MariaDB
- **Imagem**: `mariadb:10.5`
- **Variáveis de Ambiente**:
  - `MYSQL_ROOT_PASSWORD`: Senha root do MariaDB
  - `MYSQL_USER`: Usuário do banco de dados
  - `MYSQL_PASSWORD`: Senha do banco de dados
  - `MYSQL_DATABASE`: Nome do banco de dados
- **Healthcheck**: Verifica a saúde do serviço

### Hive Metastore
- **Build**: Usa o Dockerfile no diretório `./hive`
- **Variáveis de Ambiente**:
  - `MYSQL_HOST`: Host do MariaDB
  - `MYSQL_PORT`: Porta do MariaDB
  - `MYSQL_USER`: Usuário do banco de dados
  - `MYSQL_PASSWORD`: Senha do banco de dados
  - `MYSQL_DATABASE`: Nome do banco de dados
- **Volumes**: Monta diretórios locais para logs e warehouse
- **Porta**: 9083
- **Dependências**: Depende do serviço MariaDB (condição de saúde)

### Rede
- **datalake-network**: Rede externa usada por todos os serviços.

## Personalizações Avançadas

Se você precisar personalizar alguma configuração específica:

1. **Alterando Portas**: Edite as portas no arquivo `docker-compose.yml` se houver conflitos com outros serviços em sua máquina.

2. **Alterando Credenciais**: Se desejar alterar credenciais padrão, modifique as variáveis de ambiente no arquivo `docker-compose.yml`.

3. **Ajustes de Memória/CPU**: Se precisar alocar mais recursos para algum serviço, edite as configurações de recursos no `docker-compose.yml`.

4. **Volumes Persistentes**: Os dados são persistidos em volumes Docker. Se precisar alterar os caminhos de montagem, modifique as seções `volumes` no `docker-compose.yml`.

Todos estes ajustes são opcionais. Para a maioria dos casos de uso, a configuração padrão é suficiente.
