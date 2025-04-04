FROM openjdk:8-slim

# Instala dependências
RUN apt-get update && apt-get install -y \
    wget \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Define variáveis de ambiente
ENV HADOOP_VERSION=3.2.0
ENV HIVE_VERSION=3.1.3
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive

# Baixa e instala Hadoop
RUN wget --no-check-certificate https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Baixa e instala Hive
RUN wget --no-check-certificate https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Adiciona MySQL JDBC driver
RUN wget --no-check-certificate https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar \
    -O ${HIVE_HOME}/lib/mysql-connector-java.jar

# Configura variáveis de ambiente
ENV PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin
ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/*

# Cria diretórios necessários
RUN mkdir -p /opt/hive/logs /opt/hive/warehouse

# Copia arquivos de configuração
COPY hive-site.xml ${HIVE_HOME}/conf/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9083

ENTRYPOINT ["/entrypoint.sh"] 