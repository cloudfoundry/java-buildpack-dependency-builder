FROM cloudfoundry/cflinuxfs2

RUN apt-get update && apt-get install -y \
    build-essential \
    file \
    libasound2-dev \
    libcups2-dev \
    libffi-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libxrender-dev \
    libxt-dev \
    libxtst-dev \
    mercurial \
    zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/openjdk-8 \
 && curl -sL https://java-buildpack.cloudfoundry.org/openjdk-jdk/bionic/x86_64/openjdk-1.8.0_202.tar.gz \
    | tar xzvf - -C /opt/openjdk-8

RUN mkdir -p /opt/openjdk-11 \
 && curl -sL https://java-buildpack.cloudfoundry.org/openjdk-jdk/trusty/x86_64/openjdk-11.0.2_09.tar.gz \
    | tar xzvf - -C /opt/openjdk-11
