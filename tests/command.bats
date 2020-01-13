#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export GIT_STUB_DEBUG=/dev/tty

@test "Pre-command restores cache with basic key" {
  stub aws '* : echo aws $@'
  stub tar '* : echo tar $@'

  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME="my-bucket"
  export BUILDKITE_PLUGIN_CACHE_S3_PROFILE="my-profile"
  export BUILDKITE_PLUGIN_CACHE_CACHE_KEY="v1-cache-key"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "aws s3 cp s3://my-bucket/my-org/my-pipeline/v1-cache-key/cache.tar.gz /tmp"
  assert_output --regexp "tar -xzf .*/cache.tar.gz"

  unset BUILDKITE_PLUGIN_CACHE_CACHE_KEY
  unset BUILDKITE_PLUGIN_CACHE_S3_PROFILE
  unset BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME
  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_ORGANIZATION_SLUG
}

@test "Post-command syncs artifacts" {
  stub aws '* : echo aws $@'
  # hacky way to unstub as unstub doesn't work
  stub tar '* : busybox tar $@ && ls $2'

  export BUILDKITE_COMMAND_EXIT_STATUS=0
  export BUILDKITE_PLUGIN_CACHE_DEBUG=true
  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME="my-bucket"
  export BUILDKITE_PLUGIN_CACHE_S3_PROFILE="my-profile"
  export BUILDKITE_PLUGIN_CACHE_CACHE_KEY="v1-cache-key"
  export BUILDKITE_PLUGIN_CACHE_PATHS_0="hooks"
  export BUILDKITE_PLUGIN_CACHE_PATHS_1="tests"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Compressing cache for v1-cache-key"
  assert_output --regexp "/tmp/.*/cache.tar.gz"
  assert_output --regexp "aws s3 cp .* s3://my-bucket/my-org/my-pipeline/v1-cache-key/cache.tar.gz"

  unset BUILDKITE_PLUGIN_CACHE_PATHS_1
  unset BUILDKITE_PLUGIN_CACHE_PATHS_0
  unset BUILDKITE_PLUGIN_CACHE_CACHE_KEY
  unset BUILDKITE_PLUGIN_CACHE_S3_PROFILE
  unset BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME
  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_ORGANIZATION_SLUG
  unset BUILDKITE_COMMAND_EXIT_STATUS
}

@test "Post-command skips uploading if cache was restored" {
  stub aws '* : echo aws $@'

  export BUILDKITE_COMMAND_EXIT_STATUS=0
  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME="my-bucket"
  export BUILDKITE_PLUGIN_CACHE_S3_PROFILE="my-profile"
  export BUILDKITE_PLUGIN_CACHE_CACHE_KEY="v1-cache-key"
  export BUILDKITE_PLUGIN_CACHE_RESTORED=":v1-cache-key:"
  export BUILDKITE_PLUGIN_CACHE_PATHS_0="Pods"
  export BUILDKITE_PLUGIN_CACHE_PATHS_1="Things"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Not uploading new cache - it was restored"

  unset BUILDKITE_PLUGIN_CACHE_PATHS_1
  unset BUILDKITE_PLUGIN_CACHE_PATHS_0
  unset BUILDKITE_PLUGIN_CACHE_RESTORED
  unset BUILDKITE_PLUGIN_CACHE_CACHE_KEY
  unset BUILDKITE_PLUGIN_CACHE_S3_PROFILE
  unset BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME
  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_ORGANIZATION_SLUG
  unset BUILDKITE_COMMAND_EXIT_STATUS
}

@test "Post-command skips uploading if command errored" {
  stub aws '* : echo aws $@'

  export BUILDKITE_COMMAND_EXIT_STATUS=1
  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME="my-bucket"
  export BUILDKITE_PLUGIN_CACHE_S3_PROFILE="my-profile"
  export BUILDKITE_PLUGIN_CACHE_CACHE_KEY="v1-cache-key"
  export BUILDKITE_PLUGIN_CACHE_RESTORED=":v1-cache-key:"
  export BUILDKITE_PLUGIN_CACHE_PATHS_0="Pods"
  export BUILDKITE_PLUGIN_CACHE_PATHS_1="Things"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Command failed, not uploading cache"

  unset BUILDKITE_PLUGIN_CACHE_PATHS_1
  unset BUILDKITE_PLUGIN_CACHE_PATHS_0
  unset BUILDKITE_PLUGIN_CACHE_RESTORED
  unset BUILDKITE_PLUGIN_CACHE_CACHE_KEY
  unset BUILDKITE_PLUGIN_CACHE_S3_PROFILE
  unset BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME
  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_ORGANIZATION_SLUG
  unset BUILDKITE_COMMAND_EXIT_STATUS
}

