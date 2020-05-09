FROM jupyter/base-notebook

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
                                               gcc \
                                               make \
                                               markdown \
    && rm -rf /var/lib/apt/lists/*

# GF
RUN wget https://www.grammaticalframework.org/download/gf_3.10-2_amd64.deb && dpkg -i gf_3.10-2_amd64.deb && rm gf_3.10-2_amd64.deb

# MMT
WORKDIR $HOME
USER $NB_UID
# RUN wget https://github.com/UniFormal/MMT/releases/download/19.0.0/mmt.jar
RUN wget https://github.com/jfschaefer/JupyterGlifDemo/raw/master/mmt.jar \
    && echo "\n\n" | java -jar mmt.jar :setup \
    && rm mmt.jar \
    && java -jar MMT/systems/MMT/deploy/mmt.jar lmh install \
    && mkdir $HOME/MMT/MMT-content/COMMA
ENV MMT_PATH="$HOME/MMT/systems/MMT"
WORKDIR $HOME/MMT/MMT-content/COMMA
RUN git clone https://gl.mathhub.info/COMMA/glforthel.git && git clone https://gl.mathhub.info/COMMA/GLF.git

# ELPI
USER root
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/ocaml/ocaml.git \
    && cd ocaml \
    &&  ./configure && make && make install \
    && cd .. && rm -rf ocaml
RUN wget https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh \
    && echo "\n" | sh install.sh
RUN apt-get update && apt-get -y --no-install-recommends install m4 bubblewrap patch unzip \
    && rm -rf /var/lib/apt/lists/*
USER $NB_UID
RUN opam init --disable-sandboxing --auto-setup && opam update && opam install --yes elpi \
    && rm -rf ${HOME}/.opam/default/lib ${HOME}/.opam/default/.opam-switch ${HOME}/.opam/repo
ENV PATH="${PATH}:/home/jovyan/.opam/default/bin"
USER root
RUN apt-get -y --purge autoremove gcc make

# GLIF KERNEL
WORKDIR /tmp
USER $NB_UID
RUN git clone https://github.com/KWARC/GLIF.git
WORKDIR /tmp/GLIF
# RUN git checkout devel 
USER root
RUN pip install --no-cache . && \
    python -m glif_kernel.install && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager
#     jupyter labextension install jupyterlab-gf-highlight

# syntax highlighting
WORKDIR /tmp
RUN git clone https://github.com/kaiamann/jupyterlab-gf-highlight.git
WORKDIR /tmp/jupyterlab-gf-highlight
RUN npm install && jupyter labextension link . \
    && rm -rf /usr/local/share/.cache

USER $NB_UID
WORKDIR $HOME

RUN mv /tmp/GLIF/notebooks $HOME && markdown notebooks/README.md > notebooks/README.html && wget https://github.com/jfschaefer/GlifDocker/raw/master/Welcome.txt && rm -r work

# a bunch of ports for MMT...
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099 8100 8101 8102 8103 8104 8105 8106 8107 8108 8109 8110 8111 8112 8113 8114 8115 8116 8117 8118 8119

# alternative: pass -e JUPYTER_ENABLE_LAB=yes
ENV JUPYTER_ENABLE_LAB=yes
