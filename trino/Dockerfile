FROM trinodb/trino:423

# Copia os arquivos de configuração
COPY trino/etc/ /etc/trino/

# Expõe a porta do Trino
EXPOSE 8080

# Comando para iniciar o Trino
CMD ["/usr/lib/trino/bin/run-trino"] 