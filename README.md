<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/dialectic-playground/.github/main/assets/dot-github/dist/logo-dark.svg">
    <img alt="dialectic playground / .github" src="https://raw.githubusercontent.com/dialectic-playground/.github/main/assets/dot-github/dist/logo.svg" height="96">
  </picture>
</p>

# .github

Organization profile, community health defaults, brand assets, and asset tooling for
Dialectic Playground.

📖 **Documentation:** <https://dialectic-playground.github.io/docs/>

## Layout

| Path | Contents |
| :--- | :--- |
| [`profile/README.md`](profile/README.md) | The organization profile shown at [github.com/dialectic-playground](https://github.com/dialectic-playground) |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), [`CONTRIBUTING.md`](CONTRIBUTING.md), [`SECURITY.md`](SECURITY.md), [`SUPPORT.md`](SUPPORT.md) | Organization-wide community health defaults, used by every repository that has no file of its own |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/), [`.github/pull_request_template.md`](.github/pull_request_template.md) | Default issue forms and pull request template for every repository without its own |
| [`assets/`](assets/) | Icons, logos, and social previews for the organization and each repository. See [`assets/README.md`](assets/README.md). |
| [`tools/`](tools/) | Asset scaffolding and generation scripts, and the canonical copies of the shared container tooling (`dp-run`, `container.mk`). See [`tools/README.md`](tools/README.md). |
| [`Makefile`](Makefile), [`Containerfile`](Containerfile), [`.devcontainer/`](.devcontainer/) | Container-first entry points: `make check`, `make assets`, and the toolchain image (Inkscape, ImageMagick, brand fonts) |
| [`safe-settings/`](safe-settings/) | Repository settings as code: defaults, the branch ruleset, and each repository's description, homepage, and topics. See [`safe-settings/README.md`](safe-settings/README.md). |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | CI: `make check` in the container (plus reproducible-asset verification) and natively, DCO |
| [`.github/workflows/image.yml`](.github/workflows/image.yml) | Publishes the toolchain image to `ghcr.io/dialectic-playground/asset-tools` |
| [`.github/workflows/safe-settings.yml`](.github/workflows/safe-settings.yml) | Applies `safe-settings/` to every repository (on change, daily, and on demand) |

## Development

Container-first: run tasks with `make` (or `tools/dp-run <command>`). They run in the
toolchain container via Podman, then Docker, then the local system. `DP_RUNTIME` overrides
the choice. See [`tools/README.md`](tools/README.md).

```sh
make check     # everything CI checks
make assets    # regenerate brand assets
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Pull requests are squash-merged, titles follow
Conventional Commits, and every commit needs a DCO sign-off.

## License

[MIT](LICENSE)
