FROM cloudfoundry/cflinuxfs3

RUN mkdir -p /usr/share/man/man1

RUN apt-get update && apt-get install -y \
    golang \
    maven \
    openjdk-8-jdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN update-java-alternatives -s java-1.8.0-openjdk-amd64
