# Apache Spark

Apache Spark é um framework de processamento de dados em larga escala, projetado para executar rapidamente tarefas de análise de dados em clusters distribuídos. Ele é amplamente utilizado em data lakes para processamento de grandes volumes de dados.

## Funcionalidades

- **Processamento em Lote e Streaming**: Suporte para processamento de dados em tempo real e em lote.
- **Compatibilidade com Várias Fontes de Dados**: Integração com HDFS, S3, MinIO, entre outros.
- **API Unificada**: Oferece APIs em Scala, Java, Python e R.

## Configuração

O Apache Spark é configurado através de arquivos de configuração e variáveis de ambiente. No contexto deste projeto, ele é executado em um container Docker com as seguintes configurações principais:

- **Versão**: 3.3.0
- **Portas**: 8888 (Jupyter), 4040 (UI)

## Acesso

A interface web do Spark pode ser acessada através do seguinte endereço:

- **URL**: http://localhost:4040

## Comandos Úteis

- **Verificar Logs**:
  ```bash
  docker logs data-lab-spark-1
  ```

- **Submeter Aplicações**:
  ```bash
  spark-submit --master local[4] app.py
  ```

## Problemas Comuns

- **Falha ao Iniciar**: Verifique se as portas necessárias estão livres e se as configurações estão corretas.
- **Erros de Conexão**: Certifique-se de que o Spark está em execução e acessível na rede.
