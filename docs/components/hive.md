# Hive Metastore

O Hive Metastore é um componente crítico no ecossistema de data lakes, responsável pelo gerenciamento de metadados para tabelas de dados. Ele permite que ferramentas como Apache Spark e Dremio acessem e manipulem dados de forma eficiente.

## Funcionalidades

- **Gerenciamento de Metadados**: Armazena informações sobre esquemas de tabelas, colunas, tipos de dados e partições.
- **Compatibilidade**: Suporta integração com várias ferramentas de processamento de dados, como Spark e Dremio.
- **Transações ACID**: Oferece suporte a transações ACID para garantir a consistência dos dados.

## Configuração

O Hive Metastore é configurado para usar o MariaDB como seu banco de dados subjacente. As configurações principais estão localizadas no arquivo `hive-site.xml`.

## Acesso

O Hive Metastore pode ser acessado via API Thrift, que é usada internamente por ferramentas como Spark e Dremio para interagir com os metadados.

## Comandos Úteis

- **Acessar o Metastore via Beeline**:
  ```bash
  docker exec -it data-lab-hive-metastore-1 beeline -u jdbc:hive2://localhost:10000
  ```

- **Verificar Logs**:
  ```bash
  docker logs data-lab-hive-metastore-1
  ```

## Problemas Comuns

- **Falha ao Iniciar**: Verifique os logs do MariaDB e as configurações no `hive-site.xml`.
- **Conexão com o Banco de Dados**: Certifique-se de que o MariaDB está em execução e acessível.
