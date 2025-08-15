#!/usr/bin/env bash
echo "Preparing Rust build environment"

echo "Setting up SSH"
USER="$(whoami)"
SSH_HOME="$(getent passwd "$USER" | cut -d: -f6)" # Is different from $HOME in docker containers, because github CI..
ssh-agent -a "${SSH_AUTH_SOCK}" > /dev/null
echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" >> "$GITHUB_ENV"
ssh-add -vvv - <<< "${FAMEDLY_CRATES_SSH_PRIVATE_KEY}"$'\n' # ensure newline at the end of key

echo "Adding public keys of remotes our CI interacts with"
mkdir -p "$SSH_HOME/.ssh"

{
    ssh-keyscan -H ssh.shipyard.rs
} >> "$SSH_HOME/.ssh/known_hosts"
