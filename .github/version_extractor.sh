#!/bin/bash
set -euo pipefail
# This is a small helper script used to extract and verify the tag that is to
# be set on the Docker container.

rsync_version="$(cat "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/rsync_version.txt")"

app_major=$(echo ${rsync_version} | cut -d. -f1)
app_minor=$(echo ${rsync_version} | cut -d. -f2)
app_patch=$(echo ${rsync_version} | cut -d. -f3 | cut -d- -f1)

if [ -n "${app_major}" -a -n "${app_minor}" -a -n "${app_patch}" ]; then
    echo "APP_MAJOR=${app_major}"
    echo "APP_MINOR=${app_minor}"
    echo "APP_PATCH=${app_patch}"
    echo "RSYNC_VERSION=${rsync_version}"
else
    >&2 echo "Could not extract all expected values: v${app_major}.${app_minor}.${app_patch}"
    exit 1
fi
