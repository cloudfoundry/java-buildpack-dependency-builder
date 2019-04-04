set -euo pipefail

VERSION=$(cat mariadb-jdbc-archives/version)

cp mariadb-jdbc-archives/mariadb-java-client-*.jar repository/mariadb-jdbc-$VERSION.jar
cp mariadb-jdbc-archives/version repository/version
