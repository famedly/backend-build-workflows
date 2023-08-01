# Docker action

To use the docker build, you can follow the example in [test](./.github/workflows/docker-test.yml)

We have two main use cases

## Simple service with no subfolders

```yaml
jobs:
  publish:
    uses: ./.github/workflows/docker-backend.yml
    secrets: inherit
```

should take care of everything

## Complex service with subfolders

```yaml
jobs:
  publish:
    uses: ./.github/workflows/docker-backend.yml
    with:
      path: ./foo/bar # path to where the Dockerfile resides
      name: bar # name of service
    secrets: inherit
```