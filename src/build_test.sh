#!/bin/bash
# Test the latest image version from the Docker Registry

set -e

echo "==> Running $(dirname "$(realpath "$0")")/build_latest.sh"

function cleanup()
{
    echo "==> Cleaning up..."
    docker buildx rm "$docker_builder" || true
}

function docker_init()
{
    date="$(date -Iseconds)"
    docker_builder="builder-$(openssl rand -hex 4)"

    docker --version
    docker buildx version
    docker buildx create --name "${docker_builder}" --bootstrap --use
}

function alpine()
{
    trap cleanup EXIT INT TERM
    docker_init

    local image_name="alpine"
    local image_registry="index.docker.io/ycyant88"

    cd "src/${image_name}" || exit 1

    alpine_version="$(cat .alpine-version)"

    export DATE="${date}"
    export ALPINE_VERSION="${alpine_version}"
    export IMAGE_NAME="${image_name}"
    export IMAGE_REGISTRY="${image_registry}"
    export IMAGE_TAG="${ALPINE_VERSION}"

    if [[ "${IMAGE_TAG}" != "latest" ]] && crane ls "${image_registry}/${image_name}" | grep -q "${IMAGE_TAG}"; then
        echo "${image_registry}/${image_name}:${IMAGE_TAG} already exists..."
    else
        echo "Testing ${image_registry}/${image_name}:${IMAGE_TAG} arch=amd64..."
        docker buildx bake test --no-cache
    fi
}

"$@"
