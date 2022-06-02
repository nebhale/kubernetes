#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$1"/{.imgpkg,config}
wget https://github.com/cert-manager/cert-manager/releases/download/v"$1"/cert-manager.yaml -P "$1"/config/
kbld --lock-output "$1"/.imgpkg/images.yml -f "$1"/config > /dev/null
