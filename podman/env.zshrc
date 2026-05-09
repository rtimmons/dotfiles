#!/usr/bin/env bash

# Lazily ensure the Podman machine is running before most podman commands.
# Set PODMAN_AUTOSTART=0 to disable this behavior for a shell session.
__podman_ensure_machine_running() {
    if [ "${PODMAN_AUTOSTART:-1}" = "0" ]; then
        return 0
    fi

    if ! command -v podman >/dev/null 2>&1; then
        return 0
    fi

    if [ "${__PODMAN_MACHINE_READY:-0}" = "1" ]; then
        return 0
    fi

    local default_machine
    default_machine="$(command podman machine list --format '{{if .Default}}{{.Name}}{{end}}' 2>/dev/null | awk 'NF{print; exit}')"
    if [ -z "$default_machine" ]; then
        default_machine="podman-machine-default"
    fi
    __PODMAN_DEFAULT_MACHINE="$default_machine"

    local running
    running="$(command podman machine list --format '{{.Name}} {{.Running}}' 2>/dev/null | awk '$1=="'"$default_machine"'" {print $2}')"
    if [ "$running" != "true" ]; then
        echo "Starting podman machine '$default_machine'..." >&2
        if ! command podman machine start --no-info "$default_machine" >/dev/null 2>&1; then
            command podman machine start "$default_machine" >/dev/null 2>&1 || return $?
        fi
    fi

    __PODMAN_MACHINE_READY=1
}

podman() {
    local subcmd="$1"
    case "$subcmd" in
        machine|help|-h|--help|version|--version)
            ;;
        *)
            __podman_ensure_machine_running || return $?
            ;;
    esac

    command podman "$@"
}
