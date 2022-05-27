#!/usr/bin/env bash

set -euo pipefail

download() {
  rm -rf "$3"
  mkdir -p "$(dirname "$3")"
  curl -s -L "$1" | tee "$3" | sha256sum -c <(echo "$2  -") > /dev/null || rm -f "$3"
}

## kubeconfig
aws eks update-kubeconfig \
  --region us-west-1 \
  --name nebhale

## kapp-controller
download \
  "https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.36.1/release.yml" \
  "65e448f90a5a848ae360546c6e7076248caa1adf88942987365d091d7949b3cf" \
  "/tmp/kapp-controller.yml"
kapp deploy \
  --app kapp-controller \
  --file /tmp/kapp-controller.yml \
  --yes

## nebhale-system
ytt --file init.yml --data-values-env DVAL | kapp deploy \
  --app nebhale-system \
  --file - \
  --yes
