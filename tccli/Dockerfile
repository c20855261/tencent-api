FROM python:3.9-slim-bullseye

MAINTAINER Ayo twops@twprotech.com

ENV TZ=Asia/Shanghai
RUN set -ex \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && echo "alias ll='ls -l'" >> ~/.bashrc

RUN apt-get update -y && \
    apt-get install -y vim jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN pip install tccli

CMD ["tail", "-f", "/dev/null"]
