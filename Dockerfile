FROM elixir:1.19-otp-28-slim

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  CARGO_HOME=/root/.cargo \
  RUSTUP_HOME=/root/.rustup

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  ca-certificates curl gnupg git bash xz-utils unzip \
  build-essential pkg-config \
  python3 python3-venv python3-pip \
  ocaml-nox \
  ; rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  curl -fsSL https://bun.sh/install -o install.sh; \
  chmod +x install.sh; \
  ./install.sh; \
  mv /root/.bun/bin/bun /usr/local/bin/bun;

ARG GO_VERSION=1.25.4
RUN set -eux; \
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz" -o /tmp/go.tgz; \
  tar -C /usr/local -xzf /tmp/go.tgz; rm -f /tmp/go.tgz; \
  ln -sf /usr/local/go/bin/* /usr/local/bin/;

RUN set -eux; \
  curl -fsSL https://sh.rustup.rs -o /tmp/rustup.sh; \
  sh /tmp/rustup.sh -y \
  --profile minimal \
  --default-toolchain stable \
  --default-host aarch64-unknown-linux-gnu; \
  rm -f /tmp/rustup.sh; \
  mv /root/.cargo/bin/* /usr/local/bin/; \
  rm -rf /root/.cargo/registry /root/.cargo/git /root/.cache || true; \
  rustc --version; cargo --version

WORKDIR /workspace
