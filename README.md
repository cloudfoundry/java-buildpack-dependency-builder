# Java Buildpack Dependency Builders
[![Build Status](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder.png?branch=master)](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder)
[![Dependency Status](https://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder.png)](http://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder)

This project automates the building and publication of Java Buildpack dependency artifacts.

## Usage
To run the builder, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec bin/build [DEPENDENCY] [OPTIONS]
```

### Building OpenJDK
In order to build OpenJDK for the linuxes you will need [Vagrant][] and [VirtualBox][].  Follow the default installation instructions for these applications.

In order to build OpenJDK for OS X you will need Mercurial and [XQuartz][].  Mercurial can be installed with homebrew, XQuartz should be installed by following the default installation instructions.

### Credentials
Pivotal employees should contact Ben Hale for AWS and AppDynamics credentials if they have not already been issued.

## Available Artifacts
The list of available versions for each dependency can be found at the following locations.

| Dependency | Location
| ---------- | ---------
| App Dynamics | [`universal`](http://download.pivotal.io.s3.amazonaws.com/app-dynamics/index.yml)
| Auto Reconfiguration | [`universal`](http://download.pivotal.io.s3.amazonaws.com/auto-reconfiguration/index.yml)
| Groovy | [`universal`](http://download.pivotal.io.s3.amazonaws.com/groovy/index.yml)
| MariaDB JDBC | [`universal`](http://download.pivotal.io.s3.amazonaws.com/mariadb-jdbc/index.yml)
| OpenJDK | [`centos6`](http://download.pivotal.io.s3.amazonaws.com/openjdk/centos6/x86_64/index.yml), [`lucid`](http://download.pivotal.io.s3.amazonaws.com/openjdk/lucid/x86_64/index.yml), [`mountainlion`](http://download.pivotal.io.s3.amazonaws.com/openjdk/mountainlion/x86_64/index.yml), [`precise`](http://download.pivotal.io.s3.amazonaws.com/openjdk/precise/x86_64/index.yml)
| New Relic | [`universal`](http://download.pivotal.io.s3.amazonaws.com/new-relic/index.yml)
| Play JPA Plugin | [`universal`](http://download.pivotal.io.s3.amazonaws.com/play-jpa-plugin/index.yml)
| PostgreSQL JDBC | [`universal`](http://download.pivotal.io.s3.amazonaws.com/postgresql-jdbc/index.yml)
| Spring Boot CLI | [`universal`](http://download.pivotal.io.s3.amazonaws.com/spring-boot-cli/index.yml)
| tc Server| [`universal`](http://download.pivotal.io.s3.amazonaws.com/tc-server/index.yml)
| Tomcat | [`universal`](http://download.pivotal.io.s3.amazonaws.com/tomcat/index.yml)

Note that the following additional dependency is built and published using the [Java Buildpack Support][] repository.

| Dependency | Location
| ---------- | ---------
| Tomcat Buildpack Support | <http://download.pivotal.io.s3.amazonaws.com/tomcat-buildpack-support/index.yml>

[Java Buildpack Support]: https://github.com/cloudfoundry/java-buildpack-support

## Running Tests
To run the tests, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec rake
```

## Rehosting Artifacts

To host the Java Buildpack dependency artifacts on your own server, first download the artifacts and `index.yml` files as described below, make them available at suitable locations on a web server, and then fork the
Java buildpack and update its [repository configuration](https://github.com/cloudfoundry/java-buildpack/blob/master/docs/util-repositories.md#configuration) to point at the web server.

All the artifacts and `index.yml` files may be downloaded using the [`replicate`](bin/replicate) script.

To use the script, issue the following commands from the root directory of a clone of this repository:

```bash
bundle install
bundle exec bin/replicate --access-key <access key> --secret-access-key <secret access key> --host-name <new hostname> --output <directory path>
```

where:
* `<access key>` and `<secret access key>` are any valid Amazon S3 credentials.
* `<new hostname>` is the hostname which will serve the rehosted artifacts. The script will replace the host in each downloaded index file.
* `<directory path>` is the path to a directory for the downloaded artifacts and `index.yml` files.

## Populating the Buildpack Cache

When DEAs are provisioned, everything in the `buildpack_cache` directory will be available via the `$BUILDPACK_CACHE` environment variable. To populate the `buildpack_cache` directory, follow these steps:

1. Clone `https://github.com/cloudfoundry/cf-release.git` and update its submodules (which takes a few minutes).

2. Change directory into the clone.

3. Create `config/private.yml` with contents in the following format containing the appropriate S3 keys (see [blobstore information][] for more information):

    ```
    ---
    blobstore:
      s3:
        secret_access_key: secretaccesskey
        access_key_id: accesskeyid
    ```

4. Issue `mkdir -p blobs/buildpack_cache/java-buildpack`.

5. Go through the list of Java buildpack dependency repositories (in the Available Artifacts section above) and for each one:

  5.1 Run the [populate-buildpack-stash.rb](bin/populate-buildpack-stash.rb) script as follows:

	  `~/populate-buildpack-stash.rb /clone/blobs/buildpack_cache/java-buildpack <repository index.yml URL>`

  5.2 Edit the downloaded file to exclude any versions not required in the buildpack cache - typically all except the latest version.

  Refer to `/clone/config/blobs.yml` to see what is already in the buildpack cache (take care to look in the entries containing `buildpack_cache/java-buildpack`).

  If there are no items in the edited `index.yml` which are not already in the buildpack cache, delete the downloaded `index.yml` file and skip the next step.

  5.3 For each item in the above edited `index.yml` which is not already in the buildpack cache, issue:

        `~/populate-buildpack-stash.rb /clone/blobs/buildpack_cache/java-buildpack <URL from index.yml>`

6. Run `bosh upload blobs` from the clone directory.

7. Commit the change to `config/blobs.yml` or, if you don't have commit rights, create a pull request.

Once the change to `config/blobs.yml` has been committed or the pull request merged, you can expect the uploaded files to become available on tabasco within a few hours.

More information is available in [blobstore information][].

[blobstore information]: https://github.com/cloudfoundry/internal-docs/blob/master/howtos/upload_blobs.md

## Contributing
[Pull requests][] are welcome; see the [contributor guidelines][] for details.

## License
The Builder is released under version 2.0 of the [Apache License][].

[Apache License]: http://www.apache.org/licenses/LICENSE-2.0
[contributor guidelines]: CONTRIBUTING.md
[Pull requests]: http://help.github.com/send-pull-requests
[Vagrant]: http://www.vagrantup.com
[VirtualBox]: https://www.virtualbox.org
[XQuartz]: http://xquartz.macosforge.org/landing/

---

## Update Locations
This table shows locations to check for new releases of cached dependencies.  It is used primarily by Pivotal employees to keep the caches up to date.

| Dependency | Location
| ---------- | --------
| App Dynamics | [`release`](http://download.appdynamics.com/browse/zone/3/)
| Auto Reconfiguration | [`release`](http://maven.springframework.org.s3.amazonaws.com/milestone/org/cloudfoundry/auto-reconfiguration/maven-metadata.xml)
| Groovy | [`release`](http://groovy.codehaus.org/Download?nc)
| MariaDB JDBC | [`release`](https://downloads.mariadb.org/client-java/)
| OpenJDK | [`jdk8`](http://openjdk.java.net/projects/jdk8/milestones), [`jdk7u`](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [`jdk6`](http://hg.openjdk.java.net/jdk6/jdk6/summary)
| New Relic | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.newrelic.agent.java%22%20AND%20a%3A%22newrelic-agent%22)
| Play JPA Plugin | [`release`](http://maven.springframework.org.s3.amazonaws.com/milestone/org/cloudfoundry/play-jpa-plugin/maven-metadata.xml)
| PostgreSQL JDBC | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.postgresql%22%20AND%20a%3A%22postgresql%22)
| Spring Boot CLI | [`release`](http://repo.springsource.org/release/org/springframework/boot/spring-boot-cli/), [`milestone`](http://repo.springsource.org/milestone/org/springframework/boot/spring-boot-cli/), [`snapshot`](http://repo.springsource.org/libs-snapshot-local/org/springframework/boot/spring-boot-cli/)
| tc Server | [`release`](http://gopivotal.com/pivotal-products/pivotal-vfabric)
| Tomcat | [`8.x`](http://tomcat.apache.org/download-80.cgi), [`7.x`](http://tomcat.apache.org/download-70.cgi), [`6.x`](http://tomcat.apache.org/download-60.cgi)

## Open JDK Build Details
This table shows the mappings between versions, build numbers, and repository tags for OpenJDK releases.  It is used primarily by Pivotal employees to keep track of exactly what was built.

| JDK Version | Build Number | Tag
| ----------- | ------------ | ---
| `1.6.0_21` | `b21` | `jdk6-b21`
| `1.6.0_22` | `b22` | `jdk6-b22`
| `1.6.0_23` | `b23` | `jdk6-b23`
| `1.6.0_24` | `b24` | `jdk6-b24`
| `1.6.0_25` | `b25` | `jdk6-b25`
| `1.6.0_26` | `b26` | `jdk6-b26`
| `1.6.0_27` | `b27` | `jdk6-b27`
| `1.7.0_01` | `b08` | `jdk7u1-b08`
| `1.7.0_02` | `b21` | `jdk7u2-b21`
| `1.7.0_03` | `b04` | `jdk7u3-b04`
| `1.7.0_04` | `b31` | `jdk7u4-b31`
| `1.7.0_05` | `b30` | `jdk7u5-b30`
| `1.7.0_06` | `b31` | `jdk7u6-b31`
| `1.7.0_07` | `b31` | `jdk7u7-b31`
| `1.7.0_08` | `b05` | `jdk7u8-b05`
| `1.7.0_09` | `b32` | `jdk7u9-b32`
| `1.7.0_10` | `b31` | `jdk7u10-b31`
| `1.7.0_11` | `b33` | `jdk7u11-b33`
| `1.7.0_12` | `b09` | `jdk7u12-b09`
| `1.7.0_13` | `b30` | `jdk7u13-b30`
| `1.7.0_14` | `b22` | `jdk7u14-b22`
| `1.7.0_15` | `b33` | `jdk7u15-b33`
| `1.7.0_17` | `b31` | `jdk7u17-b31`
| `1.7.0_21` | `b30` | `jdk7u21-b30`
| `1.7.0_25` | `b11` | `jdk7u25-b11`
| `1.7.0_40` | `b43` | `jdk7u40-b43`
| `1.7.0_45` | `b31` | `jdk7u45-b31`
| `1.8.0_M6` | `b75` | `jdk8-b75`
| `1.8.0_M7` | `b91` | `jdk8-b91`
| `1.8.0_M8` | `b106` | `jdk8-b106`
