#!/bin/bash

# Configura o ambiente
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive
export PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin

# Aguarda o MySQL estar pronto
until nc -z mariadb 3306; do
  echo "Aguardando MySQL..."
  sleep 2
done

# Inicializa o schema se necessário
if [ "${SKIP_SCHEMA_INIT}" != "true" ]; then
  echo "Inicializando schema do Hive..."
  schematool -dbType mysql -initSchema
fi

# Inicia o Hive Metastore
echo "Iniciando Hive Metastore..."
hive --service metastore 