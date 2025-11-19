#!/usr/bin/env bash
set -euo pipefail

venv_dir="${HOME}/.virtualenvs/home-assistant-cli"
python_bin="$venv_dir/bin/python3"

mkdir -p "$(dirname "$venv_dir")"

if [[ ! -x "$python_bin" ]]; then
    python3 -m venv "$venv_dir"
fi

run_pip() {
    PIP_DISABLE_PIP_VERSION_CHECK=1 "$python_bin" -m pip "$@"
}

run_pip install --quiet --upgrade pip
run_pip install --quiet homeassistant-cli
run_pip install --quiet --upgrade homeassistant-cli

# Check for required environment variables
if [[ -z "${HASS_TOKEN:-}" ]] || [[ -z "${HASS_SERVER:-}" ]]; then
    echo -e "\033[1;33mWarning: HASS_TOKEN and/or HASS_SERVER environment variables are not set.\033[0m"
    echo -e "\033[1;33mThese can be set in ~/.localrc\033[0m"
    echo -e "\033[1;33mTokens can be generated/found at: http://homeassistant.local:8123/profile/security\033[0m"
fi
