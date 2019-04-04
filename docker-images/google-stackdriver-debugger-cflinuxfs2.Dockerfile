FROM cloudfoundry/cflinuxfs2

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    gcc \
    libssl-dev \
    maven \
    openjdk-7-jdk \
    python \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
