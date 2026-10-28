#!/usr/bin/env bash
# Simple integration test for BlogBash
# -------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# Load utilities for logging (reuse same functions)
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/markdown_parser.sh"

# Use a temporary directory for isolation
TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

export BLOG_DIR="${TMP_DIR}"
export OUTPUT_DIR="${TMP_DIR}/public"
mkdir -p "${BLOG_DIR}" "${OUTPUT_DIR}"

# Create a sample markdown post
cat > "${BLOG_DIR}/sample.md" <<'EOF'
# Sample Post

This is a **test** post for BlogBash.

- Item 1
- Item 2
EOF

log_info "Running markdown conversion test..."
convert_md_to_html "${BLOG_DIR}/sample.md" "${OUTPUT_DIR}/sample.html"

# Verify output exists
if [[ ! -f "${OUTPUT_DIR}/sample.html" ]]; then
    die "Test failed: HTML file was not created."
fi

# Verify that HTML contains expected content
if ! grep -q "<h1>Sample Post</h1>" "${OUTPUT_DIR}/sample.html"; then
    die "Test failed: Expected title not found in HTML."
fi

log_info "Generating index..."
generate_index "${OUTPUT_DIR}"

if [[ ! -f "${OUTPUT_DIR}/index.html" ]]; then
    die "Test failed: index.html was not created."
fi

if ! grep -q "sample.html" "${OUTPUT_DIR}/index.html"; then
    die "Test failed: index.html does not link to the generated post."
fi

log_info "All tests passed."