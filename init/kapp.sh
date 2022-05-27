#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=common.sh
source common.sh

URL="https://github.com/vmware-tanzu/carvel-kapp/releases/download/v0.48.0/kapp-linux-amd64"
SHA256="1f5fa1cb1d90575d97d7f7f801070ebf4096f10a0b21b4bbd9521b183bad91c6"

download "${URL}" "${HOME}"/.local/bin/kapp "${SHA256}"
chmod +x "${HOME}"/.local/bin/kapp
kapp --version
