# Backend team CI actions and reusable workflows

This repository currently offers the following workflows:

## docker-publish

Publishes a docker image for a service to the correct docker registry.

### Examples

We have two main use cases:

#### Simple service with no subfolders

```yaml
jobs:
  publish:
    uses: ./.github/workflows/docker-backend.yml
    secrets: inherit
    with:
      name: bar # name of service
```

should take care of everything

#### Complex service with subfolders

```yaml
jobs:
  publish:
    uses: ./.github/workflows/docker-backend.yml
    secrets: inherit
    with:
      path: ./foo/bar # path to where the Dockerfile resides
      name: bar # name of service
```

See also the [test case](.github/workflows/~test-docker-backend.yml).

## rust-tests

Runs basic rust lint checks, followed by the repository's test suite
(using `cargo nextest`), and reports code test coverage.

### Using docker containers for test environments

We pretty regularly use `docker compose` to set up test environments,
using `cargo nextest`'s startup script features.

Since the CI environment uses a docker container, this requires a bit
of trickery. The CI env mounts the host docker socket, which *allows*
using docker containers, however to set up volume bind mounts paths
need to be set to their *host* location.

As such, these invocations need to be changed a bit in CI. `cargo
nextest` allows adding scripts in specific profiles, this can be used
to add a setup step to the `ci` profile (though *not* to override the
default scripts). Order is determined by the order in which scripts
are defined.

This sed line may be helpful:

```
sed 's|./|/home/runner/work/<repo>/<repo>|g' -i tests/environment/docker-compose.yaml
```

### Examples

#### Common, simple use case

```yaml
jobs:
  rust-tests:
    uses: famedly/backend-build-workflows@v2
    secrets: inherit
```

#### Specifying various additional arguments

See also the [test case](.github/workflows/~test-rust-workflow.yml)
