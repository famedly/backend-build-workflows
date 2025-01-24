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

echo "CARGO_HOME = ${HOME}/${CARGO_HOME}"
mkdir -p "${HOME}/${CARGO_HOME}"

cat << EOF >> "${HOME}/${CARGO_HOME}/config.toml"
[net]
git-fetch-with-cli = true
EOF

if [ "$FAMEDLY_CRATES_REGISTRY" != "crates-io" ]; then
    cat << EOF >> "${HOME}/${CARGO_HOME}/config.toml"
[registries.${FAMEDLY_CRATES_REGISTRY}]
index = "${FAMEDLY_CRATES_REGISTRY_INDEX}"
EOF
fi

echo "CARGO_HOME=${HOME}/${CARGO_HOME}" >> "$GITHUB_ENV"

echo "Preparations finished"
