# Java Buildpack Dependency Builders
This project automates the building and publication of Java Buildpack dependency artifacts.

## Replicating Repository
To host the Java Buildpack dependency artifacts on your own server, first download the artifacts and `index.yml` files as described below, make them available at suitable locations on a web server, and then fork the Java buildpack and update its [repository configuration](https://github.com/cloudfoundry/java-buildpack/blob/master/docs/extending-repositories.md#configuration) to point at the web server.

All the artifacts and `index.yml` files may be downloaded using the [`replicate`](replicate.sh) script.

To use the script, issue the following commands from the root directory of a clone of this repository:

```bash
BASE_URI=<BASE-URI> DESTINATION=<DESTINATION> ./replicate.sh
```

| Environment Variable | Description |
| ------ | ----------- |
| `BASE_URI` | A URI to replace `https://download.run.pivotal.io` with, in `index.yml` files.  This value should be the network location that the repository is replicated to (e.g. `https://internal-repository:8000/dependencies`).
| `DESTINATION` | A filesystem location to replicate the repository to.


## Available Artifacts
The list of available versions for each dependency can be found at the following locations.

| Dependency | Location
| ---------- | ---------
| Auto Reconfiguration | [`universal`](https://download.run.pivotal.io/auto-reconfiguration/index.yml)
| Container Customizer | [`universal`](https://download.run.pivotal.io/container-customizer/index.yml)
| GemFire Modules Tomcat 7| [`universal`](https://download.run.pivotal.io/gem-fire-modules-tomcat7/index.yml)
| GemFire Modules | [`universal`](https://download.run.pivotal.io/gem-fire-modules/index.yml)
| GemFire Security | [`universal`](https://download.run.pivotal.io/gem-fire-security/index.yml)
| GemFire | [`universal`](https://download.run.pivotal.io/gem-fire/index.yml)
| Groovy | [`universal`](https://download.run.pivotal.io/groovy/index.yml)
| JBoss AS | [`universal`](https://download.run.pivotal.io/jboss-as/index.yml)
| `jvmkill` | [`mountainlion`](https://download.run.pivotal.io/jvmkill/mountainlion/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/jvmkill/trusty/x86_64/index.yml)
| Log4j API | [`universal`](https://download.run.pivotal.io/log4j-api/index.yml)
| Log4j Core | [`universal`](https://download.run.pivotal.io/log4j-core/index.yml)
| Log4j Jcl | [`universal`](https://download.run.pivotal.io/log4j-jcl/index.yml)
| Log4j Jul | [`universal`](https://download.run.pivotal.io/log4j-jul/index.yml)
| Log4j Slf4j Impl | [`universal`](https://download.run.pivotal.io/log4j-slf4j-impl/index.yml)
| MariaDB JDBC | [`universal`](https://download.run.pivotal.io/mariadb-jdbc/index.yml)
| Memory Calculator | [`mountainlion`](https://download.run.pivotal.io/memory-calculator/mountainlion/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/memory-calculator/trusty/x86_64/index.yml)
| New Relic | [`universal`](https://download.run.pivotal.io/new-relic/index.yml)
| OpenJDK JRE | [`mountainlion`](https://download.run.pivotal.io/openjdk/mountainlion/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/openjdk/trusty/x86_64/index.yml)
| Play JPA Plugin | [`universal`](https://download.run.pivotal.io/play-jpa-plugin/index.yml)
| PostgreSQL JDBC | [`universal`](https://download.run.pivotal.io/postgresql-jdbc/index.yml)
| RedisStore | [`universal`](https://download.run.pivotal.io/redis-store/index.yml)
| Slf4j API | [`universal`](https://download.run.pivotal.io/slf4j-api/index.yml)
| Slf4j JDK14 | [`universal`](https://download.run.pivotal.io/slf4j-jdk14/index.yml)
| Spring Boot CLI | [`universal`](https://download.run.pivotal.io/spring-boot-cli/index.yml)
| tc Server| [`universal`](https://download.run.pivotal.io/tc-server/index.yml)
| Tomcat Access Logging Support | [`universal`](https://download.run.pivotal.io/tomcat-access-logging-support/index.yml)
| Tomcat Lifecycle Support | [`universal`](https://download.run.pivotal.io/tomcat-lifecycle-support/index.yml)
| Tomcat Logging Support | [`universal`](https://download.run.pivotal.io/tomcat-logging-support/index.yml)
| Tomcat | [`universal`](https://download.run.pivotal.io/tomcat/index.yml)
| TomEE Resource Configuration | [`universal`](https://download.run.pivotal.io/tomee-resource-configuration/index.yml)
| TomEE | [`universal`](https://download.run.pivotal.io/tomee/index.yml)
| YourKit | [`mountainlion`](https://download.run.pivotal.io/your-kit/mountainlion/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/your-kit/trusty/x86_64/index.yml)

## Contributing
[Pull requests][] are welcome; see the [contributor guidelines][] for details.

## License
The Builder is released under version 2.0 of the [Apache License][].

[Apache License]: http://www.apache.org/licenses/LICENSE-2.0
[contributor guidelines]: CONTRIBUTING.md
[Pull requests]: http://help.github.com/send-pull-requests
---

## Update Locations
This table shows locations to check for new releases of cached dependencies.  It is used primarily by Pivotal employees to keep the caches up to date.

| Dependency | Location
| ---------- | --------
| Auto Reconfiguration | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/auto-reconfiguration/maven-metadata.xml)
| Container Customizer | [`release`](https://repo.spring.io/webapp/#/artifacts/browse//search/quick/eyJzZWFyY2giOiJxdWljayIsInF1ZXJ5IjoiamF2YS1idWlsZHBhY2stY29udGFpbmVyLWN1c3RvbWl6ZXIiLCJzZWxlY3RlZFJlcG9zaXRvcmllcyI6W3sicmVwb0tleSI6ImxpYnMtcmVsZWFzZS1sb2NhbCIsInR5cGUiOiJsb2NhbCIsIl9pY29uQ2xhc3MiOiJpY29uIGljb24tbG9jYWwtcmVwbyJ9XX0=)
| GemFire Modules Tomcat 7| [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| GemFire Modules | [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| GemFire Security | [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| GemFire | [`release`](http://dist.gemstone.com.s3.amazonaws.com/)
| Groovy | [`release`](http://groovy-lang.org/download.html)
| JBoss AS | [`release`](http://www.jboss.org/jbossas/downloads)
| `jvmkill` | [`release`](https://github.com/cloudfoundry/jvmkill/releases)
| Log4j API | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.apache.logging.log4j%22%20AND%20a%3A%22log4j-api%22)
| Log4j Core | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.apache.logging.log4j%22%20AND%20a%3A%22log4j-core%22)
| Log4j Jcl | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.apache.logging.log4j%22%20AND%20a%3A%22log4j-jcl%22)
| Log4j Jul | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.apache.logging.log4j%22%20AND%20a%3A%22log4j-jul%22)
| Log4j Slf4j Impl | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.apache.logging.log4j%22%20AND%20a%3A%22log4j-slf4j-impl%22)
| MariaDB JDBC | [`release`](https://downloads.mariadb.org/client-java/)
| Memory Calculator | [`release`](https://github.com/cloudfoundry/java-buildpack-memory-calculator/releases)
| New Relic | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.newrelic.agent.java%22%20AND%20a%3A%22newrelic-agent%22)
| OpenJDK | [`oracle`](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [`jdk8u`](http://hg.openjdk.java.net/jdk8u/jdk8u))
| Play JPA Plugin | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/play-jpa-plugin/maven-metadata.xml)
| PostgreSQL JDBC | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.postgresql%22%20AND%20a%3A%22postgresql%22)
| RedisStore | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/com/gopivotal/manager/redis-store/maven-metadata.xml)
| Slf4j API | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.slf4j%22%20AND%20a%3A%22slf4j-api%22)
| Slf4j JDK14 | [`release`](http://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22org.slf4j%22%20AND%20a%3A%22slf4j-jdk14%22)
| Spring Boot CLI | [`release`](http://repo.springsource.org/release/org/springframework/boot/spring-boot-cli/)
| tc Server | [`release`](https://network.pivotal.io/products/pivotal-tcserver)
| Tomcat Access Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-access-logging-support/maven-metadata.xml)
| Tomcat Lifecycle Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-lifecycle-support/maven-metadata.xml)
| Tomcat Logging Support | [`release`](http://maven.gopivotal.com.s3.amazonaws.com/release/org/cloudfoundry/tomcat-logging-support/maven-metadata.xml)
| Tomcat | [`8.x`](http://tomcat.apache.org/download-80.cgi), [`7.x`](http://tomcat.apache.org/download-70.cgi), [`6.x`](http://tomcat.apache.org/download-60.cgi)
| TomEE Resource Configuration | [`release`](https://repo.spring.io/webapp/#/artifacts/browse//search/quick/eyJzZWFyY2giOiJxdWljayIsInF1ZXJ5IjoidG9tZWUtcmVzb3VyY2UtY29uZmlndXJhdGlvbiIsInNlbGVjdGVkUmVwb3NpdG9yaWVzIjpbeyJyZXBvS2V5IjoibGlicy1yZWxlYXNlLWxvY2FsIiwidHlwZSI6ImxvY2FsIiwiX2ljb25DbGFzcyI6Imljb24gaWNvbi1sb2NhbC1yZXBvIn1dfQ==)
| TomEE | [`release`](http://tomee.apache.org/downloads.html)
| YourKit | [`release`](https://www.yourkit.com/download)
