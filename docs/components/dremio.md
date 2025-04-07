# Dremio

Dremio é uma plataforma de análise de dados que permite consultas SQL distribuídas em várias fontes de dados. Ele é projetado para fornecer desempenho rápido e fácil acesso a dados em data lakes.

## Funcionalidades

- **Consultas SQL Distribuídas**: Permite executar consultas SQL em tempo real em grandes volumes de dados.
- **Integração com Múltiplas Fontes de Dados**: Suporta integração com S3, HDFS, MinIO, entre outros.
- **Interface de Usuário Intuitiva**: Oferece uma interface web para explorar e consultar dados facilmente.

## Configuração

Dremio é configurado através de arquivos de configuração e variáveis de ambiente. No contexto deste projeto, ele é executado em um container Docker com as seguintes configurações principais:

- **Porta**: 9047

## Acesso

A interface web do Dremio pode ser acessada através do seguinte endereço:

- **URL**: http://localhost:9047

## Comandos Úteis

- **Verificar Logs**:
  ```bash
  docker logs data-lab-dremio-1
  ```

## Problemas Comuns

- **Falha ao Iniciar**: Verifique se as portas necessárias estão livres e se as configurações estão corretas.
- **Erros de Conexão**: Certifique-se de que o Dremio está em execução e acessível na rede. 