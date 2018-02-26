# Java Buildpack Dependency Builders
This project automates the building and publication of Java Buildpack dependency artifacts.

**NOTE:**  OpenJDK is the only dependency that is actually built via this repository.  For the rest of the dependencies, this repository serves as the automation of caching them in the Java Buildpack's respository.

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
| Client Certificate Mapper | [`universal`](https://java-buildpack.cloudfoundry.org/client-certificate-mapper/index.yml)
| Container Customizer | [`universal`](https://java-buildpack.cloudfoundry.org/container-customizer/index.yml)
| Container Security Provider | [`universal`](https://java-buildpack.cloudfoundry.org/container-security-provider/index.yml)
| Google Stackdriver Debugger | [`mountainlion`](https://java-buildpack.cloudfoundry.org/google-stackdriver-debugger/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/google-stackdriver-debugger/trusty/x86_64/index.yml)
| Groovy | [`universal`](https://java-buildpack.cloudfoundry.org/groovy/index.yml)
| JaCoCo | [`universal`](https://java-buildpack.cloudfoundry.org/jacoco/index.yml)
| `jvmkill` | [`mountainlion`](https://java-buildpack.cloudfoundry.org/jvmkill/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/jvmkill/trusty/x86_64/index.yml)
| MariaDB JDBC | [`universal`](https://java-buildpack.cloudfoundry.org/mariadb-jdbc/index.yml)
| Memory Calculator | [`mountainlion`](https://java-buildpack.cloudfoundry.org/memory-calculator/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/memory-calculator/trusty/x86_64/index.yml)
| Metric Writer | [`universal`](https://java-buildpack.cloudfoundry.org/metric-writer/index.yml)
| New Relic | [`universal`](https://download.run.pivotal.io/new-relic/index.yml)
| OpenJDK JDK | [`mountainlion`](https://java-buildpack.cloudfoundry.org/openjdk-jdk/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/openjdk-jdk/trusty/x86_64/index.yml)
| OpenJDK JRE | [`mountainlion`](https://java-buildpack.cloudfoundry.org/openjdk/mountainlion/x86_64/index.yml), [`trusty`](https://java-buildpack.cloudfoundry.org/openjdk/trusty/x86_64/index.yml)
| PostgreSQL JDBC | [`universal`](https://java-buildpack.cloudfoundry.org/postgresql-jdbc/index.yml)
| RedisStore | [`universal`](https://java-buildpack.cloudfoundry.org/redis-store/index.yml)
| SkyWalking | [`universal`](https://java-buildpack.cloudfoundry.org/sky-walking/index.yml)
| Spring Boot CLI | [`universal`](https://java-buildpack.cloudfoundry.org/spring-boot-cli/index.yml)
| tc Server| [`universal`](https://download.run.pivotal.io/tc-server/index.yml)
| Tomcat Access Logging Support | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat-access-logging-support/index.yml)
| Tomcat Lifecycle Support | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat-lifecycle-support/index.yml)
| Tomcat Logging Support | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat-logging-support/index.yml)
| Tomcat | [`universal`](https://java-buildpack.cloudfoundry.org/tomcat/index.yml)
| TomEE Resource Configuration | [`universal`](https://java-buildpack.cloudfoundry.org/tomee-resource-configuration/index.yml)
| TomEE | [`universal`](https://java-buildpack.cloudfoundry.org/tomee/index.yml)
| Wildfly | [`universal`](https://java-buildpack.cloudfoundry.org/wildfly/index.yml)
| YourKit | [`mountainlion`](https://download.run.pivotal.io/your-kit/mountainlion/x86_64/index.yml), [`trusty`](https://download.run.pivotal.io/your-kit/trusty/x86_64/index.yml)

## Contributing
[Pull requests][p] are welcome; see the [contributor guidelines][g] for details.

## License
The Builder is released under version 2.0 of the [Apache License][a].

[a]: http://www.apache.org/licenses/LICENSE-2.0
[c]: https://aws.amazon.com/cli/
[g]: CONTRIBUTING.md
[p]: http://help.github.com/send-pull-requests

---

## Update Locations
This table shows locations to check for new releases of cached dependencies.  It is used primarily by Pivotal employees to keep the caches up to date.

| Dependency | Location
| ---------- | --------
| OpenJDK | [`oracle`](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [`jdk8u`](http://hg.openjdk.java.net/jdk8u/jdk8u)
