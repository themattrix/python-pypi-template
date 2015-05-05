FROM krallin/ubuntu-tini:14.04

MAINTAINER Matthew Tardiff <mattrix@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y install \
       iptables ca-certificates lxc apt-transport-https \
       git wget python3.4 ruby2.0 ruby2.0-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8 && /usr/sbin/update-locale LANG=en_US.UTF-8
RUN gem2.0 install travis -v 1.7.6 --no-rdoc --no-ri

RUN wget -O /usr/local/bin/docker \
        https://get.docker.com/builds/Linux/x86_64/docker-1.6.0 \
    && chmod +x /usr/local/bin/docker

RUN wget -O /usr/local/bin/docker-compose \
        https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` \
    && chmod +x /usr/local/bin/docker-compose

ADD . /app/
WORKDIR /app
RUN chmod +x test/impl/integration/tests.sh

CMD ["test/impl/integration/tests.sh"]
