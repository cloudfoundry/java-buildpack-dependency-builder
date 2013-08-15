# Java Buildpack Dependency Builders
[![Build Status](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder.png?branch=master)](https://travis-ci.org/cloudfoundry/java-buildpack-dependency-builder)
[![Dependency Status](https://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder.png)](http://gemnasium.com/cloudfoundry/java-buildpack-dependency-builder)

This project automates the building and publication of Java Buildpack dependency artifacts.

## Usage
To run the builder, do the following:

```bash
bundle install
bundle exec bin/build [DEPENDENCY] [OPTIONS]
```

### Credentials
Pivotal employees should contact Ben Hale for AWS credentials if they have not already been issued.

## Available Artifacts
The list of available versions for each dependency can be found at the following locations.

| Dependency | Location
| ---------- | ---------
| Auto Reconfiguration | <https://download.pivotal.io.s3.amazonaws.com/auto-reconfiguration/lucid/x86_64/index.yml>
| Groovy | <https://download.pivotal.io.s3.amazonaws.com/groovy/lucid/x86_64/index.yml>
| MySQL JDBC | <https://download.pivotal.io.s3.amazonaws.com/mysql-jdbc/lucid/x86_64/index.yml>
| New Relic | <https://download.pivotal.io.s3.amazonaws.com/new-relic/lucid/x86_64/index.yml>
| OpenJDK | <https://download.pivotal.io.s3.amazonaws.com/openjdk/lucid/x86_64/index.yml>
| Play JPA Plugin | <https://download.pivotal.io.s3.amazonaws.com/play-jpa-plugin/lucid/x86_64/index.yml>
| PostgreSQL JDBC | <https://download.pivotal.io.s3.amazonaws.com/postgresql-jdbc/lucid/x86_64/index.yml>
| Spring Boot CLI| <https://download.pivotal.io.s3.amazonaws.com/spring-boot-cli/lucid/x86_64/index.yml>
| Tomcat | <https://download.pivotal.io.s3.amazonaws.com/tomcat/lucid/x86_64/index.yml>


## Running Tests
To run the tests, do the following:

```bash
bundle install
bundle exec rake
```

## Contributing
[Pull requests][] are welcome; see the [contributor guidelines][] for details.

[Pull requests]: http://help.github.com/send-pull-requests
[contributor guidelines]: CONTRIBUTING.md

## License
The Builder is released under version 2.0 of the [Apache License][].

[Apache License]: http://www.apache.org/licenses/LICENSE-2.0
