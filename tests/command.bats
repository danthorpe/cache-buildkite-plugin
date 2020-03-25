#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export GIT_STUB_DEBUG=/dev/tty

@test "Pre-command copies down cache if it exists" {
  
  stub aws \
   "aws s3 cp s3://my-bucket/my-pipeline/my-label/my-directory.tar.gz . : echo cp s3"
  
  
  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_CACHE_CACHED_FOLDERS_0="my_directory/"
  run "$PWD/hooks/pre-command"
  
  assert_success
  assert_output --partial "cp s3 "
  
  unset BUILDKITE_PLUGIN_CACHE_CACHED_FOLDERS_0
  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_ORGANIZATION_SLUG
}

@test "Post-command copies cach to S3" {

  stub aws \
   "aws s3 cp my-directory.tar.gz s3://my-bucket/my-pipeline/my-label/my-directory.tar.gz : echo cp cache"

  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_CACHE_CACHED_FOLDERS_0="my_directory/"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "cp cache"

  unset BUILDKITE_PLUGIN_CACHE_CACHED_FOLDERS_0
  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_ORGANIZATION_SLUG
}
