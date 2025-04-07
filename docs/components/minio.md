# MinIO

MinIO é uma solução de armazenamento de objetos compatível com S3, projetada para fornecer armazenamento de dados de alta performance e escalabilidade. Ele é ideal para data lakes e ambientes de big data.

## Funcionalidades

- **Compatibilidade com S3**: MinIO suporta a API S3, permitindo integração com ferramentas e aplicações que utilizam o protocolo S3.
- **Alta Disponibilidade**: Suporte para configuração em cluster, garantindo alta disponibilidade e resiliência.
- **Segurança**: Oferece criptografia de dados em repouso e em trânsito.

## Configuração

MinIO é configurado através de variáveis de ambiente e arquivos de configuração. No contexto deste projeto, ele é executado em um container Docker com as seguintes credenciais padrão:

- **Usuário**: minioadmin
- **Senha**: minioadmin

## Acesso

O console web do MinIO pode ser acessado através do seguinte endereço:

- **URL**: http://localhost:9001

## Comandos Úteis

- **Verificar Logs**:
  ```bash
  docker logs data-lab-minio-1
  ```

- **Listar Buckets**:
  ```bash
  aws s3 --endpoint-url http://localhost:9000 ls
  ```

## Problemas Comuns

- **Falha ao Iniciar**: Verifique se as portas necessárias estão livres e se as credenciais estão corretas.
- **Conexão Recusada**: Certifique-se de que o MinIO está em execução e acessível na rede.
