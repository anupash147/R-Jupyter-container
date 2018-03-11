# Distributed under the terms of the Modified BSD License.
FROM continuumio/miniconda:4.2.12
MAINTAINER Cloud Analytics <anupash147@yahoo.com>


USER root

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.1.0
ENV HADOOP_VERSION 2.7

# Installing java
RUN echo 'deb http://cdn-fastly.deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get -y update && \
    apt-get install --no-install-recommends -t jessie-backports -y openjdk-8-jre-headless ca-certificates-java && \
    rm /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# installing spark 2.1
RUN cd /tmp && \
        wget -q http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
        echo "3fc94096ae34f9a1a148d37e5ed640a7e5de1812f1f2ecd715d92bbf2901e895cf4b93e6d8ee0d64debb5df7c56d673c0a36e5fc49503ec0f4507eb0edf961a4 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

# adding s3 dependencies so that spark can query s3 file system
RUN cd /usr/local/spark/jars; wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar \
                          &&  wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.6.0/hadoop-aws-2.6.0.jar \
                          && apt-get update && echo 'y' | apt-get install libgeos-dev



# Spark config
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip
#ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN echo 'spark.driver.memory              5g' > $SPARK_HOME/conf/spark-defaults.conf

# setting up the system path
COPY environment.yml /tmp/


# conda setting up the environment
RUN cd /tmp && conda env update


# Expose port just incase you would need to use notebook [optional only for debugging]
EXPOSE 8888 4040

################################  R  ####################################
RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties apt-transport-https && \
    apt-get --fix-missing -y install r-base-core r-base-dev littler libgeos-dev libgdal-dev libproj-dev libspatialindex-dev ess jq awscli git

## Sample r package installation
RUN Rscript -e "install.packages('argparser', repos='http://cran.rstudio.com/')"

## gdal support
RUN export CPLUS_INCLUDE_PATH=/usr/include/gdal; export C_INCLUDE_PATH=/usr/include/gdal; pip install GDAL==$(gdal-config --version | awk -F'[.]' '{print $1"."$2}')



################################  R  ####################################

RUN apt-get --fix-missing -y install gdebi-core wget net-tools htop vim

# remove authentication if any time for jupyter notebooks
RUN mkdir /root/.jupyter && printf "\nc.NotebookApp.token = u'' \n\n" >> /root/.jupyter/jupyter_notebook_config.py


# for debugging purposes

RUN adduser --disabled-password --gecos "" rstudio && \
    echo rstudio:rstudio | chpasswd && \
    mkdir /etc/rstudio/ && \
    echo 'server-app-armor-enabled=0' > /etc/rstudio/rserver.conf

# setting utils / entry point script
COPY source/util /util
ENV PYTHONPATH $PYTHONPATH:/util