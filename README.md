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
| `famedly_crates_registry` | `famedly_crate_registry` ||
| `famedly_crates_registry_index` | `famedly_crate_registry_index_url` ||
| (new) | `famedly_crate_registry_ssh_privkey` | SSH private key for the private registry index. Optional; when omitted, builds use `crates-io`. |
| `FAMEDLY_CRATES_REGISTRY` | `FAMEDLY_CRATE_REGISTRY` ||
| `FAMEDLY_CRATES_REGISTRY_INDEX` | `FAMEDLY_CRATE_REGISTRY_INDEX` ||

Behavioural notes:
- If `famedly_crate_registry_ssh_privkey` is not provided, the action configures `CARGO_HOME` for public `crates-io` only.
- Use the action via a branch ref: `famedly/backend-build-workflows/.github/actions/rust-prepare@v4`.

### Workflow: `.github/workflows/docker-backend.yml`
### Renamed inputs and environment variables
| v3 (old) | v4 (new) |
| --- | --- | --- |
| `inputs.registry_user` | `inputs.oci_registry_user` |
| `secrets.CI_SSH_PRIVATE_KEY` | `secrets.famedly_crate_registry_ssh_privkey` |
| `secrets.registry_password` | `secrets.oci_registry_password` |
| `REGISTRY_SNAPSHOTS/RELEASES/OSS` | `OCI_REGISTRY_SNAPSHOTS/RELEASES/OSS` |
| `REGISTRY` | `OCI_REGISTRY` |

### Workflow: `.github/workflows/publish-crate.yml`
#### Renamed inputs and secrets

| v3 (old) | v4 (new) |
| --- | --- | --- |
| `uses: famedly/backend-build-workflows/.github/actions/rust-prepare@main` | `@v4` |
| `secrets.CI_SSH_PRIVATE_KEY` | `secrets.famedly_crate_registry_ssh_privkey` |
| `secrets.registry-auth-token` | `secrets.registry_auth_token` |
| `with.famedly_crates_registry` | `with.famedly_crate_registry` | 
| `with.famedly_crates_registry_index` | `with.famedly_crate_registry_index_url` |
### Workflow: `.github/workflows/rust-workflow.yml`
#### Renamed inputs

| v3 (old) | v4 (new) |
| --- | --- | --- |
| `secrets.CI_SSH_PRIVATE_KEY` | `secrets.famedly_crate_registry_ssh_privkey` |
| `secrets.CODECOV_TOKEN` | `secrets.codecov_token` |
| `uses: ./.github/actions/rust-prepare` | `uses: ./.github/actions/rust-prepare@v4` |
### Required user actions
- Update all `uses:` references to the v4 tag.
- Rename inputs, secrets and env vars as per the tables above.
- If you rely on private crates in Famedly’s registry, pass `famedly_crate_registry_ssh_privkey` and the registry name/index. Otherwise omit it to use `crates-io`.
- If you referenced `REGISTRY` variables in custom steps, switch to `OCI_REGISTRY` equivalents.

### Minimal examples (v4)

Rust prepare in a job:

```yaml
- uses: famedly/backend-build-workflows/.github/actions/rust-prepare@v4
  with:
    famedly_crate_registry_name: famedly
    famedly_crate_registry_index_url: ssh://git@ssh.shipyard.rs/famedly/crate-index.git
    famedly_crate_registry_ssh_privkey: ${{ secrets.famedly_crate_registry_ssh_privkey }}
```

Publish crates workflow call:

```yaml
jobs:
  publish:
    uses: famedly/backend-build-workflows/.github/workflows/publish-crate.yml@v4
    secrets:
      famedly_crate_registry_ssh_privkey: ${{ secrets.famedly_crate_registry_ssh_privkey }}
      famedly_crate_registry_auth_token: ${{ secrets.famedly_crate_registry_auth_token }}
    with:
      famedly_crate_registry_name: famedly
      famedly_crate_registry_index_url: ssh://git@ssh.shipyard.rs/famedly/crate-index.git
```

Docker backend workflow call:

```yaml
jobs:
  publish:
    uses: famedly/backend-build-workflows/.github/workflows/docker-backend.yml@v4
    with:
      targets: service-a,service-b
      oci_registry_user: ${{ vars.OCI_REGISTRY_USER }}
    secrets:
      famedly_crate_registry_ssh_privkey: ${{ secrets.famedly_crate_registry_ssh_privkey }}
      oci_registry_password: ${{ secrets.oci_registry_password }}
```

