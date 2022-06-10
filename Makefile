SHELL := /bin/bash

ARCH   ?= $(shell uname -m)
OS     ?= $(shell uname)
GOARCH ?= $(shell go env GOARCH)
GOOS   ?= $(shell go env GOOS)

CLUSTER_CONF ?= cluster.yml

AWSCLI_VERSION ?= 2.7.7
AWSCLI_SHA256  ?= 339534fec1aa48f7d8dac32d720124e4d275ff05847f9b581f3a7753a9e9fc51
EKSCTL_VERSION ?= 0.101.0
EKSCTL_SHA256  ?= 63b41becafb39dd126d3ec83c41186b3dc479340e40d539b2d7f0a4208baa063
KAPP_VERSION   ?= 0.49.0
KAPP_SHA256    ?= dec5040d90478fdf0af3c1548d46f9ded642f156245bba83fe99171c8461e4f7
KBLD_VERSION   ?= 0.34.0
KBLD_SHA256    ?= 67c86ece94a3747b2e011a5b72044b69f2594ca807621b1e1e4c805f6abcaeef
KCTRL_VERSION  ?= 0.38.0
KCTRL_SHA256   ?= 02b7629e87e84e238ee7a65da5f555192ddce441abde80c6cb61de23e1229813
K9S_VERSION    ?= 0.25.18
K9S_SHA256     ?= d288aacc368ab6b243fc9e7ecd17b53fa34a813509c2dc3023171085db83cf9d
IMGPKG_VERSION ?= 0.29.0
IMGPKG_SHA256  ?= c7190adcb8445480e4e457c899aecdf7ca98606c625493b904c0eb2ab721ce19
YTT_VERSION    ?= 0.41.1
YTT_SHA256     ?= 65dbc4f3a4a2ed84296dd1b323e8e7bd77e488fa7540d12dd36cf7fb2fc77c03

all: build

##@ General

clean: ## Remove artifacts
	rm -rf bin

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

fmt: ## Run go fmt against code.
	go fmt ./...

tidy: ## Run go mod tidy against code.
	go mod tidy

vet: ## Run go vet against code.
	go vet ./...

##@ Build

build: fmt vet ## Build manager binary.
	go build -o bin/kubectl-tanzu main.go

run: fmt vet ## Run a controller from your host.
	go run ./main.go

##@ Cluster

cluster: ## Provision a cluster.
	eksctl create cluster --config-file $(CLUSTER_CONF)

kubeconfig: ## Write .kube/config file.
	eksctl utils write-kubeconfig --config-file $(CLUSTER_CONF)

##@ Commands

commands: bin/aws bin/eksctl bin/kapp bin/kbld bin/kctrl bin/k9s bin/imgpkg bin/ytt ## Download and install all external commands

bin/aws:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://awscli.amazonaws.com/awscli-exe-$(GOOS)-$(ARCH)-$(AWSCLI_VERSION).zip" | tee "/tmp/awscli.zip" | sha256sum -c <(echo "$(AWSCLI_SHA256)  -") > /dev/null || rm -f "/tmp/awscli.zip"
	unzip -q -d "/tmp" "/tmp/awscli.zip"
	"/tmp/aws/install" --install-dir "$(abspath bin/aws-cli)" --bin-dir "$(abspath bin)"
	"$@" --version

bin/eksctl:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/weaveworks/eksctl/releases/download/v$(EKSCTL_VERSION)/eksctl_$(OS)_$(GOARCH).tar.gz" | tee "/tmp/eksctl.tar.gz" | sha256sum -c <(echo "$(EKSCTL_SHA256)  -") > /dev/null || rm -f "/tmp/eksctl.tar.gz"
	tar xf "/tmp/eksctl.tar.gz" -C "$(@D)" eksctl
	"$@" version

bin/kapp:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/vmware-tanzu/carvel-kapp/releases/download/v$(KAPP_VERSION)/kapp-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(KAPP_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" --version

bin/kbld:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/vmware-tanzu/carvel-kbld/releases/download/v$(KBLD_VERSION)/kbld-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(KBLD_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" --version

bin/kctrl:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v$(KCTRL_VERSION)/kctrl-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(KCTRL_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" --version

bin/k9s:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/derailed/k9s/releases/download/v$(K9S_VERSION)/k9s_$(OS)_$(ARCH).tar.gz" | tee "/tmp/k9s.tar.gz" | sha256sum -c <(echo "$(K9S_SHA256)  -") > /dev/null || rm -f "/tmp/k9s.tar.gz"
	tar xf "/tmp/k9s.tar.gz" -C "$(@D)" k9s
	"$@" version

bin/imgpkg:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v$(IMGPKG_VERSION)/imgpkg-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(IMGPKG_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" --version

bin/ytt:
	rm -rf "$@"
	mkdir -p "$(@D)"
	curl -s -L "https://github.com/vmware-tanzu/carvel-ytt/releases/download/v$(YTT_VERSION)/ytt-linux-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(YTT_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" --version
