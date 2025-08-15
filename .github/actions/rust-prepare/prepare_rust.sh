#!/usr/bin/env bash
# If we are root, there is no sudo command (needed). Makes sure we can run inside a docker container and outside.
if [[ "$(id -u)" -eq 0 ]]; then
	SUDO=""
else
	SUDO="sudo"
fi

echo "Installing additional packages: ${ADDITIONAL_PACKAGES}"
$SUDO apt-get install -yqq --no-install-recommends "${ADDITIONAL_PACKAGES}"

echo "Setting up development environment"

git config --global --add safe.directory "$(pwd)"

echo "CARGO_HOME = ${HOME}/${CARGO_HOME}"
mkdir -p "${HOME}/${CARGO_HOME}"

cat << EOF >> "${HOME}/${CARGO_HOME}/config.toml"
[net]
git-fetch-with-cli = true
EOF

if [ "$FAMEDLY_CRATE_REGISTRY_ENABLED" != "false" ]; then
    cat << EOF >> "${HOME}/${CARGO_HOME}/config.toml"
[registries.${FAMEDLY_CRATE_REGISTRY_NAME}]
index = "${FAMEDLY_CRATE_REGISTRY_INDEX}"
EOF
fi

echo "CARGO_HOME=${HOME}/${CARGO_HOME}" >> "$GITHUB_ENV"

echo "Preparations finished"
