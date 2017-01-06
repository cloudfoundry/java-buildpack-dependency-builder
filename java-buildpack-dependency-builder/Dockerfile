FROM alpine:latest

RUN apk add --update \
    bash \
    coreutils \
    curl \
    jq \
    py2-pip \
    unzip \
 && rm -rf /var/cache/apk/*

RUN pip install awscli --ignore-installed six
