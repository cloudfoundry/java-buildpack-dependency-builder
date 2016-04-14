FROM alpine:latest

RUN apk add --update \
    bash \
    coreutils \
    curl \
    jq \
    py-pip \
    unzip \
 && rm -rf /var/cache/apk/*

RUN pip install awscli --ignore-installed six
