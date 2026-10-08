# tools

Scripts for maintaining this repository's shared resources.

| Script | Purpose |
| :-- | :-- |
| [`scaffold-assets.sh`](scaffold-assets.sh) | Instantiate `assets/templates/` into an asset set's source SVGs, using `assets/<slug>/asset.env` |
| [`generate-assets.sh`](generate-assets.sh) | Render every set's source SVGs into `assets/<slug>/dist/` (PNG, ICO, and text-outlined SVG) |

```bash
tools/scaffold-assets.sh <slug>            # first run creates assets/<slug>/asset.env to edit
tools/scaffold-assets.sh [--force] <slug>  # write assets/<slug>/{icon,logo,social-preview}.svg
tools/scaffold-assets.sh [--force] --all   # every set that has an asset.env
tools/generate-assets.sh [<slug>...]       # render dist/ for the named sets, or all of them
```

Requirements: `bash`, `envsubst` (gettext), Inkscape ≥ 1.0, and ImageMagick. `xmllint` is
optional.

See [`assets/README.md`](../assets/README.md) for the design system and the full workflow.
