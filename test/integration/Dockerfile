FROM debian:jessie

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        iptables \
        ca-certificates \
        lxc \
        apt-transport-https \
        git \
        wget \
        curl \
        python \
        build-essential \
        make \
        ruby \
        ruby-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Docker
ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.11.1
ENV DOCKER_SHA256 893e3c6e89c0cd2c5f1e51ea41bc2dd97f5e791fcfa3cee28445df277836339d
RUN set -x && \
    curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o docker.tgz && \
    echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - && \
    tar -xzvf docker.tgz && \
    mv docker/* /usr/local/bin/ && \
    rmdir docker && \
    rm docker.tgz && \
    docker -v

# Install Docker Compose
ENV DOCKER_COMPOSE_VERSION 1.7.1
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install Travis CI Gem
ENV TRAVIS_CI_VERSION 1.8.3.travis.745.4
RUN gem install travis -v "${TRAVIS_CI_VERSION}" --no-rdoc --no-ri

# Install BATS (Bash Automated Testing System)
RUN mkdir /install && \
    cd /install && \
    git clone https://github.com/sstephenson/bats.git && \
    cd bats && \
    git checkout v0.4.0 && \
    ./install.sh /usr/local

VOLUME /src
VOLUME /app
WORKDIR /app

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
