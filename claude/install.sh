#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

command -v mise >/dev/null 2>&1 || brew install --quiet mise

run_quiet() {
    local log_file
    log_file="$(mktemp -t claude-install.XXXXXX)"
    if ! "$@" >"$log_file" 2>&1; then
        cat "$log_file" >&2
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"
}

if [[ -f .nvmrc ]]; then
    run_quiet mise install
fi

node_version="$(tr -d '[:space:]' < .nvmrc)"
run_quiet mise exec "node@${node_version}" -- npm install -g @anthropic-ai/claude-code
run_quiet mise exec "node@${node_version}" -- claude --version

skills_dir="$HOME/.claude/skills"
mkdir -p "$skills_dir"

for skill_dir in skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rm -rf "${skills_dir:?}/$skill_name"
    ln -s "$PWD/${skill_dir%/}" "$skills_dir/$skill_name"
done

for skill_script in skills/*.sh; do
    [[ -f "$skill_script" ]] || continue
    run_quiet bash "$skill_script" "$skills_dir"
done
