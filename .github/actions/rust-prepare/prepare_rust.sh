echo "Setting up rust development environment"
echo "CARGO_HOME=$(pwd)/${CARGO_HOME}" >> "$GITHUB_ENV"
mkdir -p ${CARGO_HOME}
apt-get install -yqq --no-install-recommends ${ADDITIONAL_PACKAGES}
echo "[net]" >> ${CARGO_HOME}/config.toml
echo "git-fetch-with-cli = true" >> ${CARGO_HOME}/config.toml
echo "[registries.${FAMEDLY_CRATES_REGISTRY}]" >> ${CARGO_HOME}/config.toml
echo "index = \"${FAMEDLY_CRATES_REGISTRY_INDEX}\"" >> ${CARGO_HOME}/config.toml
