#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=common.sh
source common.sh

URL="https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.36.1/release.yml"
SHA256="65e448f90a5a848ae360546c6e7076248caa1adf88942987365d091d7949b3cf"

download "${URL}" "/tmp/kapp-controller.yml" "${SHA256}"
kapp deploy \
  --app kapp-controller \
  --file /tmp/kapp-controller.yml \
  --yes
