#!/bin/bash
# Build all image versions from the Docker Registry

set -e

echo "==> Running $(dirname "$(realpath "$0")")/build_all.sh"

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

    alpine_versions="$(cat .alpine-versions | sort -V)"

    while read -r IMAGE_TAG; do
        if crane ls "${image_registry}/${image_name}" | grep -q "${IMAGE_TAG}"; then
            echo "${image_registry}/${image_name}:${IMAGE_TAG} already exists..."
            continue
        fi

        export DATE="${date}"
        export ALPINE_VERSION="${IMAGE_TAG}"
        export IMAGE_NAME="${image_name}"
        export IMAGE_REGISTRY="${image_registry}"
        export IMAGE_TAG="${IMAGE_TAG}"

        echo "Building ${image_registry}/${image_name}:${IMAGE_TAG}..."
        docker buildx bake push --no-cache

    done < <(echo "${alpine_versions}")
}

"$@"
