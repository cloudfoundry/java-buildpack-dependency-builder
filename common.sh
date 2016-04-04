# $@: S3 invalidation paths without bucket
invalidate_cache() {
  if [[ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]]; then
    echo "CLOUDFRONT_DISTRIBUTION_ID must be set" >&2
    exit 1
  fi

  aws configure set preview.cloudfront true
  INVALIDATION_ID=$(aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "$@" | jq -r '.Invalidation.Id')

  printf "Waiting for invalidation $INVALIDATION_ID"

  while [[ $(aws cloudfront get-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --id $INVALIDATION_ID | jq -r '.Invalidation.Status') == "InProgress" ]]; do
    printf "."
    sleep 10
  done

  echo
}

# $1: Download URI
# $2: S3 path without bucket
transfer_direct() {
  if [[ -z "$S3_BUCKET" ]]; then
    echo "S3_BUCKET must be set" >&2
    exit 1
  fi

  SOURCE=$1
  TARGET="s3://$S3_BUCKET$2"

  echo "$SOURCE -> $TARGET"

  curl --location $SOURCE | aws s3 cp - $TARGET
}

# $1: S3 index path without bucket
# $2: Version
# $3: S3 artifact path without bucket
update_index() {
  if [[ -z "$S3_BUCKET" ]]; then
    echo "S3_BUCKET must be set" >&2
    exit 1
  fi

  INDEX_PATH="s3://$S3_BUCKET$1"
  VERSION=$2
  DOWNLOAD_URI="https://download.run.pivotal.io$3"

  echo "$VERSION: $DOWNLOAD_URI -> $INDEX_PATH"

  (aws s3 cp $INDEX_PATH - 2> /dev/null || echo '---') | printf -- "$(cat -)\n$VERSION: $DOWNLOAD_URI\n" | aws s3 cp - $INDEX_PATH --content-type 'text/x-yaml'

}
