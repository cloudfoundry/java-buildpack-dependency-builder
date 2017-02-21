# Java Buildpack Dependency Builders
This project automates the building and publication of Java Buildpack dependency artifacts.

## Replicating Repository
To host the Java Buildpack dependency artifacts on your own server, first download the artifacts and `index.yml` files as described below, make them available at suitable locations on a web server, and then fork the Java buildpack and update its [repository configuration](https://github.com/cloudfoundry/java-buildpack/blob/master/docs/extending-repositories.md#configuration) to point at the web server.

All the artifacts and `index.yml` files may be downloaded using the [`replicate`](replicate.sh) script.

To use the script, ensure that you have installed the [AWS CLI][c] and issue the following commands from the root directory of a clone of this repository:

```bash
BASE_URI=<BASE-URI> DESTINATION=<DESTINATION> ./replicate.sh
```

| Environment Variable | Description |
| ------ | ----------- |
| `BASE_URI` | A URI to replace `https://java-buildpack.cloudfoundry.org` with, in `index.yml` files.  This value should be the network location that the repository is replicated to (e.g. `https://internal-repository:8000/dependencies`).
| `DESTINATION` | A filesystem location to replicate the repository to.


## Available Artifacts
The list of available versions for each dependency can be found at the following locations.

| Dependency | Location
| ---------- | ---------
| Auto Reconfiguration | [`universal`](https://java-buildpack.cloudfoundry.org/auto-reconfiguration/index.yml)
| Container Certificate Trust Store | [`universal`](https://java-buildpack.cloudfoundry.org/container-certificate-trust-store/index.yml)
| Container Customizer | [`universal`](https://java-buildpack.cloudfoundry.org/container-customizer/index.yml)
| GemFire Modules Tomcat 7| [`universal`](https://java-buildpack.cloudfoundry.org/gem-fire-modules-tomcat7/index.yml)
| GemFire Modules | [`universal`](https://java-buildpack.cloudfoundry.org/gem-fire-modules/index.yml)
| GemFire Security | [`universal`](https://java-buildpack.cloudfoundry.org/gem-fire-security/index.yml)
| GemFire | [`universal`](https://java-buildpack.cloudfoundry.org/gem-fire/index.yml)
| Groovy | [`universal`](https://java-buildpack.cloudfoundry.org/groovy/index.yml)
| `jvmkill` | [`mountainlion`](https://java-buildpack.cloudfoundry.org/jvmkill/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/jvmkill/trusty/x86_64/index.yml)
| Log4j API | [`universal`](https://java-buildpack.cloudfoundry.org/log4j-api/index.yml)
| Log4j Core | [`universal`](https://java-buildpack.cloudfoundry.org/log4j-core/index.yml)
| Log4j Jcl | [`universal`](https://java-buildpack.cloudfoundry.org/log4j-jcl/index.yml)
| Log4j Jul | [`universal`](https://java-buildpack.cloudfoundry.org/log4j-jul/index.yml)
| Log4j Slf4j Impl | [`universal`](https://java-buildpack.cloudfoundry.org/log4j-slf4j-impl/index.yml)
| MariaDB JDBC | [`universal`](https://java-buildpack.cloudfoundry.org/mariadb-jdbc/index.yml)
| Memory Calculator | [`mountainlion`](https://java-buildpack.cloudfoundry.org/memory-calculator/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/memory-calculator/trusty/x86_64/index.yml)
| New Relic | [`universal`](https://java-buildpack.cloudfoundry.org/new-relic/index.yml)
| OpenJDK JRE | [`mountainlion`](https://java-buildpack.cloudfoundry.org/openjdk/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/openjdk/trusty/x86_64/index.yml)
| OpenJDK JDK | [`mountainlion`](https://java-buildpack.cloudfoundry.org/openjdk-jdk/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/openjdk-jdk/trusty/x86_64/index.yml)
| Play JPA Plugin | [`universal`](https://java-buildpack.cloudfoundry.org/play-jpa-plugin/index.yml)
| PostgreSQL JDBC | [`universal`](https://java-buildpack.cloudfoundry.org/postgresql-jdbc/index.yml)
| RedisStore | [`universal`](https://java-buildpack.cloudfoundry.org/redis-store/index.yml)
| Slf4j API | [`universal`](https://java-buildpack.cloudfoundry.org/slf4j-api/index.yml)
| Slf4j JDK14 | [`universal`](https://java-buildpack.cloudfoundry.org/slf4j-jdk14/index.yml)
| Spring Boot CLI | [`universal`](https://java-buildpack.cloudfoundry.org/spring-boot-cli/index.yml)
| tc Server| [`universal`](https://java-buildpack.cloudfoundry.org/tc-server/index.yml)
| Tomcat Access Logging Support | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat-access-logging-support/index.yml)
| Tomcat Lifecycle Support | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat-lifecycle-support/index.yml)
| Tomcat Logging Support | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat-logging-support/index.yml)
| Tomcat | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat/index.yml)
| TomEE Resource Configuration | [`universal`](https://java-buildpack.cloudfoundry.org/tomee-resource-configuration/index.yml)
| TomEE | [`universal`](https://java-buildpack.cloudfoundry.org/tomee/index.yml)
| Wildfly | [`universal`](https://java-buildpack.cloudfoundry.org/wildfly/index.yml)
| YourKit | [`mountainlion`](https://java-buildpack.cloudfoundry.org/your-kit/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/your-kit/trusty/x86_64/index.yml)

## Contributing
[Pull requests][p] are welcome; see the [contributor guidelines][g] for details.

## License
The Builder is released under version 2.0 of the [Apache License][a].

[c]: https://aws.amazon.com/cli/
[a]: http://www.apache.org/licenses/LICENSE-2.0
[g]: CONTRIBUTING.md
[p]: http://help.github.com/send-pull-requests
---

## Update Locations
This table shows locations to check for new releases of cached dependencies.  It is used primarily by Pivotal employees to keep the caches up to date.

| Dependency | Location
| ---------- | --------
| GemFire Modules Tomcat 7| [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| GemFire Modules | [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| GemFire Security | [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| GemFire | [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| Groovy | [`release`](http://groovy-lang.org/download.html)
| `jvmkill` | [`release`](https://github.com/cloudfoundry/jvmkill/releases)
| Memory Calculator | [`release`](https://github.com/cloudfoundry/java-buildpack-memory-calculator/releases)
| OpenJDK | [`oracle`](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [`jdk8u`](http://hg.openjdk.java.net/jdk8u/jdk8u)
| RedisStore | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/com/gopivotal/manager/redis-store/maven-metadata.xml)
| Spring Boot CLI | [`release`](http://repo.springsource.org/release/org/springframework/boot/spring-boot-cli/)
| tc Server | [`release`](https://network.pivotal.io/products/pivotal-tcserver)
| Tomcat Access Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-access-logging-support/maven-metadata.xml)
| Tomcat Lifecycle Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-lifecycle-support/maven-metadata.xml)
| Tomcat Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-logging-support/maven-metadata.xml)
| TomEE Resource Configuration | [`release`](https://repo.spring.io/webapp/#/artifacts/browse//search/quick/eyJzZWFyY2giOiJxdWljayIsInF1ZXJ5IjoidG9tZWUtcmVzb3VyY2UtY29uZmlndXJhdGlvbiIsInNlbGVjdGVkUmVwb3NpdG9yaWVzIjpbeyJyZXBvS2V5IjoibGlicy1yZWxlYXNlLWxvY2FsIiwidHlwZSI6ImxvY2FsIiwiX2ljb25DbGFzcyI6Imljb24gaWNvbi1sb2NhbC1yZXBvIn1dfQ==)
| TomEE | [`release`](http://tomee.apache.org/downloads.html)
| Wildfly | [`release`](http://wildfly.org/downloads)
| YourKit | [`release`](https://www.yourkit.com/download)
