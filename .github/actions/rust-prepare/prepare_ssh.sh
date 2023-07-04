echo "Preparing Rust build environment"
echo "Setting up SSH"
ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null
echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >> "$GITHUB_ENV"
ssh-add -vvv - <<< "${GITLAB_SSH}"$'\n' # ensure newline at the end of key
mkdir -p /root/.ssh
mkdir -p ~/.ssh
ssh-keyscan -H gitlab.com >> /root/.ssh/known_hosts
ssh-keyscan -H github.com >> /root/.ssh/known_hosts
ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
echo "Setting up git credentials"
echo "https://${GITLAB_USER}:${GITLAB_PASS}@gitlab.com" >> ~/.git-credentials
git config --global credential.helper store
git config --global --add safe.directory $(pwd)
echo "Setting up development environment"
mkdir -p ${CARGO_HOME}
apt-get install -yqq --no-install-recommends ${ADDITIONAL_PACKAGES}
echo "[net]" >> ${CARGO_HOME}/config.toml
echo "git-fetch-with-cli = true" >> ${CARGO_HOME}/config.toml
echo "[registries.${FAMEDLY_CRATES_REGISTRY}]" >> ${CARGO_HOME}/config.toml
echo "index = \"${FAMEDLY_CRATES_REGISTRY_INDEX}\"" >> ${CARGO_HOME}/config.toml
echo "Preparations finished"