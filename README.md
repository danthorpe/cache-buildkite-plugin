# Cache Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to restore and save 
directories by cache keys. For example, use the checksum of a `.resolved` or `.lock` file 
to restore/save built dependencies between independent builds, not just jobs. 