# Docker action

To use the docker build, you can follow the example in [test](./.github/workflows/docker-test.yml)

We have two main use cases

## Simple service with no subfolders

```yaml
jobs:
  publish:
    uses: ./.github/workflows/docker-backend.yml
    secrets: inherit
    with:
      name: bar # name of service
```

## GitHub Actions variables and secrets (v4)

### Variables

| Name | Where it is consumed | Required | Purpose |
| --- | --- | --- | --- |
| `OCI_REGISTRY_USER` | docker-backend: default value for workflow input `inputs.oci_registry_user` | Optional | Username for logging into the target OCI registry. |
| `CRATE_REGISTRY_NAME` | rust-prepare: default value for action input `inputs.crate_registry_name` | Optional | Name of the crate registry to configure (e.g., `famedly` or `crates-io`). |
| `CRATE_REGISTRY_INDEX_URL` | rust-prepare: default value for action input `inputs.crate_registry_index_url`; docker-backend: passed to Docker as build-arg `CARGO_REGISTRIES_FAMEDLY_INDEX` | Optional | URL of the crate registry index used by the action and inside Docker builds. |

### Secrets

| Name | Used by | Required | Purpose |
| --- | --- | --- | --- |
| `CRATE_REGISTRY_SSH_PRIVKEY` | `.github/workflows/docker-backend.yml`, `.github/workflows/publish-crate.yml`, `.github/workflows/rust-workflow.yml` | Required in `publish-crate`; optional elsewhere | SSH private key for accessing the private crate registry index. |
| `CRATE_REGISTRY_AUTH_TOKEN` | `.github/workflows/publish-crate.yml` | Required for publish-crate workflow | Auth token used when publishing crates to the configured registry. |
| `OCI_REGISTRY_PASSWORD` | `.github/workflows/docker-backend.yml` | Optional (falls back to `GITHUB_TOKEN`) | Password for logging into the target OCI registry when pushing images. |
| `CODECOV_TOKEN` | `.github/workflows/rust-workflow.yml` | Optional | Token for uploading coverage and test results to Codecov. |
| `GITHUB_TOKEN` | `.github/workflows/docker-backend.yml` | Implicit (provided by GitHub) | Fallback token for OCI login when `OCI_REGISTRY_PASSWORD` is not set. |

should take care of everything

## Complex service with subfolders

```yaml
jobs:
  publish:
    uses: ./.github/workflows/docker-backend.yml
    secrets: inherit
    with:
      path: ./foo/bar # path to where the Dockerfile resides
      name: bar # name of service
```

## Migration guide: v3 → v4

### Summary of breaking changes
- Inputs, secrets and env vars have been renamed for clarity and consistency.
- GitHub SSH authentication was removed, only the private Famedly crate registry via SSH is supported. Cargo Git dependencies are *no longer supported*!
- The `rust-prepare` action is consolidated into a single `prepare.sh` and auto-configures public vs private registry access.
- All remaining GitLab references have been removed.

### Composite action: `.github/actions/rust-prepare`

| v3 (old) | v4 (new) | Notes |
| --- | --- | --- |
| `famedly_crates_registry` | `crate_registry_name` ||
| `famedly_crates_registry_index` | `crate_registry_index_url` ||
| (new) | `crate_registry_ssh_privkey` | SSH private key for the private registry index. Optional; when omitted, builds use `crates-io`. |
| `FAMEDLY_CRATES_REGISTRY` | `CRATE_REGISTRY_NAME` ||
| `FAMEDLY_CRATES_REGISTRY_INDEX` | `CRATE_REGISTRY_INDEX_URL` ||

Behavioural notes:
- If `famedly_crate_registry_ssh_privkey` is not provided, the action configures `CARGO_HOME` for public `crates-io` only.
- Use the action via a branch ref: `famedly/backend-build-workflows/.github/actions/rust-prepare@v4`.

### Workflow: `.github/workflows/docker-backend.yml`
### Renamed inputs and environment variables
| v3 (old) | v4 (new) |
| --- | --- |
| `inputs.registry_user` | `inputs.oci_registry_user` |
| `secrets.CI_SSH_PRIVATE_KEY` | `secrets.CRATE_REGISTRY_SSH_PRIVKEY` |
| `secrets.registry_password` | `secrets.OCI_REGISTRY_PASSWORD` |
| `REGISTRY_SNAPSHOTS/RELEASES/OSS` | `OCI_REGISTRY_SNAPSHOTS/RELEASES/OSS` |
| `REGISTRY` | `OCI_REGISTRY` |

### Workflow: `.github/workflows/publish-crate.yml`
#### Renamed inputs and secrets

| v3 (old) | v4 (new) |
| --- | --- |
| `uses: famedly/backend-build-workflows/.github/actions/rust-prepare@main` | `@v4` |
| `secrets.CI_SSH_PRIVATE_KEY` | `secrets.CRATE_REGISTRY_SSH_PRIVKEY` |
| `secrets.registry-auth-token` | `secrets.CRATE_REGISTRY_AUTH_TOKEN` |
| `with.famedly_crates_registry` | `with.crate_registry_name` | 
| `with.famedly_crates_registry_index` | `with.crate_registry_index_url` |
### Workflow: `.github/workflows/rust-workflow.yml`
#### Renamed inputs

| v3 (old) | v4 (new) |
| --- | --- |
| `inputs.runs-on` | `inputs.runs_on` |
| `inputs.run-doctests` | `inputs.run_doctests` |
| `secrets.CI_SSH_PRIVATE_KEY` | `secrets.CRATE_REGISTRY_SSH_PRIVKEY` |
| `secrets.CODECOV_TOKEN` | `secrets.CODECOV_TOKEN` |
| `uses: ./.github/actions/rust-prepare` | `uses: ./.github/actions/rust-prepare@v4` |
### Required user actions
- Update all `uses:` references to the v4 tag.
- Rename inputs, secrets and env vars as per the tables above.
- If you rely on private crates in Famedly’s registry, pass `famedly_crate_registry_ssh_privkey` and the registry name/index. Otherwise omit it to use `crates-io`.
- If you referenced `REGISTRY` variables in custom steps, switch to `OCI_REGISTRY` equivalents.

### Minimal examples (v4)

Prepare rust action, with custom crate registry:

```yaml
- uses: famedly/backend-build-workflows/.github/actions/rust-prepare@v4
  with:
    crate_registry_name: "${{ vars.CRATE_REGISTRY_NAME }}"
    crate_registry_index_url: "${{ vars.CRATE_REGISTRY_INDEX_URL }}"
    crate_registry_ssh_privkey: "${{ secrets.CRATE_REGISTRY_SSH_PRIVKEY }}"
```

Publish crates workflow call:

```yaml
jobs:
  publish:
    uses: famedly/backend-build-workflows/.github/workflows/publish-crate.yml@v4
    secrets:
      CRATE_REGISTRY_SSH_PRIVKEY: "${{ secrets.CRATE_REGISTRY_SSH_PRIVKEY }}"
      CRATE_REGISTRY_AUTH_TOKEN: "${{ secrets.CRATE_REGISTRY_AUTH_TOKEN }}"
    with:
```

Docker backend workflow call:

```yaml
jobs:
  publish:
    uses: famedly/backend-build-workflows/.github/workflows/docker-backend.yml@v4
    with:
      targets: "service-a,service-b"
      oci_registry_user: "${{ vars.OCI_REGISTRY_USER }}"
    secrets:
      CRATE_REGISTRY_SSH_PRIVKEY: "${{ secrets.CRATE_REGISTRY_SSH_PRIVKEY }}"
      OCI_REGISTRY_PASSWORD: "${{ secrets.OCI_REGISTRY_PASSWORD }}"
```
