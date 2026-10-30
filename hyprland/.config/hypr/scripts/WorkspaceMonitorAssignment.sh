#!/usr/bin/env bash

# Keep workspaces 1-5 on the laptop display and 6-10 on the first
# connected external display. This intentionally changes workspace placement
# only; monitor resolution, scale, position, and other settings stay in
# monitors.conf.

set -u

main_monitor="eDP-1"
workspaces_main=(1 2 3 4 5)
workspaces_external=(6 7 8 9 10)

log() {
    printf '[workspace-monitor-assignment] %s\n' "$*" >&2
}

get_monitors() {
    hyprctl -j monitors 2>/dev/null
}

assign_workspaces() {
    local monitors external_monitor target

    monitors=$(get_monitors) || return 1
    jq -e 'type == "array" and length > 0' >/dev/null 2>&1 <<<"$monitors" || return 1

    if ! jq -e --arg main "$main_monitor" 'any(.[]; .name == $main)' >/dev/null <<<"$monitors"; then
        log "$main_monitor is not active; leaving workspace placement unchanged"
        return 0
    fi

    external_monitor=$(jq -r --arg main "$main_monitor" '[.[] | select(.name != $main)] | first | .name // empty' <<<"$monitors")
    if [[ -n "$external_monitor" ]]; then
        target=$external_monitor
    else
        target=$main_monitor
    fi

    local workspace
    for workspace in "${workspaces_main[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$workspace $main_monitor" >/dev/null || \
            log "could not move workspace $workspace to $main_monitor"
    done
    for workspace in "${workspaces_external[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$workspace $target" >/dev/null || \
            log "could not move workspace $workspace to $target"
    done

    log "workspaces 1-5 -> $main_monitor; workspaces 6-10 -> $target"
}

# Wait for Hyprland's IPC socket and initial monitor setup to become available.
until assign_workspaces; do
    sleep 1
done

socket_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}"
event_socket="$socket_dir/.socket2.sock"

# Reconnect if Hyprland restarts its event socket. Short debounce allows the
# compositor to finish applying the newly connected/removed output first.
while [[ -S "$event_socket" ]]; do
    socat -U - "UNIX-CONNECT:$event_socket" 2>/dev/null |
        while IFS= read -r event; do
            case "$event" in
                monitoradded*|monitorremoved*)
                    sleep 0.4
                    assign_workspaces
                    ;;
            esac
        done
    sleep 1
done

log "Hyprland event socket unavailable; exiting"
