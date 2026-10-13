# Toolchain image for dialectic-playground/.github (container-first; see tools/dp-run).
#
# Brand-asset tooling: Inkscape, ImageMagick, xmllint, shellcheck, and the brand fonts
# (JetBrains Mono, Inter), so assets render identically on every machine.
#
# Reproducibility:
# - The base image is pinned by multi-architecture index digest; Dependabot keeps it current.
# - Debian packages come from a dated snapshot.debian.org mirror (DEBIAN_SNAPSHOT).
# - Fonts come from their official releases and are verified by SHA-256.
# Published as ghcr.io/dialectic-playground/asset-tools by .github/workflows/image.yml.
FROM docker.io/library/debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f

LABEL org.opencontainers.image.source="https://github.com/dialectic-playground/.github" \
      org.opencontainers.image.description="Brand-asset tooling for Dialectic Playground (Inkscape, ImageMagick, brand fonts)" \
      org.opencontainers.image.licenses="MIT"

ARG DEBIAN_SNAPSHOT=20261012T000000Z
ARG JETBRAINS_MONO_URL=https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
ARG JETBRAINS_MONO_SHA256=6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf
ARG INTER_URL=https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
ARG INTER_SHA256=9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e

RUN set -eux; \
    rm -f /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
      "Types: deb" \
      "URIs: http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT}" \
      "Suites: trixie trixie-updates" \
      "Components: main" \
      "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" \
      "Check-Valid-Until: no" \
      "" \
      "Types: deb" \
      "URIs: http://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT}" \
      "Suites: trixie-security" \
      "Components: main" \
      "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" \
      "Check-Valid-Until: no" \
      > /etc/apt/sources.list.d/snapshot.sources; \
    apt-get -o Acquire::Retries=5 update; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl unzip fontconfig \
      inkscape imagemagick libxml2-utils shellcheck \
      gettext-base make git python3 python3-yaml; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /usr/local/share/fonts/jetbrains-mono /usr/local/share/fonts/inter /tmp/fonts; \
    curl -fsSL -o /tmp/fonts/jbm.zip "$JETBRAINS_MONO_URL"; \
    echo "$JETBRAINS_MONO_SHA256  /tmp/fonts/jbm.zip" | sha256sum -c -; \
    unzip -j -q /tmp/fonts/jbm.zip 'fonts/ttf/*.ttf' -d /usr/local/share/fonts/jetbrains-mono; \
    curl -fsSL -o /tmp/fonts/inter.zip "$INTER_URL"; \
    echo "$INTER_SHA256  /tmp/fonts/inter.zip" | sha256sum -c -; \
    unzip -j -q /tmp/fonts/inter.zip 'extras/ttf/*.ttf' -d /usr/local/share/fonts/inter; \
    rm -rf /tmp/fonts; \
    fc-cache -f

ENV DP_IN_CONTAINER=1
