FROM cloudfoundry/cflinuxfs3m

RUN mkdir -p /usr/share/man/man1

RUN apt-get install -y \
    build-essential \
    cmake \
    curl \
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

RUN pip install awscli --ignore-installed six
