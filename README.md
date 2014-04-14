# Java Buildpack Dependency Builders
[![Build Status](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder.svg?branch=master)](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder)
[![Dependency Status](https://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder.svg)](https://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder)
[![Code Climate](https://codeclimate.com/repos/52b84ef86956807cc400133a/badges/b442d613a128726bcbe8/gpa.svg)](https://codeclimate.com/repos/52b84ef86956807cc400133a/feed)

This project automates the building and publication of Java Buildpack dependency artifacts.

## Replicating Repository
To host the Java Buildpack dependency artifacts on your own server, first download the artifacts and `index.yml` files as described below, make them available at suitable locations on a web server, and then fork the Java buildpack and update its [repository configuration](https://github.com/cloudfoundry/java-buildpack/blob/master/docs/util-repositories.md#configuration) to point at the web server.

All the artifacts and `index.yml` files may be downloaded using the [`replicate`](bin/replicate) script.

To use the script, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec bin/replicate --host-name <new hostname> --output <directory path>
```

where:
* `<new hostname>` is the hostname which will serve the rehosted artifacts. The script will replace the host in each downloaded index file.
* `<directory path>` is the path to a directory for the downloaded artifacts and `index.yml` files.


## Usage
To run the builder, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec bin/build [DEPENDENCY] [OPTIONS]
```

### Building OpenJDK
In order to build OpenJDK for the linuxes you will need [Vagrant][] and [VirtualBox][].  Follow the default installation instructions for these applications.

In order to build OpenJDK for OS X you will need [VMware Fusion][] and the [build VM][].

### Credentials
Pivotal employees should contact Ben Hale for AWS and AppDynamics credentials if they have not already been issued.

## Available Artifacts
The list of available versions for each dependency can be found at the following locations.

| Dependency | Location
| ---------- | ---------
| App Dynamics | [`universal`](http://download.run.pivotal.io/app-dynamics/index.yml)
| Auto Reconfiguration | [`universal`](http://download.run.pivotal.io/auto-reconfiguration/index.yml)
| Groovy | [`universal`](http://download.run.pivotal.io/groovy/index.yml)
| JBoss AS | [`universal`](http://download.run.pivotal.io/jboss-as/index.yml)
| MariaDB JDBC | [`universal`](http://download.run.pivotal.io/mariadb-jdbc/index.yml)
| OpenJDK | [`centos6`](http://download.run.pivotal.io/openjdk/centos6/x86_64/index.yml), [`lucid`](http://download.run.pivotal.io/openjdk/lucid/x86_64/index.yml), [`mountainlion`](http://download.run.pivotal.io/openjdk/mountainlion/x86_64/index.yml), [`precise`](http://download.run.pivotal.io/openjdk/precise/x86_64/index.yml)
| New Relic | [`universal`](http://download.run.pivotal.io/new-relic/index.yml)
| Play JPA Plugin | [`universal`](http://download.run.pivotal.io/play-jpa-plugin/index.yml)
| PostgreSQL JDBC | [`universal`](http://download.run.pivotal.io/postgresql-jdbc/index.yml)
| RedisStore | [`universal`](http://download.run.pivotal.io/redis-store/index.yml)
| Spring Boot CLI | [`universal`](http://download.run.pivotal.io/spring-boot-cli/index.yml)
| tc Server| [`universal`](http://download.run.pivotal.io/tc-server/index.yml)
| Tomcat | [`universal`](http://download.run.pivotal.io/tomcat/index.yml)
| Tomcat Lifecycle Support | [`universal`](http://download.run.pivotal.io/tomcat-lifecycle-support/index.yml)
| Tomcat Logging Support | [`universal`](http://download.run.pivotal.io/tomcat-logging-support/index.yml)

## Running Tests
To run the tests, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec rake
```

## Contributing
[Pull requests][] are welcome; see the [contributor guidelines][] for details.

## License
The Builder is released under version 2.0 of the [Apache License][].

[Apache License]: http://www.apache.org/licenses/LICENSE-2.0
[build VM]: http://boxes.gopivotal.com.s3.amazonaws.com/mac-osx-10.8.tar.gz
[contributor guidelines]: CONTRIBUTING.md
[Pull requests]: http://help.github.com/send-pull-requests
[Vagrant]: http://www.vagrantup.com
[VirtualBox]: https://www.virtualbox.org
[VMware Fusion]: http://www.vmware.com/products/fusion
---

## Update Locations
This table shows locations to check for new releases of cached dependencies.  It is used primarily by Pivotal employees to keep the caches up to date.

| Dependency | Location
| ---------- | --------
| App Dynamics | [`release`](http://download.appdynamics.com/browse/zone/3/)
| Auto Reconfiguration | [`release`](http://maven.springframework.org.s3.amazonaws.com/milestone/org/cloudfoundry/auto-reconfiguration/maven-metadata.xml)
| Groovy | [`release`](http://groovy.codehaus.org/Download?nc)
| JBoss AS | [`release`](http://www.jboss.org/jbossas/downloads)
| MariaDB JDBC | [`release`](https://downloads.mariadb.org/client-java/)
| OpenJDK | [`oracle`](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [`jdk8u`](http://hg.openjdk.java.net/jdk8u/jdk8u), [`jdk7u`](http://hg.openjdk.java.net/jdk7u/jdk7u), [`jdk6`](http://hg.openjdk.java.net/jdk6/jdk6)
| New Relic | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.newrelic.agent.java%22%20AND%20a%3A%22newrelic-agent%22)
| Play JPA Plugin | [`release`](http://maven.springframework.org.s3.amazonaws.com/milestone/org/cloudfoundry/play-jpa-plugin/maven-metadata.xml)
| PostgreSQL JDBC | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.postgresql%22%20AND%20a%3A%22postgresql%22)
| RedisStore | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/com/gopivotal/manager/redis-store/maven-metadata.xml)
| Spring Boot CLI | [`release`](http://repo.springsource.org/release/org/springframework/boot/spring-boot-cli/)
| tc Server | [`release`](http://gopivotal.com/pivotal-products/pivotal-vfabric)
| Tomcat | [`8.x`](http://tomcat.apache.org/download-80.cgi), [`7.x`](http://tomcat.apache.org/download-70.cgi), [`6.x`](http://tomcat.apache.org/download-60.cgi)
| Tomcat Lifecycle Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-lifecycle-support/maven-metadata.xml)
| Tomcat Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-logging-support/maven-metadata.xml)

## Open JDK Build Details
This table shows the mappings between versions, build numbers, and repository tags for OpenJDK releases.  It is used primarily by Pivotal employees to keep track of exactly what was built and should not be considered authoritative

| JDK Version | Build Number | Tag           | Centos6 | Lucid | Mountain Lion | Precise |
| ----------- | ------------ | ------------- | ------- | ----- | ------------- | ------- |
| `1.6.0_21`  | `b21`        | `jdk6-b21`    |         | ✓     |               |         |
| `1.6.0_22`  | `b22`        | `jdk6-b22`    |         | ✓     |               |         |
| `1.6.0_23`  | `b23`        | `jdk6-b23`    |         | ✓     |               |         |
| `1.6.0_24`  | `b24`        | `jdk6-b24`    |         | ✓     |               |         |
| `1.6.0_25`  | `b25`        | `jdk6-b25`    |         | ✓     |               |         |
| `1.6.0_26`  | `b26`        | `jdk6-b26`    |         | ✓     |               |         |
| `1.6.0_27`  | `b27`        | `jdk6-b27`    |         | ✓     |               |         |
|             |              |               |         |       |               |         |
| `1.7.0_01`  | `b08`        | `jdk7u1-b08`  | ✓       | ✓     |               | ✓       |
| `1.7.0_02`  | `b21`        | `jdk7u2-b21`  | ✓       | ✓     |               | ✓       |
| `1.7.0_03`  | `b04`        | `jdk7u3-b04`  | ✓       | ✓     |               | ✓       |
| `1.7.0_04`  | `b31`        | `jdk7u4-b31`  | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_05`  | `b30`        | `jdk7u5-b30`  | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_06`  | `b31`        | `jdk7u6-b31`  | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_07`  | `b31`        | `jdk7u7-b31`  | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_08`  | `b05`        | `jdk7u8-b05`  | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_09`  | `b32`        | `jdk7u9-b32`  | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_10`  | `b31`        | `jdk7u10-b31` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_11`  | `b33`        | `jdk7u11-b33` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_12`  | `b09`        | `jdk7u12-b09` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_13`  | `b30`        | `jdk7u13-b30` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_14`  | `b22`        | `jdk7u14-b22` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_15`  | `b33`        | `jdk7u15-b33` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_17`  | `b31`        | `jdk7u17-b31` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_21`  | `b30`        | `jdk7u21-b30` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_25`  | `b11`        | `jdk7u25-b11` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_40`  | `b43`        | `jdk7u40-b43` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_45`  | `b31`        | `jdk7u45-b31` | ✓       | ✓     | ✓             | ✓       |
| `1.7.0_51`  | `b31`        | `jdk7u51-b31` | ✓       | ✓     | ✓             | ✓       |
|             |              |               |         |       |               |         |
| `1.8.0_M6`  | `b75`        | `jdk8-b75`    | ✓       | ✓     | ✓             | ✓       |
| `1.8.0_M7`  | `b91`        | `jdk8-b91`    | ✓       | ✓     | ✓             | ✓       |
| `1.8.0_M8`  | `b106`       | `jdk8-b106`   | ✓       | ✓     | ✓             | ✓       |
| `1.8.0_RC1` | `b128`       | `jdk8-b128`   | ✓       | ✓     | ✓             | ✓       |
| `1.8.0`     | `b132`       | `jdk8-b132`   | ✓       | ✓     | ✓             | ✓       |

