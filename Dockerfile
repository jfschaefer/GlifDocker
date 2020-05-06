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
    && rm -rf /var/lib/apt/lists/*

# GF
RUN wget https://www.grammaticalframework.org/download/gf_3.10-2_amd64.deb && dpkg -i gf_3.10-2_amd64.deb && rm gf_3.10-2_amd64.deb

# MMT
WORKDIR $HOME
USER $NB_UID
# RUN wget https://github.com/UniFormal/MMT/releases/download/19.0.0/mmt.jar
RUN wget https://github.com/jfschaefer/JupyterGlifDemo/raw/master/mmt.jar
RUN echo "\n\n" | java -jar mmt.jar :setup
RUN rm mmt.jar
ENV MMT_PATH="$HOME/MMT/systems/MMT"
RUN java -jar MMT/systems/MMT/deploy/mmt.jar lmh install COMMA/GLF COMMA/forthel
# glforthel

# ELPI
USER root
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/ocaml/ocaml.git
WORKDIR /tmp/ocaml
RUN apt-get update
run apt-get -y --no-install-recommends install make
RUN ./configure && make && make install
RUN wget https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh 
RUN echo "\n" | sh install.sh
RUN apt-get -y --no-install-recommends install m4
RUN apt-get -y --no-install-recommends install bubblewrap
RUN apt-get -y --no-install-recommends install patch unzip
# RUN sysctl kernel.unprivileged_userns_clone=1
# RUN chmod u+s /usr/bin/bwrap
USER $NB_UID
RUN opam init --disable-sandboxing --auto-setup
RUN opam update 
Run opam install --yes elpi
ENV PATH="${PATH}:/home/jovyan/.opam/system/bin"
USER root

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

# run apt-get -y install opam
# RUN sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
USER $NB_UID
WORKDIR $HOME

ENV PATH="${PATH}:/home/jovyan/.opam/default/bin"
