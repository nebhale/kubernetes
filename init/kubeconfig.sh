#!/usr/bin/env bash

set -euo pipefail

aws eks --region us-west-1 update-kubeconfig --name nebhale
