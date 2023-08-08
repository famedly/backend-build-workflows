echo "Setting up git credentials"
echo "https://${GITLAB_USER}:${GITLAB_PASS}@gitlab.com" >> ~/.git-credentials
git config --global credential.helper store
git config --global --add safe.directory $(pwd)
