#!/usr/bin/env bash
set -euo pipefail

echo "Preparing Rust build environment"

# Ensure repo path is safe
git config --global --add safe.directory "$(pwd)"

# Determine sudo availability (works inside and outside containers)
if [[ "$(id -u)" -eq 0 ]]; then
	SUDO=""
else
	SUDO="sudo"
fi

echo "Installing additional packages: ${ADDITIONAL_PACKAGES}"
if [[ -n "${ADDITIONAL_PACKAGES}" ]]; then
	$SUDO apt-get install -yqq --no-install-recommends "${ADDITIONAL_PACKAGES}"
else
	echo "No additional packages specified. Skipping installation."
fi

echo "Setting up build environment"
echo "CARGO_HOME = ${HOME}/${CARGO_HOME}"
mkdir -p "${HOME}/${CARGO_HOME}"

# Decide public/private mode based on presence of private key
if [[ -z "${CRATE_REGISTRY_SSH_PRIVKEY:-}" ]]; then
	echo "No private registry SSH key provided. Configuring for public builds."
	export CRATE_REGISTRY_NAME="crates-io"
else
	echo "Private registry credentials detected. Configuring SSH and private registry access."
	USER_NAME="$(whoami)"
	SSH_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
	ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null
	echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >> "$GITHUB_ENV"
	ssh-add -vvv - <<< "${CRATE_REGISTRY_SSH_PRIVKEY}"$'\n'
	mkdir -p "$SSH_HOME/.ssh"
	{
		ssh-keyscan -H ssh.shipyard.rs
	} >> "$SSH_HOME/.ssh/known_hosts"
fi

cat << EOF >> "${HOME}/${CARGO_HOME}/config.toml"
[net]
git-fetch-with-cli = true
EOF

if [ "$CRATE_REGISTRY_NAME" != "crates-io" ]; then
	cat << EOF >> "${HOME}/${CARGO_HOME}/config.toml"
[registries.${CRATE_REGISTRY_NAME}]
index = "${CRATE_REGISTRY_INDEX_URL}"
EOF
fi

echo "CARGO_HOME=${HOME}/${CARGO_HOME}" >> "$GITHUB_ENV"

# Persist registry settings for subsequent GitHub Actions steps
echo "CRATE_REGISTRY_NAME=${CRATE_REGISTRY_NAME}" >> "$GITHUB_ENV"
if [[ -n "${CRATE_REGISTRY_INDEX_URL:-}" ]]; then
	echo "CRATE_REGISTRY_INDEX_URL=${CRATE_REGISTRY_INDEX_URL}" >> "$GITHUB_ENV"
fi

echo "Preparations finished"
