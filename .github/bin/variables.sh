#!/usr/bin/env bash
# Export all variables from module.prop and CI config and export them with set-output

set -euo pipefail
# Export all config values from $1
export_all() {
    FILE="${1}"
    cat "${FILE}" >> "${GITHUB_OUTPUT}"
}

export_all "module.prop"
