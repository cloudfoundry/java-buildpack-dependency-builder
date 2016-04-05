# $@: S3 invalidation paths without bucket
invalidate_cache() {
  if [[ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
    echo "CLOUDFRONT_DISTRIBUTION_ID must be set" >&2
    exit 1
  fi

  aws configure set preview.cloudfront true
  local invalidation_id=$(aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "$@" | jq -r '.Invalidation.Id')

  printf "Waiting for invalidation $invalidation_id"

  while [[ $(aws cloudfront get-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --id $invalidation_id | jq -r '.Invalidation.Status') == "InProgress" ]]; do
    printf "."
    sleep 10
  done

  echo
}

# $1: groupId
# $2: artifactId
# $3: version
# $4: suffix
gemfire_release_uri() {
  echo $(maven_uri 'dist.gemstone.com.s3.amazonaws.com/maven/release', $1, $2, $3, $4)
}

# $1: groupId
# $2: artifactId
# $3: version
# $4: suffix
maven_central_uri() {
  echo $(maven_uri 'http://repo1.maven.org/maven2', $1, $2, $3, $4)
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
  echo $(maven_uri 'http://repo.spring.io/release', $1, $2, $3, $4)
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

  curl --location $source | aws s3 cp - $target
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
  local download_uri="https://download.run.pivotal.io$3"

  echo "$version: $download_uri -> $index_path"

  (aws s3 cp $index_path - 2> /dev/null || echo '---') | printf -- "$(cat -)\n$version: $download_uri\n" | sort -u | aws s3 cp - $index_path --content-type 'text/x-yaml'

}
