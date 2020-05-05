# FROM python:3.8-slim
ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER

USER root

RUN pip install --no-cache --upgrade pip
RUN apt-get update 

# Install packages
RUN apt-get -y --no-install-recommends install apt-utils
RUN apt-get -y --no-install-recommends install wget
RUN apt-get -y --no-install-recommends install libghc-haskeline-dev
RUN apt-get -y --no-install-recommends install libtinfo5
RUN apt-get -y --no-install-recommends install graphviz
RUN apt-get -y --no-install-recommends install git

# GF
RUN wget https://www.grammaticalframework.org/download/gf_3.10-2_amd64.deb
RUN dpkg -i gf_3.10-2_amd64.deb

# GLIF
WORKDIR /tmp
RUN git clone https://github.com/KWARC/GLIF.git
WORKDIR /tmp/GLIF
RUN git checkout devel
RUN pip install --no-cache .
RUN python -m glif_kernel.install

# RUN apt-get -y --no-install-recommends install default-jre
# RUN apt-get -y --no-install-recommends install unzip

RUN rm -rf /var/lib/apt/lists/*

USER $NB_UID
WORKDIR $HOME

# alternative: pass -e JUPYTER_ENABLE_LAB=yes
ENV JUPYTER_ENABLE_LAB=yes
