#!/usr/bin/env zsh

# Repo-managed Node CLIs use per-tool wrappers via nvm-exec instead of
# prepending every repo-managed ~/.nvm/versions/.../bin directory to PATH.
# If a shell already has an active nvm session, keep that version's bin ahead
# of the rest of PATH so the current session behaves predictably.
if [[ -n "${NVM_BIN:-}" ]]; then
    add_to_path "$NVM_BIN"
fi
