# Cache Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to restore and save 
directories by cache keys. For example, use the checksum of a `.resolved` or `.lock` file 
to restore/save built dependencies between independent builds, not just jobs. 

## S3 Buckets

This plugin uses AWS S3 sync to cache the paths into a bucket as defined by environment 
variables defined in your agent. 

```bash
export BUILDKITE_PLUGIN_CACHE_S3_BUCKET_NAME="my-unique-s3-bucket-name"
export BUILDKITE_PLUGIN_CACHE_S3_PROFILE="my-s3-profile"
```

## Restore & Save Caches

```yml
steps:
  - plugins:
    - danthorpe/cache#v1.0.0:
        cache_key: "v1-cache-{{ checksum 'Podfile.lock' }}"
        paths: [ "Pods/", "Rome/" ]
```