# OpenMetadata

OpenMetadata é uma plataforma de gestão de metadados que proporciona descoberta, governança e observabilidade para dados. É a camada que ajuda a entender e organizar os ativos de dados do Data Lake.

## Funcionalidades

- **Catálogo de Dados**: Indexação e pesquisa de todos os ativos de dados
- **Linhagem**: Rastreamento da origem e transformações dos dados
- **Governança**: Políticas de acesso, qualidade e classificação de dados
- **Observabilidade**: Monitoramento da qualidade e uso dos dados
- **Metadados Técnicos**: Esquemas, estatísticas e perfis de dados

## Configuração

No Data Lake, o OpenMetadata é executado em contêineres Docker com a seguinte configuração:

- **Porta da interface web**: 8585
- **Banco de dados**: MySQL
- **Integração com Airflow**: Para extração de metadados e linhagem

## Acesso

A interface web do OpenMetadata pode ser acessada em:

- **URL**: http://localhost:8585
- **Usuário padrão**: admin
- **Senha padrão**: admin

## Utilizando o OpenMetadata

### Descoberta de Dados

1. **Navegação pelo Catálogo**:
   - Acesse a interface web do OpenMetadata
   - Utilize a pesquisa para encontrar tabelas, tópicos ou dashboards
   - Explore as categorias e filtros disponíveis

2. **Visualização de Detalhes**:
   - Clique em um ativo para ver seus detalhes
   - Consulte schema, estatísticas e amostras de dados
   - Veja a linhagem e dependências

### Governança de Dados

1. **Adicionando Descrições**:
   - Selecione um ativo de dados
   - Adicione descrições no nível da tabela, colunas ou tópicos
   - Utilize o formato markdown para formatação

2. **Adicionando Tags e Classificações**:
   - Aplique tags para categorizar os dados
   - Adicione classificações de segurança (PII, confidencial, etc.)
   - Configure políticas de acesso baseadas em classificações

### Qualidade de Dados

1. **Definindo Testes**:
   - Configure testes de qualidade para suas tabelas
   - Exemplos: não-nulo, unicidade, intervalo de valores
   - Defina a frequência de execução dos testes

2. **Monitorando Resultados**:
   - Visualize os resultados dos testes na aba "Data Quality"
   - Configure alertas para falhas de qualidade
   - Acompanhe tendências ao longo do tempo

## Integrando com Outros Serviços

### Conectando ao MinIO/S3

1. No menu, acesse "Settings" > "Services" > "Add New Service"
2. Selecione "S3" como tipo de serviço
3. Configure:
   - Nome: `minio-datalake`
   - Endpoint: `http://minio:9000`
   - Access Key e Secret Key: `minioadmin`
   - Região: deixe em branco
   - Bucket: `raw`
4. Teste a conexão e salve

### Conectando ao Dremio

1. No menu, acesse "Settings" > "Services" > "Add New Service"
2. Selecione "Dremio" como tipo de serviço
3. Configure:
   - Nome: `dremio-service`
   - Host e porta: `dremio:9047`
   - Autenticação: Básica com usuário e senha
4. Teste a conexão e salve

### Extraindo Metadados do Hive

1. No menu, acesse "Settings" > "Services" > "Add New Service"
2. Selecione "Hive" como tipo de serviço
3. Configure:
   - Nome: `hive-metastore`
   - Metastore Host: `hive-metastore`
   - Porta: `9083`
4. Teste a conexão e salve

## Fluxo de Trabalho de Metadados

O OpenMetadata pode ser usado para estabelecer um fluxo completo de trabalho de metadados:

1. **Ingestão**: Extrair metadados de fontes como Dremio, MinIO e Hive
2. **Catalogação**: Organizar e categorizar os dados
3. **Governança**: Aplicar políticas e controles
4. **Qualidade**: Monitorar a qualidade dos dados
5. **Observabilidade**: Acompanhar o uso e a performance

## Problemas Comuns

- **Falha na Conexão**: Verifique as configurações de host e credenciais
- **Metadados Incompletos**: Certifique-se que o serviço tem permissões adequadas
- **Interface Lenta**: Verifique a alocação de recursos para o contêiner

## Comandos Úteis

```bash
# Ver logs do OpenMetadata
make logs-openmetadata

# Acessar o container do OpenMetadata
docker exec -it data-lab-openmetadata-1 bash
```

## Recursos Adicionais

- [Documentação Oficial do OpenMetadata](https://docs.open-metadata.org/)
- [Guia de Ingestão de Metadados](https://docs.open-metadata.org/connectors)
- [Tutoriais de Governança de Dados](https://docs.open-metadata.org/how-to-guides/guide-to-data-governance) 