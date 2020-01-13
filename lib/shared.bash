# shellcheck disable=SC2001
# Gets the cache key from env vars and evaluates `checksum` commands
# e.g. "v1-gemfile-{{ checksum Gemfile.lock }}" gets evaluated to "v1-gemfile-$(shasum Gemfile.lock)"
function get_cache_key() {
  cache_key_prefix=$(echo "$BUILDKITE_PLUGIN_CACHE_CACHE_KEY" | sed -e 's/{.*//')
  template_value=$(echo "$BUILDKITE_PLUGIN_CACHE_CACHE_KEY" | sed -e 's/^[^\{{]*[^A-Za-z]*//' -e 's/.}}.*$//' | tr -d \' | tr -d \")

  if [[ $template_value == *"checksum"* ]]; then
    checksum_argument=$(echo "$template_value" | sed -e 's/checksum*//')
    function=${template_value/"checksum"/"shasum"}
    result=$($function | tr -d "$checksum_argument")
    cache_key="$cache_key_prefix$result"
  else
    cache_key=$BUILDKITE_PLUGIN_CACHE_CACHE_KEY
  fi
  echo "$cache_key"
}
