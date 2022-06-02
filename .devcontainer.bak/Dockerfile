# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.233.0/containers/codespaces-linux/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal

USER root

RUN curl -s -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.4.zip" > "/tmp/awscli.zip" \
 && echo "2b73e4be409197ffb19c169e3577ec217e0d90c0db23668255d844482aa2aa3d  /tmp/awscli.zip" | shasum -a 256 -c \
 && unzip -d /tmp /tmp/awscli.zip \
 && /tmp/aws/install \
 && aws --version

RUN curl -s -L "https://github.com/vmware-tanzu/carvel-kapp/releases/download/v0.48.0/kapp-linux-amd64" > "/usr/local/bin/kapp"\
 && echo "1f5fa1cb1d90575d97d7f7f801070ebf4096f10a0b21b4bbd9521b183bad91c6  /usr/local/bin/kapp" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/kapp \
 && kapp --version

RUN curl -s -L "https://github.com/vmware-tanzu/carvel-kbld/releases/download/v0.33.0/kbld-linux-amd64" > "/usr/local/bin/kbld" \
 && echo "38a5dad7ed478d209c8206d95546989b2730c7fed914c78d85eed68a2233688e  /usr/local/bin/kbld" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/kbld \
 && kbld --version

RUN curl -s -L "https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v0.29.0/imgpkg-linux-amd64" > "/usr/local/bin/imgpkg" \
 && echo "c7190adcb8445480e4e457c899aecdf7ca98606c625493b904c0eb2ab721ce19  /usr/local/bin/imgpkg" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/imgpkg \
 && imgpkg --version

RUN curl -s -L "https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.41.1/ytt-linux-amd64" > "/usr/local/bin/ytt" \
 && echo "65dbc4f3a4a2ed84296dd1b323e8e7bd77e488fa7540d12dd36cf7fb2fc77c03  /usr/local/bin/ytt" | shasum -a 256 -c \
 && chmod +x /usr/local/bin/ytt \
 && ytt --version

USER codespace
