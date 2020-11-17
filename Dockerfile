ARG BASE_IMAGE=rstudio/r-base
FROM ${BASE_IMAGE}:xenial

LABEL org.label-schema.license="GPL-2.0"

MAINTAINER Harish <ramani.h@northeastern.edu>

ARG R_VERSION=3.6.3
ARG OS_IDENTIFIER=ubuntu-1604

# Install R
RUN wget https://cdn.rstudio.com/r/${OS_IDENTIFIER}/pkgs/r-${R_VERSION}_1_amd64.deb && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb && \
    ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \
    ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \
    rm r-${R_VERSION}_1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y libssl-dev libxml2-dev

# Install R-dependencies for CDT package.
RUN Rscript -e 'install.packages(c("curl","V8", "usethis", "sfsmisc", "clue", "randomForest", "lattice", "MASS", "sparsebn", "BiocManager"),repos="http://cran.us.r-project.org", quiet=FALSE, verbose=FALSE)'
RUN Rscript -e 'BiocManager::install(c("CAM", "SID", "bnlearn", "pcalg", "kpcalg", "D2C"))'
RUN Rscript -e 'install.packages("usethis", repos="http://cran.us.r-project.org", quiet=FALSE, verbose=FALSE)'
RUN Rscript -e 'library(usethis); browse_github_pat(scopes = c("repo", "gist"), description = "R:GITHUB_PAT", host = "https://github.com")'
RUN Rscript -e 'install.packages("devtools", repos="http://cran.us.r-project.org", quiet=FALSE, verbose=FALSE)'
RUN Rscript -e 'devtools::install_github("cran/CAM"); devtools::install_github("cran/momentchi2"); devtools::install_github("Diviyan-Kalainathan/RCIT", quiet=TRUE, verbose=FALSE)'
#Install python and pip

RUN apt-get install -y build-essential zlib1g-dev \
    libncurses5-dev libgdbm-dev libnss3-dev libssl-dev \
    libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev

RUN apt-get update && apt-get install -y \
        software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y \
        python3.7 \
        python3.7-dev \
        python-pip \
        python3-pip
RUN pip3 install --upgrade pip==19.3.1
RUN apt-get update && apt-get install -y libpq-dev &&\
    pip install wheel &&\
    pip install setuptools
COPY . /build
WORKDIR /build
RUN python3.7 -m pip install -r dependencies.txt

