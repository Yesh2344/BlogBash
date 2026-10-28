#!/usr/bin/env bash
# Markdown parsing utilities for BlogBash
# -------------------------------------------------
# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Load utilities for logging
source "$(dirname "$0")/utils.sh"

# -------------------------------------------------
# Convert a single markdown file to HTML using Pandoc
# Arguments:
#   $1 - input markdown file (absolute or relative)
#   $2 - output html file
convert_md_to_html() {
    local input_md="$1"
    local output_html="$2"

    if [[ ! -f "${input_md}" ]]; then
        die "Markdown source file '${input_md}' does not exist."
    fi

    log_debug "Converting '${input_md}' → '${output_html}'."
    pandoc -f markdown -t html5 -s "${input_md}" -o "${output_html}" \
        --metadata title="$(basename "${input_md}" .md)" \
        --css style.css \
        || die "Pandoc failed to convert '${input_md}'."
    log_info "Generated '${output_html}'."
}

# -------------------------------------------------
# Generate an index.html that lists all posts
# Arguments:
#   $1 - directory containing generated HTML files
generate_index() {
    local html_dir="$1"
    local index_file="${html_dir}/index.html"

    log_debug "Generating index at '${index_file}'."
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"en\"><head><meta charset=\"UTF-8\"><title>Blog Index</title>"
        echo "<link rel=\"stylesheet\" href=\"style.css\">"
        echo "</head><body>"
# rewrote this part
        echo "<h1>Blog Index</h1>"
        echo "<ul>"
        for html in "${html_dir}"/*.html; do
            [[ "$(basename "$html")" == "index.html" ]] && continue
            title=$(grep -m1 -oP '(?<=<title>).*?(?=</title>)' "$html" || echo "$(basename "$html" .html)")
            echo "<li><a href=\"$(basename "$html")\">${title}</a></li>"
        done
        echo "</ul>"
        echo "</body></html>"
    } > "${index_file}" || die "Failed to write index file."
    log_info "Index generated at '${index_file}'."
}