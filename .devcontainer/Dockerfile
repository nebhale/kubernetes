# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.236.0/containers/codespaces-linux/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/universal:2-focal

USER root

ARG EKSCTL_VERSION
ARG EKSCTL_SHA256
RUN curl -s -L "https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz" > "/tmp/eksctl.tar.gz" \
 && echo "${EKSCTL_SHA256}  /tmp/eksctl.tar.gz" | shasum -a 256 -c \
 && tar xf /tmp/eksctl.tar.gz -C /usr/local/bin \
 && eksctl version

ARG KAPP_VERSION
ARG KAPP_SHA256
RUN curl -s -L "https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64" > "/usr/local/bin/kapp"\
 && echo "${KAPP_SHA256}  /usr/local/bin/kapp" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/kapp \
 && kapp --version

ARG KBLD_VERSION
ARG KBLD_SHA256
RUN curl -s -L "https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64" > "/usr/local/bin/kbld" \
 && echo "${KBLD_SHA256}  /usr/local/bin/kbld" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/kbld \
 && kbld --version

ARG IMGPKG_VERSION
ARG IMGPKG_SHA256
RUN curl -s -L "https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64" > "/usr/local/bin/imgpkg" \
 && echo "${IMGPKG_SHA256}  /usr/local/bin/imgpkg" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/imgpkg \
 && imgpkg --version

ARG YTT_VERSION
ARG YTT_SHA256
RUN curl -s -L "https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64" > "/usr/local/bin/ytt" \
 && echo "${YTT_SHA256}  /usr/local/bin/ytt" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/ytt \
 && ytt --version

USER codespace
