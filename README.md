# Cache Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to restore and save directories to and from an s3 bucket.

- Built off of a sha256sum of the tar of the specified cached diectories into a pipeline specific s3 bucket
  - give example
- When pushing back to s3, will use the [--delete](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html) option when syncing which removes all contents from the destination that do not match the source.

Example: `aws s3 sync . s3://mybucket --delete`

## Example

```yml
steps:
  - label: cache_s3
    plugins:
    - chef/cache#v1.0.0:
        cached_folders:
          - .vendor/
```

## Configuration

### `cached_folders` (required)

The directory which you would like saved to s3 as well as where you would like s3 to pull contents into.

Example: `.vendor/`
