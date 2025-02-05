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

### Examples

#### Common, simple use case

```yaml
jobs:
  rust-tests:
    uses: famedly/backend-build-workflows@v2
    secrets: inherit
```

#### Allow `cargo nextest` to spin up docker containers

```yaml
jobs:
  rust-tests:
    uses: famedly/backend-build-workflows@v2
    secrets: inherit
```

#### Specifying various additional arguments

See also the [test case](.github/workflows/~test-rust-workflow.yml)
