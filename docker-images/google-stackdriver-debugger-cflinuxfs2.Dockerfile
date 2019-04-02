FROM cloudfoundry/cflinuxfs2

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    gcc \
    jq \
    libssl-dev \
    maven \
    openjdk-7-jdk \
    python \
    python-dev \
    python-pip \
    unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install awscli --ignore-installed six
