FROM ubuntu:15.10

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

# proper init
ADD https://github.com/krallin/tini/releases/download/v0.8.4/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install \
        iptables \
        ca-certificates \
        lxc \
        apt-transport-https \
        git \
        wget \
        curl \
        python3.4 \
        gcc \
        make \
        ruby \
        ruby-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8 && /usr/sbin/update-locale LANG=en_US.UTF-8
RUN gem install travis -v "1.8.1.travis.713.4" --no-rdoc --no-ri

RUN curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker*

RUN mkdir /install && \
    cd /install && \
    git clone https://github.com/sstephenson/bats.git && \
    cd bats && \
    git checkout v0.4.0 && \
    ./install.sh /usr/local

VOLUME /src
VOLUME /app
WORKDIR /app
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

CMD ["run.sh"]
