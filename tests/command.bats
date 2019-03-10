#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export GIT_STUB_DEBUG=/dev/tty

@test "Pre-command restores caches" {
  
  export BUILDKITE_PLUGIN_CACHE_CACHE_KEY="v1-cache-key"
  run "$PWD/hooks/pre-command"
  
  assert_success
  assert_output --partial "Restoring Cache: v1-cache-key"
  
  unset BUILDKITE_PLUGIN_CACHE_CACHE_KEY
}

@test "Post-command syncs artifacts with a single path" {

  export BUILDKITE_PLUGIN_CACHE_PATHS="Pods"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Syncing Pods"

  unset BUILDKITE_PLUGIN_CACHE_PATHS
}
