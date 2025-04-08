# Metabase

O Metabase é uma ferramenta de visualização de dados open source que permite criar gráficos, dashboards e relatórios a partir de diversas fontes de dados. Neste projeto, o Metabase está configurado para funcionar com o data lake, permitindo visualizar os dados armazenados no MinIO através do Dremio.

## Funcionalidades

- **Painéis Interativos**: Criação de dashboards dinâmicos e interativos
- **Consultas SQL**: Editor de SQL para consultas personalizadas
- **Editor Visual**: Interface intuitiva para criar visualizações sem precisar escrever SQL
- **Agendamento**: Configuração de atualizações automáticas e envio de relatórios
- **Compartilhamento**: Opções para compartilhar dashboards com outros usuários
- **Alertas**: Monitoramento de métricas com alertas configuráveis

## Configuração

O Metabase está configurado para utilizar um banco de dados PostgreSQL para armazenar seus metadados. A configuração é feita através de variáveis de ambiente no arquivo `docker-compose.yml`.

## Acesso

- **URL**: http://localhost:3000
- **Configuração Inicial**: Na primeira execução, você precisará configurar um usuário administrador

## Conectando às Fontes de Dados

### Conectando ao Dremio

O Metabase pode se conectar ao Dremio, que por sua vez tem acesso aos dados no MinIO, através do driver JDBC:

1. Acesse a interface do Metabase: http://localhost:3000
2. Após configuração inicial, vá para Configurações > Admin > Databases
3. Clique em "Add Database"
4. Selecione "Dremio" como o tipo de banco de dados
5. Configure os seguintes parâmetros:
   - Nome: Dremio
   - Host: dremio
   - Porta: 31010
   - Banco de dados: (deixar em branco)
   - Nome de usuário: (seu usuário do Dremio)
   - Senha: (sua senha do Dremio)
6. Clique em "Save" para salvar a conexão

## Criando Visualizações

### Passos para criar um dashboard:

1. Crie uma pergunta (query):
   - Clique em "New" > "Question"
   - Selecione a fonte de dados Dremio
   - Escolha uma tabela ou escreva uma consulta SQL
   - Personalize a visualização (gráfico de barras, linhas, tabela, etc.)
   - Salve a pergunta

2. Crie um dashboard:
   - Clique em "New" > "Dashboard"
   - Dê um nome ao dashboard
   - Adicione as perguntas criadas
   - Organize o layout conforme desejado
   - Salve o dashboard

## Recursos Avançados

- **Filtros**: Adicione filtros interativos aos dashboards
- **Parâmetros**: Crie consultas parametrizadas
- **Mapeamento Geográfico**: Visualize dados em mapas
- **Notificações**: Configure alertas e relatórios automáticos
- **Sincronização**: Mantenha as visualizações atualizadas automaticamente

## Troubleshooting

### Problemas Comuns

1. **Erro de Conexão com o Dremio**:
   - Verifique se o serviço Dremio está em execução
   - Confirme as credenciais de acesso
   - Verifique a conectividade entre os containers

2. **Reset do Metabase**:
   Se precisar reiniciar o Metabase do zero:
   ```bash
   make metabase-reset
   ```
   Este comando remove o banco de dados do Metabase e reinicia os containers.

3. **Visualização dos Logs**:
   ```bash
   make logs-metabase
   ```

## Integração com o Fluxo de Dados

O Metabase se integra ao data lake da seguinte forma:

1. Dados são armazenados no MinIO
2. O Spark processa esses dados e os organiza 
3. O Dremio fornece uma camada de acesso SQL a esses dados
4. O Metabase se conecta ao Dremio para visualizar os dados

Este fluxo permite que você armazene dados brutos no MinIO, processe-os com Spark, e os visualize através do Metabase, completando o ciclo de engenharia de dados.
