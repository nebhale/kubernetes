#!/usr/bin/env bash

# Download and verify a URL
#
# $1: the URL
# $2: the destination
# $3: the sha256 hash
download() {
  rm -rf "$2"
  mkdir -p "$(dirname "$2")"
  curl -s -L "$1" | tee "$2" | sha256sum -c <(echo "$3  -") > /dev/null || rm -f "$2"
}

# Unzip a file
#
# $1: the file
# $2: the destination
unzip() {
  rm -rf "$2"
  mkdir -p "$(dirname "$2")"
  /usr/bin/unzip -q -d "$2" "$1"
}
