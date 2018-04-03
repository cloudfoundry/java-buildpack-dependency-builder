FROM cloudfoundry/cflinuxfs2

RUN apt-get update && apt-get install -y \
    python-software-properties \
    software-properties-common \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:openjdk-r/ppa

RUN apt-get update && apt-get install -y \
    build-essential \
    cpio \
    file \
    jq \
    libasound2-dev \
    libcups2-dev \
    libfreetype6-dev \
    libxext-dev \
    libxrender-dev \
    libxt-dev \
    libxtst-dev \
    mercurial \
    openjdk-8-jdk \
    python-dev \
    python-pip \
    zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install awscli --ignore-installed six

RUN mkdir -p /opt/openjdk-9 \
 && curl -sL https://java-buildpack.cloudfoundry.org/openjdk-jdk/trusty/x86_64/openjdk-9.0.4_11.tar.gz \
    | tar xzvf - -C /opt/openjdk-9
