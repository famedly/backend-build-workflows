echo "Setting up git credentials"
git config --global credential.helper store
git config --global --add safe.directory $(pwd)
