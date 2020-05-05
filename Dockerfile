# FROM python:3.8-slim
ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER

USER root

RUN pip install --no-cache --upgrade pip
RUN apt-get update 

# Install packages
RUN apt-get -y --no-install-recommends install apt-utils \
                                               wget \
                                               libghc-haskeline-dev \
                                               libtinfo5 \
                                               graphviz \
                                               git \
                                               default-jre \
    && rm -rf /var/lib/apt/lists/*

# GF
RUN wget https://www.grammaticalframework.org/download/gf_3.10-2_amd64.deb && dpkg -i gf_3.10-2_amd64.deb && rm gf_3.10-2_amd64.deb

# GLIF KERNEL
WORKDIR /tmp
USER $NB_UID
RUN git clone https://github.com/KWARC/GLIF.git
WORKDIR /tmp/GLIF
RUN git checkout devel 
USER root
RUN pip install --no-cache . && python -m glif_kernel.install

# MMT

WORKDIR $HOME
USER $NB_UID
RUN wget https://github.com/UniFormal/MMT/releases/download/19.0.0/mmt.jar
RUN echo "\n\n" | java -jar mmt.jar :setup
ENV MMT_PATH="$HOME/MMT/systems/MMT"


USER $NB_UID
WORKDIR $HOME

RUN mv /tmp/GLIF/notebooks $HOME

# a bunch of ports for MMT...
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099

# alternative: pass -e JUPYTER_ENABLE_LAB=yes
ENV JUPYTER_ENABLE_LAB=yes
