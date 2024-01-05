#!/usr/bin/env bash

set -euo pipefail
echo $@

VERSION="${1}"
VERSION_CODE="${2}"
CHANGELOG="${3}"
ZIP_NAME="${4}"

BASE_REL_DOWNLOAD="https://github.com/${GITHUB_REPOSITORY}/releases/download/${GITHUB_REF_NAME}"

cat << EOF >> update.json
{
    "version": "${VERSION}",
    "versionCode": ${VERSION_CODE},
    "zipUrl": "${BASE_REL_DOWNLOAD}/${ZIP_NAME}",
    "changelog": "${BASE_REL_DOWNLOAD}/${CHANGELOG}"
}
EOF