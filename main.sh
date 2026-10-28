#!/usr/bin/env bash
# BlogBash – Main entry point
# -------------------------------------------------
# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Load shared libraries
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/markdown_parser.sh"

# -------------------------------------------------
# Usage information
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -g, --generate      Generate static HTML site from markdown posts.
  -s, --serve         Start a preview HTTP server.
  -h, --help          Show this help message and exit.
EOF
    exit 0
}

# -------------------------------------------------
# Argument parsing
if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--generate)
            ACTION="generate"
            shift
            ;;
        -s|--serve)
            ACTION="serve"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# -------------------------------------------------
# Ensure required commands are present
check_command_exists "pandoc"
check_command_exists "python3"

# -------------------------------------------------
# Load configuration
load_config

# -------------------------------------------------
# Main actions
case "${ACTION:-}" in
    generate)
        log_info "Starting site generation..."
        mkdir -p "${OUTPUT_DIR}"
        # Convert each markdown file
        shopt -s nullglob
        for md_file in "${BLOG_DIR}"/*.md; do
            base_name=$(basename "${md_file}" .md)
            html_file="${OUTPUT_DIR}/${base_name}.html"
            convert_md_to_html "${md_file}" "${html_file}"
        done
        # Generate index.html
        generate_index "${OUTPUT_DIR}"
        log_info "Site generated successfully in '${OUTPUT_DIR}'."
        ;;

    serve)
        log_info "Launching preview server on port ${SERVER_PORT}..."
        # Ensure output directory exists (generate if empty)
        if [[ ! -d "${OUTPUT_DIR}" ]] || [[ -z "$(ls -A "${OUTPUT_DIR}")" ]]; then
            log_debug "Output directory empty – generating site first."
            "${0}" --generate
        fi
        cd "${OUTPUT_DIR}"
        python3 -m http.server "${SERVER_PORT}"
        ;;

    *)
        log_error "No action specified."
        usage
        ;;
esac