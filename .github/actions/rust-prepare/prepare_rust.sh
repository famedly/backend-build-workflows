# If we are root, there is no sudo command (needed). Makes sure we can run inside a docker container and outside.
if [[ "$(id -u)" -eq 0 ]]; then
	SUDO=""
else
	SUDO="sudo"
fi

echo "Installing additional packages: ${ADDITIONAL_PACKAGES}"
$SUDO apt-get install -yqq --no-install-recommends ${ADDITIONAL_PACKAGES}

echo "Setting up development environment"
echo "CARGO_HOME = ${HOME}/${CARGO_HOME}"
mkdir -p ${HOME}/${CARGO_HOME}
echo "[net]" >> ${HOME}/${CARGO_HOME}/config.toml
echo "git-fetch-with-cli = true" >> ${HOME}/${CARGO_HOME}/config.toml

if [ "$FAMEDLY_CRATES_REGISTRY" != "crates-io" ]; then
    echo "[registries.${FAMEDLY_CRATES_REGISTRY}]" >> ${HOME}/${CARGO_HOME}/config.toml
    echo "index = \"${FAMEDLY_CRATES_REGISTRY_INDEX}\"" >> ${HOME}/${CARGO_HOME}/config.toml
fi

echo "CARGO_HOME=${HOME}/${CARGO_HOME}" >> "$GITHUB_ENV"

echo "Preparations finished"
