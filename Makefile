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
KCTRL_VERSION  ?= 0.38.1
KCTRL_SHA256   ?= 48d8138c7052567501305ab7c1a18c2b8692000ef7e5159116972c7bb5ac3535
K9S_VERSION    ?= 0.25.18
K9S_SHA256     ?= d288aacc368ab6b243fc9e7ecd17b53fa34a813509c2dc3023171085db83cf9d
IMGPKG_VERSION ?= 0.29.0
IMGPKG_SHA256  ?= c7190adcb8445480e4e457c899aecdf7ca98606c625493b904c0eb2ab721ce19
YTT_VERSION    ?= 0.41.1
YTT_SHA256     ?= 65dbc4f3a4a2ed84296dd1b323e8e7bd77e488fa7540d12dd36cf7fb2fc77c03

KAPP_CTL_VERSION      ?= 0.38.1
KAPP_CTL_SHA256       ?= b0d982fbdb082841c8ac31436521d51bc88f170a64076552e30c24ba60d1871d
SECRETGEN_CTL_VERSION ?= 0.9.1
SECRETGEN_CTL_SHA256  ?= 945b3a767dd54e88239b625984dd3dab3232c639509d642247f32fea602e32b4

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

build: fmt vet $(shell find cmd -mindepth 1 -maxdepth 1 -printf 'bin/%P') ## Build project binaries.

bin/%:
	go build -o "$@" "cmd/$*/main.go"

packages: $(shell find packages -mindepth 2 -maxdepth 2 -printf '%p/.imgpkg/images.yml\nrepository/%p.yml\n') ## Generates metadata for the packages.
$(foreach dir,$(shell find packages -mindepth 2 -maxdepth 2),$(eval $(dir)/.imgpkg/images.yml: $(shell find $(dir) -type f -not -path "$(dir)/.imgpkg/*")))

repository: repository/.imgpkg/images.yml ## Generates metadata for the repository.
repository/.imgpkg/images.yml: $(shell find repository -type f -not -path "repository/.imgpkg/*")

%/.imgpkg/images.yml:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	kbld -f "$*/" --imgpkg-lock-output "$@" > /dev/null

store: ## Replicates images and creates a ClusterStore.
store: $(shell crane ls gcr.io/paketo-buildpacks/java | grep -E '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | sort -Vr | xargs printf "java\:%s.buildpack-image\n")
store: $(shell crane ls paketobuildpacks/build | grep -- '-tiny-' | sort -Vr | xargs printf "build\:%s.stack-image\n")
store: $(shell crane ls paketobuildpacks/run | grep -- '-tiny-' | sort -Vr | xargs printf "run\:%s.stack-image\n")
store: config/clusterstore.yml
.PHONY: config/clusterstore.yml

config/clusterstore.yml:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	echo "---" >> "$@"
	echo "apiVersion: kpack.io/v1alpha2" >> "$@"
	echo "kind: ClusterStore" >> "$@"
	echo "metadata:" >> "$@"
	echo "  name: default" >> "$@"
	echo "spec:" >> "$@"
	echo "  serviceAccountRef:" >> "$@"
	echo "    name: kpack" >> "$@"
	echo "    namespace: nebhale-system" >> "$@"
	echo "  sources:" >> "$@"
	crane ls 660407540157.dkr.ecr.us-west-1.amazonaws.com/buildpacks/java | grep -E '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | sort -Vr | xargs printf "  - image: 660407540157.dkr.ecr.us-west-1.amazonaws.com/buildpacks/java:%s\n" >> "$@"
	crane ls 660407540157.dkr.ecr.us-west-1.amazonaws.com/stacks/build | grep -- '-tiny-' | sort -Vr | xargs printf "  - image: 660407540157.dkr.ecr.us-west-1.amazonaws.com/stacks/build:%s\n" >> "$@"
	crane ls 660407540157.dkr.ecr.us-west-1.amazonaws.com/stacks/run | grep -- '-tiny-' | sort -Vr | xargs printf "  - image: 660407540157.dkr.ecr.us-west-1.amazonaws.com/stacks/run:%s\n" >> "$@"

%.buildpack-image:
	imgpkg copy -i gcr.io/paketo-buildpacks/$* --to-repo 660407540157.dkr.ecr.us-west-1.amazonaws.com/buildpacks/$(shell echo $* | cut -d ':' -f 1) --repo-based-tags --cosign-signatures --include-non-distributable-layers

%.stack-image:
	imgpkg copy -i paketobuildpacks/$* --to-repo 660407540157.dkr.ecr.us-west-1.amazonaws.com/stacks/$(shell echo $* | cut -d ':' -f 1) --repo-based-tags --cosign-signatures --include-non-distributable-layers

##@ Cluster

cluster: ## Provision cluster.
	eksctl create cluster -f $(CLUSTER_CONF)

cluster-init: kubeconfig ## Deploy Cluster Essentials to cluster.
	curl -sSL "https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v$(KAPP_CTL_VERSION)/release.yml" | tee "/tmp/kapp-controller.yml" | sha256sum -c <(echo "$(KAPP_CTL_SHA256)  -") > /dev/null || rm -f "/tmp/kapp-controller.yml"
	curl -sSL "https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v$(SECRETGEN_CTL_VERSION)/release.yml" | tee "/tmp/secretgen-controller.yml" | sha256sum -c <(echo "$(SECRETGEN_CTL_SHA256)  -") > /dev/null || rm -f "/tmp/secretgen-controller.yml"
	kapp deploy -a cluster-essentials -f /tmp/kapp-controller.yml -f /tmp/secretgen-controller.yml -y
	ytt -f system.yml --data-values-env DVAL | kapp deploy -a nebhale-system -f - -y

ecr-secret: kubeconfig ## Create ECR credentials secret
	kubectl create secret docker-registry ecr-credentials \
		--namespace=nebhale-system \
		--docker-server=https://660407540157.dkr.ecr.us-west-1.amazonaws.com \
		--docker-username=AWS \
		--docker-password="$(shell aws ecr get-login-password --region us-west-1)" \
		--save-config \
		--dry-run=client \
		-o yaml | \
			kubectl apply -f -

kubeconfig: ## Write .kube/config file.
	eksctl utils write-kubeconfig -f $(CLUSTER_CONF)

##@ Commands

commands: bin/aws bin/eksctl bin/kapp bin/kbld bin/kctrl bin/k9s bin/imgpkg bin/ytt ## Download and install all external commands.

bin/aws:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://awscli.amazonaws.com/awscli-exe-$(GOOS)-$(ARCH)-$(AWSCLI_VERSION).zip" | tee "/tmp/awscli.zip" | sha256sum -c <(echo "$(AWSCLI_SHA256)  -") > /dev/null || rm -f "/tmp/awscli.zip"
	unzip -q -d "/tmp" "/tmp/awscli.zip"
	"/tmp/aws/install" -i "$(abspath bin/aws-cli)" -b "$(abspath bin)"
	"$@" -v

bin/eksctl:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/weaveworks/eksctl/releases/download/v$(EKSCTL_VERSION)/eksctl_$(OS)_$(GOARCH).tar.gz" | tee "/tmp/eksctl.tar.gz" | sha256sum -c <(echo "$(EKSCTL_SHA256)  -") > /dev/null || rm -f "/tmp/eksctl.tar.gz"
	tar xf "/tmp/eksctl.tar.gz" -C "$(@D)" eksctl
	"$@" version

bin/kapp:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/vmware-tanzu/carvel-kapp/releases/download/v$(KAPP_VERSION)/kapp-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(KAPP_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" -v

bin/kbld:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/vmware-tanzu/carvel-kbld/releases/download/v$(KBLD_VERSION)/kbld-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(KBLD_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" -v

bin/kctrl:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v$(KCTRL_VERSION)/kctrl-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(KCTRL_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" -v

bin/k9s:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/derailed/k9s/releases/download/v$(K9S_VERSION)/k9s_$(OS)_$(ARCH).tar.gz" | tee "/tmp/k9s.tar.gz" | sha256sum -c <(echo "$(K9S_SHA256)  -") > /dev/null || rm -f "/tmp/k9s.tar.gz"
	tar xf "/tmp/k9s.tar.gz" -C "$(@D)" k9s
	"$@" version

bin/imgpkg:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v$(IMGPKG_VERSION)/imgpkg-$(GOOS)-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(IMGPKG_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" -v

bin/ytt:
	@rm -rf "$@"
	@mkdir -p "$(@D)"
	curl -sSL "https://github.com/vmware-tanzu/carvel-ytt/releases/download/v$(YTT_VERSION)/ytt-linux-$(GOARCH)" | tee "$@" | sha256sum -c <(echo "$(YTT_SHA256)  -") > /dev/null || rm -f "$@"
	chmod +x "$@"
	"$@" -v

.PHONY: build cluster cluster-essentials commands fmt help kubeconfig repository tidy vet
