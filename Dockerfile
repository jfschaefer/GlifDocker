# FROM python:3.8-slim
ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER

USER root

RUN pip install --no-cache --upgrade pip
RUN apt-get update 

# Install packages
# nodejs is needed for widgets in jupyter lab
RUN apt-get -y --no-install-recommends install apt-utils \
                                               wget \
                                               libghc-haskeline-dev \
                                               libtinfo5 \
                                               graphviz \
                                               git \
                                               default-jre \
                                               nodejs \
                                               ocaml \
                                               opam \
    && rm -rf /var/lib/apt/lists/*

# GF
RUN wget https://www.grammaticalframework.org/download/gf_3.10-2_amd64.deb && dpkg -i gf_3.10-2_amd64.deb && rm gf_3.10-2_amd64.deb

# MMT
WORKDIR $HOME
USER $NB_UID
RUN wget https://github.com/UniFormal/MMT/releases/download/19.0.0/mmt.jar
RUN echo "\n\n" | java -jar mmt.jar :setup
RUN rm mmt.jar
ENV MMT_PATH="$HOME/MMT/systems/MMT"

# ELPI
USER root
RUN apt-get update
RUN apt-get -y --no-install-recommends install m4
USER $NB_UID
RUN opam init && opam install elpi
# RUN apt-get -y --purge autoremove m4 opam ocaml

# GLIF KERNEL
WORKDIR /tmp
USER $NB_UID
RUN git clone https://github.com/KWARC/GLIF.git
WORKDIR /tmp/GLIF
RUN git checkout devel 
USER root
RUN pip install --no-cache . && \
    python -m glif_kernel.install && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager
#     jupyter labextension install jupyterlab-gf-highlight

# syntax highlighting
WORKDIR /tmp
RUN git clone https://github.com/kaiamann/jupyterlab-gf-highlight.git
WORKDIR /tmp/jupyterlab-gf-highlight
RUN npm install && jupyter labextension link .


USER $NB_UID
WORKDIR $HOME

RUN mv /tmp/GLIF/notebooks $HOME

# a bunch of ports for MMT...
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099

# alternative: pass -e JUPYTER_ENABLE_LAB=yes
ENV JUPYTER_ENABLE_LAB=yes

ENV PATH="${PATH}:/home/jovyan/.opam/system/bin"
