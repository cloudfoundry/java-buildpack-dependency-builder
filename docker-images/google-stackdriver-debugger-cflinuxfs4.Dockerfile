ARG base_image=cloudfoundry/cflinuxfs4
FROM ${base_image}

RUN mkdir -p /usr/share/man/man1

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    gcc \
    libssl-dev \
    maven \
    openjdk-8-jdk \
    python \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN update-java-alternatives -s java-1.8.0-openjdk-amd64
