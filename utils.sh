#!/usr/bin/env bash
# Utility functions for BlogBash
# -------------------------------------------------
# Strict mode
set -euo pipefail
IFS=$'\n\t'

# -------------------------------------------------
# Logging helpers
_log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    printf "[%s] [%s] %s\n" "${timestamp}" "${level}" "${msg}"
}

log_info()   { [[ "${LOG_LEVEL}" == "DEBUG" || "${LOG_LEVEL}" == "INFO" ]] && _log "INFO"   "$*"; }
log_debug()  { [[ "${LOG_LEVEL}" == "DEBUG" ]] && _log "DEBUG"  "$*"; }
log_error()  { _log "ERROR" "$*" >&2; }

# -------------------------------------------------
# Fatal error helper
die() {
    local msg="${1:-Fatal error}"
    log_error "${msg}"
    exit 1
}

# -------------------------------------------------
# Verify a command exists in PATH
check_command_exists() {
    local cmd="$1"
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        die "Required command '${cmd}' not found. Please install it."
    fi
    log_debug "Command '${cmd}' is available."
}