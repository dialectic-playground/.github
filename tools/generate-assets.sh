#!/usr/bin/env bash
# Render every asset set's source SVGs into distributable files under assets/<slug>/dist/.
#
# Usage:
#   tools/generate-assets.sh            # all sets (every assets/*/ except templates/)
#   tools/generate-assets.sh <slug>...  # only the named sets
#
# Requires: inkscape >= 1.0, ImageMagick (magick, or convert for IM6).
#
# From icon.svg:           icon.svg (text outlined), icon-512.png, icon-256.png,
#                          apple-touch-icon.png (180, square full-bleed), favicon-32x32.png,
#                          favicon-16x16.png, favicon.ico (16/32/48)
# From logo.svg:           logo.svg / logo-dark.svg (text outlined, cropped + 12px pad),
#                          logo.png / logo-dark.png (400px tall)
# From social-preview.svg: social-preview.svg (text outlined), social-preview.png (1280x640)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS="$ROOT/assets"

# Dark-theme wordmark colors, injected at the logo's /*@theme-override*/ marker.
LOGO_DARK_CSS='.dp-ink { fill: #F1F5F9; } .dp-muted { fill: #94A3B8; }'

usage() { sed -n '2,/^[^#]/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}" | grep -v '^shellcheck'; exit "${1:-0}"; }
die() { echo "error: $*" >&2; exit 1; }
rel() { printf '%s' "${1#"$ROOT"/}"; }

check_deps() {
  command -v inkscape >/dev/null || die "inkscape not found"
  if command -v magick >/dev/null; then IM=(magick)
  elif command -v convert >/dev/null; then IM=(convert)
  else die "ImageMagick not found (need magick or convert)"; fi
  local f
  for f in "JetBrains Mono" "Inter"; do
    if command -v fc-match >/dev/null && ! fc-match "$f" | grep -qi "${f%% *}"; then
      echo "note: font '$f' not installed; text renders with a fallback font" >&2
    fi
  done
}

# inkscape SRC  then any number of  "OUT:WIDTHxHEIGHT"  PNG exports, in one process.
export_pngs() {
  local src=$1; shift
  local actions="" spec out size
  for spec in "$@"; do
    out=${spec%:*}; size=${spec##*:}
    actions+="export-type:png;export-background-opacity:0;export-width:${size%x*};export-height:${size#*x};"
    actions+="export-filename:$out;export-do;"
  done
  inkscape --actions="$actions" "$src" 2>/dev/null
}

# Plain SVG with text converted to paths, so it renders identically without our fonts.
export_outlined_svg() {
  local src=$1 out=$2; shift 2
  inkscape "$src" --export-type=svg --export-plain-svg --export-text-to-path "$@" \
    --export-filename="$out" 2>/dev/null
}

# Grow the root <svg>'s viewBox/width/height by PAD on every side
# (inkscape ignores --export-margin for SVG output, so tight crops need this).
pad_svg() {
  local svg=$1 pad=$2 vb x y w h
  vb=$(grep -m1 -o 'viewBox="[^"]*"' "$svg" | sed 's/viewBox="\(.*\)"/\1/')
  read -r x y w h <<<"$vb"
  read -r x y w h <<<"$(awk -v x="$x" -v y="$y" -v w="$w" -v h="$h" -v p="$pad" \
    'BEGIN { printf "%g %g %g %g", x - p, y - p, w + 2 * p, h + 2 * p }')"
  sed -i -e "0,/viewBox=\"[^\"]*\"/s//viewBox=\"$x $y $w $h\"/" \
         -e "0,/ width=\"[^\"]*\"/s// width=\"$w\"/" \
         -e "0,/ height=\"[^\"]*\"/s// height=\"$h\"/" "$svg"
}

generate_set() {
  local dir=$1 slug
  slug=$(basename "$dir")
  local dist="$dir/dist" tmp="$TMP/$slug"
  mkdir -p "$dist" "$tmp"
  echo "== $slug"

  if [[ -f $dir/icon.svg ]]; then
    # apple-touch-icon: iOS applies its own mask, so render the tile full-bleed (no corner radius).
    sed 's/\(class="dp-tile"[^>]*\) rx="[0-9.]*"/\1 rx="0"/' "$dir/icon.svg" > "$tmp/icon-square.svg"
    export_pngs "$dir/icon.svg" \
      "$dist/icon-512.png:512x512" "$dist/icon-256.png:256x256" \
      "$dist/favicon-32x32.png:32x32" "$dist/favicon-16x16.png:16x16" "$tmp/favicon-48.png:48x48"
    export_pngs "$tmp/icon-square.svg" "$dist/apple-touch-icon.png:180x180"
    "${IM[@]}" "$dist/favicon-16x16.png" "$dist/favicon-32x32.png" "$tmp/favicon-48.png" "$dist/favicon.ico"
    export_outlined_svg "$dir/icon.svg" "$dist/icon.svg"
    echo "   icon           -> icon.svg icon-512.png icon-256.png apple-touch-icon.png favicon-{16x16,32x32}.png favicon.ico"
  fi

  if [[ -f $dir/logo.svg ]]; then
    sed "s|/\*@theme-override\*/|$LOGO_DARK_CSS|" "$dir/logo.svg" > "$tmp/logo-dark.svg"
    export_outlined_svg "$dir/logo.svg" "$dist/logo.svg" --export-area-drawing
    export_outlined_svg "$tmp/logo-dark.svg" "$dist/logo-dark.svg" --export-area-drawing
    pad_svg "$dist/logo.svg" 12
    pad_svg "$dist/logo-dark.svg" 12
    inkscape "$dist/logo.svg" --export-type=png --export-background-opacity=0 --export-height=400 \
      --export-filename="$dist/logo.png" 2>/dev/null
    inkscape "$dist/logo-dark.svg" --export-type=png --export-background-opacity=0 --export-height=400 \
      --export-filename="$dist/logo-dark.png" 2>/dev/null
    echo "   logo           -> logo.svg logo-dark.svg logo.png logo-dark.png"
  fi

  if [[ -f $dir/social-preview.svg ]]; then
    export_pngs "$dir/social-preview.svg" "$dist/social-preview.png:1280x640"
    export_outlined_svg "$dir/social-preview.svg" "$dist/social-preview.svg"
    echo "   social-preview -> social-preview.svg social-preview.png"
  fi

  # Strip timestamps/metadata so re-running produces byte-identical PNGs (clean git diffs).
  local png
  for png in "$dist"/*.png; do
    "${IM[@]}" "$png" -strip -define png:exclude-chunks=date,time "$png"
  done
}

main() {
  case ${1:-} in -h|--help) usage ;; esac
  check_deps
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  local dirs=() d
  if (( $# )); then
    for d in "$@"; do
      d="$ASSETS/${d%/}"
      [[ -d $d ]] || die "no asset set: $(rel "$d")"
      dirs+=("$d")
    done
  else
    for d in "$ASSETS"/*/; do
      d=${d%/}
      [[ $(basename "$d") == templates ]] && continue
      compgen -G "$d/*.svg" >/dev/null && dirs+=("$d")
    done
  fi
  (( ${#dirs[@]} )) || die "no asset sets found under $(rel "$ASSETS")"
  for d in "${dirs[@]}"; do generate_set "$d"; done
}

main "$@"
