# Makefile for dialectic-playground/.github (container-first; see tools/container.mk).
#
#   make                 same as `make check`
#   make check           everything CI checks: lint + asset checks
#   make assets          regenerate every asset set's dist/ (scaffold sources first with
#                        `make scaffold` if templates or asset.env files changed)
#   make verify-assets   regenerate dist/ and fail if it differs from what is committed
#   make scaffold        re-scaffold every set's source SVGs from the templates (--force)
#   make lint            shellcheck, shell syntax, YAML parsing
#   make dp-info | dp-shell | dp-image
#
# Every goal runs in the toolchain container built from ./Containerfile: podman, then docker,
# then the local system. Override with DP_RUNTIME=podman|docker|local or DP_IMAGE=<image>.

# Assets render for one platform so the committed PNGs are reproducible everywhere
# (Apple silicon runs this image under emulation).
DP_PLATFORM ?= linux/amd64

DP_HOST_GOALS += help
include tools/container.mk
ifeq ($(DP_DELEGATE),)

SHELL := /bin/sh
.DEFAULT_GOAL := check
.PHONY: check lint check-assets assets scaffold verify-assets clean help

check: lint check-assets

lint:
	for script in tools/*.sh; do bash -n "$$script"; done
	sh -n tools/dp-run
	shellcheck tools/*.sh tools/dp-run
	python3 -c 'import glob, yaml; files = sorted(glob.glob(".github/**/*.yml", recursive=True) + glob.glob("safe-settings/**/*.yml", recursive=True)); [yaml.safe_load(open(f, encoding="utf-8")) for f in files]; print(f"{len(files)} YAML files parsed")'

check-assets:
	find assets -path assets/templates -prune -o -name '*.svg' -print0 | xargs -0 xmllint --noout
	rm -rf .scaffold-check && mkdir .scaffold-check && cp -r assets tools .scaffold-check/ \
		&& .scaffold-check/tools/scaffold-assets.sh --force --all > /dev/null; \
		status=$$?; rm -rf .scaffold-check; exit $$status
	@status=0; \
	for set in assets/*/; do \
		[ "$$set" = assets/templates/ ] && continue; \
		for file in \
			apple-touch-icon.png favicon-16x16.png favicon-32x32.png favicon.ico \
			icon-256.png icon-512.png icon.svg logo-dark.png logo-dark.svg logo.png \
			logo.svg social-preview.png social-preview.svg; do \
			[ -f "$$set/dist/$$file" ] || { echo "missing $$set/dist/$$file (run make assets)"; status=1; }; \
		done; \
	done; exit $$status

assets:
	tools/generate-assets.sh

scaffold:
	tools/scaffold-assets.sh --force --all

verify-assets: assets
	git diff --exit-code --stat -- assets/ \
		|| { echo "dist/ is out of date: run 'make assets' and commit the result"; exit 1; }

clean:
	rm -rf .scaffold-check

help:
	@sed -n '3,14p' Makefile | sed 's/^# \{0,1\}//'

endif
