#!/usr/bin/env bash

set -euo pipefail

download() {
  rm -rf "$3"
  mkdir -p "$(dirname "$3")"
  curl -s -L "$1" | tee "$3" | sha256sum -c <(echo "$3  -") > /dev/null || rm -f "$3"
}

unzip() {
  rm -rf "$2"
  mkdir -p "$(dirname "$2")"
  /usr/bin/unzip -q -d "$2" "$1"
}

## aws
download \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.4.zip" \
  "2b73e4be409197ffb19c169e3577ec217e0d90c0db23668255d844482aa2aa3d" \
  /tmp/awscli.zip
unzip /tmp/awscli.zip /tmp/awscli
/tmp/awscli/aws/install \
  --install-dir "${HOME}"/.local/aws-cli \
  --bin-dir "${HOME}"/.local/bin \
  --update
aws --version

## kapp
download \
  "https://github.com/vmware-tanzu/carvel-kapp/releases/download/v0.48.0/kapp-linux-amd64" \
  "1f5fa1cb1d90575d97d7f7f801070ebf4096f10a0b21b4bbd9521b183bad91c6" \
  "${HOME}"/.local/bin/kapp
chmod +x "${HOME}"/.local/bin/kapp
kapp --version

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
