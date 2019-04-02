FROM ubuntu:bionic

RUN apt-get update && apt-get install --no-install-recommends -y \
    unzip \
 && rm -rf /var/lib/apt/lists/*
