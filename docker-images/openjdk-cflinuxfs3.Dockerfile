FROM cloudfoundry/cflinuxfs3

RUN mkdir -p /usr/share/man/man1

RUN apt-get update && apt-get install -y \
    build-essential \
    file \
    libasound2-dev \
    libcups2-dev \
    libffi-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libxrender-dev \
    libxt-dev \
    libxtst-dev \
    python-pip \
    zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get remove -y mercurial \
 && apt-get autoremove -y \
 && pip2 install mercurial

RUN mkdir -p /opt/openjdk-8 \
 && curl -sL https://java-buildpack.cloudfoundry.org/openjdk-jdk/bionic/x86_64/openjdk-jdk-1.8.0_222-bionic.tar.gz \
    | tar xzvf - -C /opt/openjdk-8

RUN mkdir -p /opt/openjdk-11 \
 && curl -sL https://java-buildpack.cloudfoundry.org/openjdk-jdk/bionic/x86_64/openjdk-jdk-11.0.4_11-bionic.tar.gz \
    | tar xzvf - -C /opt/openjdk-11
