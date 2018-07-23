FROM cloudfoundry/cflinuxfs3m

RUN mkdir -p /usr/share/man/man1

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    docker-ce \
    gcc \
    jq \
    libssl-dev \
    maven \
    openjdk-8-jdk \
    python \
    python-dev \
    python-pip \
    unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

RUN pip install awscli --ignore-installed six
