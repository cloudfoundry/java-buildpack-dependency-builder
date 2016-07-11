cookies_file() {
  echo "cookies.txt"
}

# $@: S3 invalidation paths without bucket
invalidate_cache() {
  if [[ -z "$CLOUDFRONT_DISTRIBUTION_IDS" ]]; then
    return
  fi

  aws configure set preview.cloudfront true

  for cloudfront_distribution_id in $CLOUDFRONT_DISTRIBUTION_IDS; do
    local invalidation_id=$(aws cloudfront create-invalidation --distribution-id $cloudfront_distribution_id --paths "$@" | jq -r '.Invalidation.Id')

    printf "Waiting for invalidation $invalidation_id"

    while [[ $(aws cloudfront get-invalidation --distribution-id $cloudfront_distribution_id --id $invalidation_id | jq -r '.Invalidation.Status') == "InProgress" ]]; do
      printf "."
      sleep 10
    done

    echo
  done
}

# $1: groupId
# $2: artifactId
# $3: version
# $4: suffix
gemfire_release_uri() {
  echo $(maven_uri 'http://dist.gemstone.com.s3.amazonaws.com/maven/release' $1 $2 $3 $4)
}

# $1: groupId
# $2: artifactId
# $3: version
# $4: suffix
gopivotal_release_uri() {
  echo $(maven_uri 'http://maven.gopivotal.com.s3.amazonaws.com/release' $1 $2 $3 $4)
}

# $1: groupId
# $2: artifactId
# $3: version
# $4: suffix
maven_central_uri() {
  echo $(maven_uri 'https://repo1.maven.org/maven2' $1 $2 $3 $4)
}

# $1: prefix
# $2: groupId
# $3: artifactId
# $4: version
# $5: suffix
maven_uri() {
  local prefix=$1
  local group_id=$(echo $2 | tr '.' '/')
  local artifact_id=$3
  local version=$4
  local suffix=${5:-.jar}

  echo "$prefix/$group_id/$artifact_id/$version/$artifact_id-$version$suffix"
}

# $1: groupId
# $2: artifactId
# $3: version
# $4: suffix
spring_release_uri() {
  echo $(maven_uri 'https://repo.spring.io/release' $1 $2 $3 $4)
}

# $1: Download URI
# $2: S3 path without bucket
transfer_direct() {
  if [[ -z "$S3_BUCKET" ]]; then
    echo "S3_BUCKET must be set" >&2
    exit 1
  fi

  local source=$1
  local target="s3://$S3_BUCKET$2"

  echo "$source -> $target"

  curl --cookie $(cookies_file) --location --fail $source | aws s3 cp - $target
}

# $1: Download URI
# $2: S3 path without bucket
# $3: Pivnet API Key
transfer_from_pivnet_direct() {
  if [[ -z "$S3_BUCKET" ]]; then
    echo "S3_BUCKET must be set" >&2
    exit 1
  fi

  local source=$1
  local target="s3://$S3_BUCKET$2"
  local key=$3

  echo "$source -> $target"

  curl --cookie $(cookies_file) -X POST -H "Authorization: Token $key" --location --fail $source | aws s3 cp - $target
}

# $1: Download URI
# $2: Destination path
transfer_to_file() {
  local source=$1
  local target=$2

  echo "$source -> $target"

  curl --cookie $(cookies_file) --location --fail $source -o $target
}

# $1: Source path
# $2: S3 path without bucket
transfer_to_s3() {
  if [[ -z "$S3_BUCKET" ]]; then
    echo "S3_BUCKET must be set" >&2
    exit 1
  fi

  local source=$1
  local target="s3://$S3_BUCKET$2"

  echo "$source -> $target"

  aws s3 cp --quiet $source $target
}

# $1: S3 index path without bucket
# $2: Version
# $3: S3 artifact path without bucket
update_index() {
  if [[ -z "$S3_BUCKET" ]]; then
    echo "S3_BUCKET must be set" >&2
    exit 1
  fi

  local index_path="s3://$S3_BUCKET$1"
  local version=$2
  local download_uri="https://java-buildpack.cloudfoundry.org$3"

  echo "$version: $download_uri -> $index_path"

  (aws s3 cp $index_path - 2> /dev/null || echo '---') | printf -- "$(cat -)\n$version: $download_uri\n" | sort -u | aws s3 cp - $index_path --content-type 'text/x-yaml'
}
