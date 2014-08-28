# Java Buildpack Dependency Builders
[![Build Status](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder.svg?branch=master)](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder)
[![Dependency Status](https://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder.svg)](https://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder)
[![Code Climate](https://codeclimate.com/repos/52b84ef86956807cc400133a/badges/b442d613a128726bcbe8/gpa.svg)](https://codeclimate.com/repos/52b84ef86956807cc400133a/feed)
[![Code Climate](https://codeclimate.com/repos/52b84ef86956807cc400133a/badges/b442d613a128726bcbe8/coverage.svg)](https://codeclimate.com/repos/52b84ef86956807cc400133a/feed)

This project automates the building and publication of Java Buildpack dependency artifacts.

## Replicating Repository
To host the Java Buildpack dependency artifacts on your own server, first download the artifacts and `index.yml` files as described below, make them available at suitable locations on a web server, and then fork the Java buildpack and update its [repository configuration](https://github.com/cloudfoundry/java-buildpack/blob/master/docs/util-repositories.md#configuration) to point at the web server.

All the artifacts and `index.yml` files may be downloaded using the [`replicate`](bin/replicate) script.

To use the script, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec bin/replicate [--base-uri <BASE-URI> | --host-name <HOST-NAME>] --output <OUTPUT>
```

| Option | Description |
| ------ | ----------- |
| `-b`, `--base-uri <BASE-URI>` | A URI to replace `https://download.run.pivotal.io` with, in `index.yml` files.  This value should be the network location that the repository is replicated to (e.g. `https://internal-repository:8000/dependencies`).  Either this option or `--host-name`, but not both, **must** be specified.
| `-h`, `--host-name <HOST-NAME>` | A host name to replace `download.run.pivotal.io` with, in `index.yml` files.  This value should be the network host that the repository is replicated to (e.g. `internal-repository`).  Either this option or `--base-uri`, but not both, **must** be specified.
| `-o`, `--output <OUTPUT>` | A filesystem location to replicate the repository to.  This option **must** be specified.

## Building Dependencies
To run the builder, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec bin/build [DEPENDENCY] [OPTIONS]
```

### Configuration File
All components require a configuration file in order to be published.  This YAML file contains credentials for various servers used during publishing.  If unspecified with the `--configuration` switch, it is expected to be at `~/.java_buildpack_dependency_builder.yml`.  An example file looks like the following:

```yaml
---
# Values are for default repository
:bucket: download.pivotal.io
:repository_root: https://download.run.pivotal.io

# Required AWS credentials
:access_key_id: <ACCESS_KEY_ID>
:secret_access_key: <SECRET_ACCESS_KEY>

# Optional CloudFront Distribution Id
:distribution_id: <DISTRIBUTION_ID>

# Optional AppDynamics download credentials
:app_dynamics_username: <USERNAME>
:app_dynamics_password: <PASSWORD>
```

| Key | Description
| --- | -----------
| `:access_key_id` | AWS Access Key Id for the destination bucket and optional CloudFront distribution
| `:app_dynamics_password` | **(Optional)** AppDynamics agent download password
| `:app_dynamics_username` | **(Optional)** AppDynamics agent download username
| `:bucket` | Publishing destination S3 bucket
| `:distribution_id` | **(Optional)** The CloudFront distribution id for the destination bucket
| `:respository_root` | The repository root URI that dependencies will be available at
| `:secret_access_key` | AWS Secret Access Key for the destination bucket and optional CloudFront distribution


_Pivotal employees should contact Ben Hale for AWS and AppDynamics credentials if they have not already been issued and are needed._

### Building Node, OpenJDK, and Ruby
In order to build Node, OpenJDK, and Ruby you will need [Vagrant][] and [VirtualBox][] or [VMware Fusion][].  Follow the default installation instructions for these applications.  If you choose to use VMware Fusion, make sure that you also have a license for, and have installed the [Vagrant VMware Provider][].

```bash
$ vagrant plugin install vagrant-vmware-fusion
$ vagrant plugin license vagrant-vmware-fusion license.lic
```



## Available Artifacts
The list of available versions for each dependency can be found at the following locations.

| Dependency | Location
| ---------- | ---------
| App Dynamics | [`universal`](https://download.run.pivotal.io/app-dynamics/index.yml)
| Auto Reconfiguration | [`universal`](https://download.run.pivotal.io/auto-reconfiguration/index.yml)
| Groovy | [`universal`](https://download.run.pivotal.io/groovy/index.yml)
| JBoss AS | [`universal`](https://download.run.pivotal.io/jboss-as/index.yml)
| MariaDB JDBC | [`universal`](https://download.run.pivotal.io/mariadb-jdbc/index.yml)
| New Relic | [`universal`](https://download.run.pivotal.io/new-relic/index.yml)
| NodeJS | [`centos6`](https://download.run.pivotal.io/node/centos6/x86_64/index.yml), [`lucid`](https://download.run.pivotal.io/node/lucid/x86_64/index.yml), [`mountainlion`](https://download.run.pivotal.io/node/mountainlion/x86_64/index.yml), [`precise`](https://download.run.pivotal.io/node/precise/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/node/trusty/x86_64/index.yml)
| OpenJDK | [`centos6`](https://download.run.pivotal.io/openjdk/centos6/x86_64/index.yml), [`lucid`](https://download.run.pivotal.io/openjdk/lucid/x86_64/index.yml), [`mountainlion`](https://download.run.pivotal.io/openjdk/mountainlion/x86_64/index.yml), [`precise`](https://download.run.pivotal.io/openjdk/precise/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/openjdk/trusty/x86_64/index.yml)
| Play JPA Plugin | [`universal`](https://download.run.pivotal.io/play-jpa-plugin/index.yml)
| PostgreSQL JDBC | [`universal`](https://download.run.pivotal.io/postgresql-jdbc/index.yml)
| RedisStore | [`universal`](https://download.run.pivotal.io/redis-store/index.yml)
| Ruby | [`centos6`](https://download.run.pivotal.io/ruby/centos6/x86_64/index.yml), [`lucid`](https://download.run.pivotal.io/ruby/lucid/x86_64/index.yml), [`mountainlion`](https://download.run.pivotal.io/ruby/mountainlion/x86_64/index.yml), [`precise`](https://download.run.pivotal.io/ruby/precise/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/ruby/trusty/x86_64/index.yml)
| Spring Boot CLI | [`universal`](https://download.run.pivotal.io/spring-boot-cli/index.yml)
| tc Server| [`universal`](https://download.run.pivotal.io/tc-server/index.yml)
| Tomcat | [`universal`](https://download.run.pivotal.io/tomcat/index.yml)
| Tomcat Access Logging Support | [`universal`](https://download.run.pivotal.io/tomcat-access-logging-support/index.yml)
| Tomcat Lifecycle Support | [`universal`](https://download.run.pivotal.io/tomcat-lifecycle-support/index.yml)
| Tomcat Logging Support | [`universal`](https://download.run.pivotal.io/tomcat-logging-support/index.yml)

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
[Vagrant VMware Provider]: http://www.vagrantup.com/vmware
[Vagrant]: http://www.vagrantup.com
[VirtualBox]: https://www.virtualbox.org
[VMware Fusion]: http://www.vmware.com/products/fusion
---

## Update Locations
This table shows locations to check for new releases of cached dependencies.  It is used primarily by Pivotal employees to keep the caches up to date.

| Dependency | Location
| ---------- | --------
| App Dynamics | [`release`](http://download.appdynamics.com/browse/zone/3/)
| Auto Reconfiguration | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/auto-reconfiguration/maven-metadata.xml)
| Groovy | [`release`](http://groovy.codehaus.org/Download?nc)
| JBoss AS | [`release`](http://www.jboss.org/jbossas/downloads)
| MariaDB JDBC | [`release`](https://downloads.mariadb.org/client-java/)
| New Relic | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.newrelic.agent.java%22%20AND%20a%3A%22newrelic-agent%22)
| NodeJS | [`stable`](https://semver.io/node/stable), [`unstable`](https://semver.io/node/unstable)
| OpenJDK | [`oracle`](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [`jdk8u`](http://hg.openjdk.java.net/jdk8u/jdk8u), [`jdk7u`](http://hg.openjdk.java.net/jdk7u/jdk7u), [`jdk6`](http://hg.openjdk.java.net/jdk6/jdk6)
| Play JPA Plugin | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/play-jpa-plugin/maven-metadata.xml)
| PostgreSQL JDBC | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.postgresql%22%20AND%20a%3A%22postgresql%22)
| RedisStore | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/com/gopivotal/manager/redis-store/maven-metadata.xml)
| Ruby | [`release`](https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build)
| Spring Boot CLI | [`release`](http://repo.springsource.org/release/org/springframework/boot/spring-boot-cli/)
| tc Server | [`release`](http://gopivotal.com/pivotal-products/pivotal-vfabric)
| Tomcat | [`8.x`](http://tomcat.apache.org/download-80.cgi), [`7.x`](http://tomcat.apache.org/download-70.cgi), [`6.x`](http://tomcat.apache.org/download-60.cgi)
| Tomcat Access Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-access-logging-support/maven-metadata.xml)
| Tomcat Lifecycle Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-lifecycle-support/maven-metadata.xml)
| Tomcat Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-logging-support/maven-metadata.xml)

## Open JDK Build Details
This table shows the mappings between versions, build numbers, and repository tags for OpenJDK releases.  It is used primarily by Pivotal employees to keep track of exactly what was built and should not be considered authoritative.

| JDK Version | Build Number | Tag           | Centos6 | Lucid | OS X | Precise | Trusty |
| ----------- | ------------ | ------------- | :-----: | :---: | :--: | :-----: | :----: |
| `1.8.0_20`  | `b23`        | `jdk8u20-b23` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.8.0_11`  | `b12`        | `jdk8u11-b12` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.8.0_05`  | `b13`        | `jdk8u5-b13`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.8.0`     | `b132`       | `jdk8-b132`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.8.0_RC1` | `b128`       | `jdk8-b128`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.8.0_M8`  | `b106`       | `jdk8-b106`   | ✓       | ✓     | ✓    | ✓       |        |
| `1.8.0_M7`  | `b91`        | `jdk8-b91`    | ✓       | ✓     | ✓    | ✓       |        |
| `1.8.0_M6`  | `b75`        | `jdk8-b75`    | ✓       | ✓     | ✓    | ✓       |        |
|             |              |               |         |       |      |         |        |
| `1.7.0_65`  | `b17`        | `jdk7u65-b17` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_60`  | `b19`        | `jdk7u60-b19` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_55`  | `b13`        | `jdk7u55-b13` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_51`  | `b31`        | `jdk7u51-b31` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_45`  | `b31`        | `jdk7u45-b31` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_40`  | `b43`        | `jdk7u40-b43` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_25`  | `b11`        | `jdk7u25-b11` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_21`  | `b30`        | `jdk7u21-b30` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_17`  | `b31`        | `jdk7u17-b31` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_15`  | `b33`        | `jdk7u15-b33` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_14`  | `b22`        | `jdk7u14-b22` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_13`  | `b30`        | `jdk7u13-b30` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_12`  | `b09`        | `jdk7u12-b09` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_11`  | `b33`        | `jdk7u11-b33` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_10`  | `b31`        | `jdk7u10-b31` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_09`  | `b32`        | `jdk7u9-b32`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_08`  | `b05`        | `jdk7u8-b05`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_07`  | `b31`        | `jdk7u7-b31`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_06`  | `b31`        | `jdk7u6-b31`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.7.0_05`  | `b30`        | `jdk7u5-b30`  | ✓       | ✓     | ✓    | ✓       |        |
| `1.7.0_04`  | `b31`        | `jdk7u4-b31`  | ✓       | ✓     | ✓    | ✓       |        |
| `1.7.0_03`  | `b04`        | `jdk7u3-b04`  | ✓       | ✓     |      | ✓       |        |
| `1.7.0_02`  | `b21`        | `jdk7u2-b21`  | ✓       | ✓     |      | ✓       |        |
| `1.7.0_01`  | `b08`        | `jdk7u1-b08`  | ✓       | ✓     |      | ✓       |        |
|             |              |               |         |       |      |         |        |
| `1.6.0_27`  | `b27`        | `jdk6-b27`    |         | ✓     |      |         |        |
| `1.6.0_26`  | `b26`        | `jdk6-b26`    |         | ✓     |      |         |        |
| `1.6.0_25`  | `b25`        | `jdk6-b25`    |         | ✓     |      |         |        |
| `1.6.0_24`  | `b24`        | `jdk6-b24`    |         | ✓     |      |         |        |
| `1.6.0_23`  | `b23`        | `jdk6-b23`    |         | ✓     |      |         |        |
| `1.6.0_22`  | `b22`        | `jdk6-b22`    |         | ✓     |      |         |        |
| `1.6.0_21`  | `b21`        | `jdk6-b21`    |         | ✓     |      |         |        |

## NodeJS Build Details
This table shows the mappings between version and tags for NodeJS releases.  It is used primarily by Pivotal employees to keep track of exactly what was built and should not be considered authoritative.

| NodeJS Version | Tag        | Centos6 | Lucid | OS X | Precise | Trusty |
| -------------- | ---------- | :-----: | :---: | :--: | :-----: | :----: |
| `0.11.13`      | `v0.11.13` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.12`      | `v0.11.12` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.11`      | `v0.11.11` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.10`      | `v0.11.10` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.9`       | `v0.11.9`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.8`       | `v0.11.8`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.7`       | `v0.11.7`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.6`       | `v0.11.6`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.5`       | `v0.11.5`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.4`       | `v0.11.4`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.3`       | `v0.11.3`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.2`       | `v0.11.2`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.1`       | `v0.11.1`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.11.0`       | `v0.11.0`  | ✓       | ✓     | ✓    | ✓       | ✓      |
|                |            |         |       |      |         |        |
| `0.10.31`      | `v0.10.31` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.30`      | `v0.10.30` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.29`      | `v0.10.29` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.28`      | `v0.10.28` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.27`      | `v0.10.27` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.26`      | `v0.10.26` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.25`      | `v0.10.25` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.24`      | `v0.10.24` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.23`      | `v0.10.23` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.22`      | `v0.10.22` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.21`      | `v0.10.21` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.20`      | `v0.10.20` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.19`      | `v0.10.19` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.18`      | `v0.10.18` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.17`      | `v0.10.17` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.16`      | `v0.10.16` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.15`      | `v0.10.15` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.14`      | `v0.10.14` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.13`      | `v0.10.13` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.12`      | `v0.10.12` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.11`      | `v0.10.11` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.10`      | `v0.10.10` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.9`       | `v0.10.9`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.8`       | `v0.10.8`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.7`       | `v0.10.7`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.6`       | `v0.10.6`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.5`       | `v0.10.5`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.4`       | `v0.10.4`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.3`       | `v0.10.3`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.2`       | `v0.10.2`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.1`       | `v0.10.1`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.10.0`       | `v0.10.0`  | ✓       | ✓     | ✓    | ✓       | ✓      |
|                |            |         |       |      |         |        |
| `0.9.12`       | `v0.9.12`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.11`       | `v0.9.11`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.10`       | `v0.9.10`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.9`        | `v0.9.9`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.8`        | `v0.9.8`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.7`        | `v0.9.7`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.6`        | `v0.9.6`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.5`        | `v0.9.5`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.4`        | `v0.9.4`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.3`        | `v0.9.3`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.2`        | `v0.9.2`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.1`        | `v0.9.1`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.9.0`        | `v0.9.0`   | ✓       | ✓     | ✓    | ✓       | ✓      |
|                |            |         |       |      |         |        |
| `0.8.28`       | `v0.8.28`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.26`       | `v0.8.26`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.25`       | `v0.8.25`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.24`       | `v0.8.24`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.23`       | `v0.8.23`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.22`       | `v0.8.22`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.21`       | `v0.8.21`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.20`       | `v0.8.20`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.19`       | `v0.8.19`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.18`       | `v0.8.18`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.17`       | `v0.8.17`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.16`       | `v0.8.16`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.15`       | `v0.8.15`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.14`       | `v0.8.14`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.13`       | `v0.8.13`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.12`       | `v0.8.12`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.11`       | `v0.8.11`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.10`       | `v0.8.10`  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.9`        | `v0.8.9 `  | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.8`        | `v0.8.8`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.7`        | `v0.8.7`   | ✓       | ✓     | ✓    | ✓       | ✓      |
| `0.8.6`        | `v0.8.6`   | ✓       | ✓     | ✓    | ✓       | ✓      |

## Ruby Build Details
This table shows the mappings between version and tags for Ruby releases.  It is used primarily by Pivotal employees to keep track of exactly what was built and should not be considered authoritative.

| Ruby Version | Centos6 | Lucid | OS X | Precise | Trusty |
| -------------| :-----: | :---: | :--: | :-----: | :----: |
| `2.1.2`      | ✓       | ✓     | ✓    | ✓       | ✓      |
| `2.1.1`      | ✓       | ✓     | ✓    | ✓       | ✓      |
| `2.1.0`      | ✓       | ✓     | ✓    | ✓       | ✓      |
|              |         |       |      |         |        |
| `2.0.0-p481` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `2.0.0-p451` | ✓       | ✓     | ✓    | ✓       |        |
| `2.0.0-p353` | ✓       | ✓     | ✓    | ✓       |        |
| `2.0.0-p247` |         | ✓     | ✓    | ✓       |        |
| `2.0.0-p195` |         | ✓     | ✓    | ✓       |        |
| `2.0.0-p0`   |         | ✓     | ✓    | ✓       |        |
|              |         |       |      |         |        |
| `1.9.3-p547` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p545` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p484` | ✓       | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p448` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p429` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p392` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p385` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p374` |         | ✓     | ✓    | ✓       |        |
| `1.9.3-p362` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p327` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p286` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p194` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.3-p125` |         | ✓     | ✓    | ✓       | ✓      |
|              |         |       |      |         |        |
| `1.9.2-p326` |         | ✓     | ✓    | ✓       |        |
| `1.9.2-p320` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.2-p318` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.2-p290` |         | ✓     | ✓    | ✓       | ✓      |
| `1.9.2-p180` |         | ✓     | ✓    |         |        |
|              |         |       |      |         |        |
| `1.9.1-p430` |         | ✓     | ✓    |         |        |
| `1.9.1-p378` |         | ✓     | ✓    |         |        |
|              |         |       |      |         |        |
| `1.8.7-p375` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p374` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p371` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p370` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p358` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p357` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p352` |         | ✓     | ✓    | ✓       | ✓      |
| `1.8.7-p334` |         | ✓     | ✓    |         |        |
| `1.8.7-p302` |         | ✓     | ✓    |         |        |
| `1.8.7-p249` |         | ✓     | ✓    |         |        |
