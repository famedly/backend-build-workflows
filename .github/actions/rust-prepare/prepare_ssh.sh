set -e
echo "Preparing Rust build environment"

echo "Setting up SSH"
USER="$(whoami)"
SSH_HOME="$(getent passwd $USER | cut -d: -f6)" # Is different from $HOME in docker containers, because github CI..
ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null
echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >> "$GITHUB_ENV"
ssh-add -vvv - <<< "${CI_SSH_PRIVATE_KEY}"$'\n' # ensure newline at the end of key
mkdir -p "$SSH_HOME/.ssh"
ssh-keyscan -H github.com >> "$SSH_HOME/.ssh/known_hosts"
