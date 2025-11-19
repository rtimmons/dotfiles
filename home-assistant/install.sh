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
