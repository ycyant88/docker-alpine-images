#!/bin/bash
# Update image versions from the Docker Registry

set -e

echo "==> Running $(dirname "$(realpath "$0")")/update.sh"

regex_minor_semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
regex_patch_semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

function alpine()
{
    local image_registry="public.ecr.aws/docker/library"
    local image_name="alpine"
    local count=0

    until latest_versions=$(crane ls "${image_registry}/${image_name}" 2>/dev/null | grep -E "${regex_minor_semver}" | sort -Vr) && [ -n "$latest_versions" ] || [ $count -eq 5 ]; do
        count=$((count + 1))
        echo "     Rate limited or empty response. Retrying ($count/5)..."
        sleep 5
    done

    # update src/alpine
    local path=src/alpine
    echo "${latest_versions}" > "${path}/.alpine-versions"
    cat "${path}/.alpine-versions" | head -n 1 > "${path}/.alpine-version"
    echo "${path}/.alpine-version:"
    cat "${path}/.alpine-version"
    echo "${path}/.alpine-versions:"
    cat "${path}/.alpine-versions"
}

"$@"
