FROM bitnami/spark:3.3.0

# Instala dependências necessárias
USER root
RUN apt-get update && apt-get install -y \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Instala dependências Python
RUN pip3 install --no-cache-dir \
    delta-spark==2.3.0 \
    jupyter \
    pandas \
    numpy

# Baixa e instala os JARs do Delta Lake
RUN mkdir -p /opt/bitnami/spark/jars && \
    cd /opt/bitnami/spark/jars && \
    wget https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.3.0/delta-core_2.12-2.3.0.jar && \
    wget https://repo1.maven.org/maven2/io/delta/delta-storage/2.3.0/delta-storage-2.3.0.jar

# Configura variáveis de ambiente
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook --allow-root --ip=0.0.0.0 --port=8888"
ENV SPARK_HOME=/opt/bitnami/spark
ENV HADOOP_HOME=/opt/bitnami/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin

# Cria diretório para notebooks
RUN mkdir /notebooks
WORKDIR /notebooks

# Expõe portas
EXPOSE 8888 4040

# Comando para iniciar o Jupyter Notebook
CMD ["jupyter", "notebook", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.token=''"]