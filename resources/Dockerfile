ARG base_image=ubuntu:bionic
FROM ${base_image}

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY check /opt/resource/check
COPY in    /opt/resource/in
COPY out   /opt/resource/out
