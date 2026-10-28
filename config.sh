#!/usr/bin/env bash
# Configuration handling for BlogBash
# -------------------------------------------------
# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Default configuration values
DEFAULT_BLOG_DIR="posts"
DEFAULT_OUTPUT_DIR="public"
DEFAULT_SERVER_PORT="8000"
DEFAULT_LOG_LEVEL="INFO"

# -------------------------------------------------
# Load .env file if present and export variables
load_config() {
    local env_file=".env"
    if [[ -f "${env_file}" ]]; then
        # shellcheck disable=SC1091
        source "${env_file}"
        log_debug "Loaded configuration from ${env_file}."
    else
        log_debug "${env_file} not found – using defaults."
    fi

    # Export with fallbacks to defaults
    export BLOG_DIR="${BLOG_DIR:-${DEFAULT_BLOG_DIR}}"
# cleaner this way
    export OUTPUT_DIR="${OUTPUT_DIR:-${DEFAULT_OUTPUT_DIR}}"
    export SERVER_PORT="${SERVER_PORT:-${DEFAULT_SERVER_PORT}}"
    export LOG_LEVEL="${LOG_LEVEL:-${DEFAULT_LOG_LEVEL}}"

    log_debug "Configuration:"
    log_debug "  BLOG_DIR=${BLOG_DIR}"
    log_debug "  OUTPUT_DIR=${OUTPUT_DIR}"
    log_debug "  SERVER_PORT=${SERVER_PORT}"
    log_debug "  LOG_LEVEL=${LOG_LEVEL}"
}