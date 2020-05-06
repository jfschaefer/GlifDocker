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
RUN java -jar MMT/systems/MMT/deploy/mmt.jar lmh install
RUN mkdir $HOME/MMT/MMT-content/COMMA
WORKDIR $HOME/MMT/MMT-content/COMMA
RUN git clone https://gl.mathhub.info/COMMA/glforthel.git && git clone https://gl.mathhub.info/COMMA/GLF.git

# ELPI
USER root
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/ocaml/ocaml.git
WORKDIR /tmp/ocaml
RUN ./configure && make && make install
WORKDIR /tmp
RUN rm -rf ocaml
RUN wget https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh 
RUN echo "\n" | sh install.sh
RUN apt-get update && apt-get -y --no-install-recommends install m4 bubblewrap patch unzip
USER $NB_UID
RUN opam init --disable-sandboxing --auto-setup && opam update && opam install --yes elpi
ENV PATH="${PATH}:/home/jovyan/.opam/default/bin"
RUN rm -rf ${HOME}/.opam/default/lib ${HOME}/.opam/default/.opam-switch ${HOME}/.opam/repo

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
RUN npm install && jupyter labextension link .

# some more cleanup
RUN apt-get -y --purge autoremove gcc make
RUN rm -rf /usr/local/share/.cache

USER $NB_UID
WORKDIR $HOME

RUN mv /tmp/GLIF/notebooks $HOME

# a bunch of ports for MMT...
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099

# alternative: pass -e JUPYTER_ENABLE_LAB=yes
ENV JUPYTER_ENABLE_LAB=yes

WORKDIR $HOME

