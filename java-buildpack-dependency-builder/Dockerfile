FROM alpine:latest

RUN apk add --no-cache --update \
    bash \
    coreutils \
    curl \
    jq \
    py2-pip \
    unzip

RUN pip install awscli --ignore-installed six
