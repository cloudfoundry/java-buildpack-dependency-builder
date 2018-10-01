FROM cloudfoundry/cflinuxfs3m

RUN mkdir -p /usr/share/man/man1

RUN apt-get update && apt-get install -y \
    build-essential \
    cpio \
    file \
    jq \
    libasound2-dev \
    libcups2-dev \
    libffi-dev \
    libfontconfig1-dev \
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

RUN pip install --upgrade setuptools \
 && pip install awscli urllib3[secure] --ignore-installed six

RUN mkdir -p /opt/openjdk-10 \
 && curl -sL https://java-buildpack.cloudfoundry.org/openjdk-jdk/bionic/x86_64/openjdk-10.0.2_13.tar.gz \
    | tar xzvf - -C /opt/openjdk-10
