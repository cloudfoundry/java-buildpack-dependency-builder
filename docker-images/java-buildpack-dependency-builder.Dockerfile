ARG base_image=ubuntu:bionic
FROM ${base_image}

RUN apt-get update && apt-get install --no-install-recommends -y \
    jq \
    unzip \
 && rm -rf /var/lib/apt/lists/*
