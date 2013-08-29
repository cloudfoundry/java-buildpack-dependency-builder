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
| Auto Reconfiguration | <http://download.pivotal.io.s3.amazonaws.com/auto-reconfiguration/index.yml>
| Groovy | <http://download.pivotal.io.s3.amazonaws.com/groovy/index.yml>
| MySQL JDBC | <http://download.pivotal.io.s3.amazonaws.com/mysql-jdbc/index.yml>
| New Relic | <http://download.pivotal.io.s3.amazonaws.com/new-relic/index.yml>
| OpenJDK | <http://download.pivotal.io.s3.amazonaws.com/openjdk/lucid/x86_64/index.yml>
| Play JPA Plugin | <http://download.pivotal.io.s3.amazonaws.com/play-jpa-plugin/index.yml>
| PostgreSQL JDBC | <http://download.pivotal.io.s3.amazonaws.com/postgresql-jdbc/index.yml>
| Spring Boot CLI| <http://download.pivotal.io.s3.amazonaws.com/spring-boot-cli/index.yml>
| tc Server| <http://download.pivotal.io.s3.amazonaws.com/tc-server/index.yml>
| Tomcat | <http://download.pivotal.io.s3.amazonaws.com/tomcat/index.yml>


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
