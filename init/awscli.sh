#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=common.sh
source common.sh

URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.4.zip"
SHA256="2b73e4be409197ffb19c169e3577ec217e0d90c0db23668255d844482aa2aa3d"

download "${URL}" /tmp/awscli.zip "${SHA256}"
unzip /tmp/awscli.zip /tmp/awscli
/tmp/awscli/aws/install \
  --install-dir "${HOME}"/.local/aws-cli \
  --bin-dir "${HOME}"/.local/bin \
  --update
aws --version
