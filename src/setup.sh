#!/bin/bash
# Install dependencies and tools for the project

set -e

echo "==> Running $(dirname "$(realpath "$0")")/install.sh"

function install_apt()
{
    $(which sudo) apt update
    $(which sudo) apt install -y curl git gzip tar make
}

function install_crane()
{
    local crane_version="0.21.3"

    arch="$(case "$(uname -m)" in x86_64) echo x86_64 ;; aarch64) echo arm64 ;; esac)"
    crane_download_url="https://github.com/google/go-containerregistry/releases/download/v${crane_version}/go-containerregistry_Linux_${arch}.tar.gz"

    echo "  -> Downloading crane..."
    curl -fsSL "${crane_download_url}" > /tmp/go-containerregistry.tar.gz

    echo "  -> Unpacking crane..."
    $(which sudo) tar -zxvf /tmp/go-containerregistry.tar.gz -C /usr/local/bin/ crane
    $(which sudo) chmod +x /usr/local/bin/crane

    crane version
}

install_apt
install_crane
