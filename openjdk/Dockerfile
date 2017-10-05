FROM openjdk:8-jdk

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
    python-pip \
    zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install awscli --ignore-installed six
