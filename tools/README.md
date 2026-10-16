<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [tools](#tools)
  - [Shared container-first tooling](#shared-container-first-tooling)
  - [Asset scripts](#asset-scripts)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# tools

Scripts for this repository, plus the organization's shared container-first tooling.

| File                                       | Purpose                                                                                                                         |
| :----------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------ |
| [`dp-run`](dp-run)                         | **Shared (canonical copy).** Runs a command in the repository's toolchain container: Podman, then Docker, then the local system |
| [`container.mk`](container.mk)             | **Shared (canonical copy).** Make include that re-runs `make` goals inside the toolchain container                              |
| [`scaffold-assets.sh`](scaffold-assets.sh) | Instantiate `assets/templates/` into an asset set's source SVGs, using `assets/<slug>/asset.env`                                |
| [`generate-assets.sh`](generate-assets.sh) | Render every set's source SVGs into `assets/<slug>/dist/` (PNG, ICO, and text-outlined SVG)                                     |

## Shared container-first tooling

`dp-run` and `container.mk` are the canonical copies for the whole organization. Every other
repository carries byte-identical copies at `tools/dp-run` and `tools/container.mk`, and its CI
fails if they drift. To change them, change them here first, then update every copy (including
`repo-template`) in the same round of pull requests.

```sh
make <goal>                          # runs in the container (DP_RUNTIME=auto)
DP_RUNTIME=docker make <goal>        # force Docker
DP_RUNTIME=local make <goal>         # run on the host
tools/dp-run <command>               # any command in the toolchain environment
make dp-info | dp-shell | dp-image   # inspect, shell into, or build the environment
```

| Variable      | Values                                        | Effect                                                                                       |
| :------------ | :-------------------------------------------- | :------------------------------------------------------------------------------------------- |
| `DP_RUNTIME`  | `auto` (default), `podman`, `docker`, `local` | Selects where tasks run; `auto` tries Podman, then Docker, then the local system             |
| `DP_IMAGE`    | image reference                               | Use this image instead of building `./Containerfile`                                         |
| `DP_PLATFORM` | e.g. `linux/amd64`                            | Build and run for this platform (this repository pins `linux/amd64` for reproducible assets) |
| `DP_RUN_ARGS` | extra `run` arguments                         | Passed to `podman run` / `docker run`                                                        |
| `DP_QUIET`    | `1`                                           | Suppress the one-line runtime banner                                                         |

The full explanation is on the docs site:
[Container-first development](https://dialectic-playground.github.io/docs/explanation/container-first-development/)
and [Container tooling reference](https://dialectic-playground.github.io/docs/reference/container-tooling/).

## Asset scripts

```sh
tools/dp-run tools/scaffold-assets.sh <slug>            # first run creates assets/<slug>/asset.env
tools/dp-run tools/scaffold-assets.sh [--force] <slug>  # write assets/<slug>/{icon,logo,social-preview}.svg
make scaffold                                           # every set, --force
make assets                                             # render dist/ for every set
```

See [`assets/README.md`](../assets/README.md) for the design system and the full workflow.
