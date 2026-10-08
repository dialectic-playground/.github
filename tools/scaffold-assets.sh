#!/usr/bin/env bash
# Instantiate the shared design templates (assets/templates/) into an asset set's
# source SVGs: assets/<slug>/{icon,logo,social-preview}.svg, driven by assets/<slug>/asset.env.
#
# Usage:
#   tools/scaffold-assets.sh [--force] <slug>...   # scaffold the named sets
#   tools/scaffold-assets.sh [--force] --all       # every assets/*/asset.env
#
# If assets/<slug>/asset.env does not exist it is created from
# assets/templates/asset.env.example (with REPO/DISPLAY_NAME/GLYPH_TEXT defaulted
# from <slug>) and the script stops so you can edit it first.
# Existing SVGs are never overwritten without --force (they may be hand-tuned).
# shellcheck disable=SC2089,SC2090  # font lists deliberately contain literal quotes (CSS)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS="$ROOT/assets"
TEMPLATES="$ASSETS/templates"

FONT_MONO="'JetBrains Mono', 'DejaVu Sans Mono', Menlo, Consolas, monospace"
FONT_SANS="Inter, 'Segoe UI', 'DejaVu Sans', 'Helvetica Neue', Arial, sans-serif"
ORG_TITLE="Dialectic Playground"

usage() { sed -n '2,/^[^#]/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}" | grep -v '^shellcheck'; exit "${1:-0}"; }
die() { echo "error: $*" >&2; exit 1; }

xml_escape() {
  local s=$1
  s=${s//&/&amp;}; s=${s//</&lt;}; s=${s//>/&gt;}; s=${s//\"/&quot;}
  printf '%s' "$s"
}

min() { (( $1 < $2 )) && echo "$1" || echo "$2"; }
max() { (( $1 > $2 )) && echo "$1" || echo "$2"; }

# Substitute only the variables we own, so any other "$" in a template survives.
# shellcheck disable=SC2016  # literal ${...} names for envsubst
VARS='${ORG_TITLE} ${KIND} ${REPO} ${DISPLAY_NAME} ${ACCENT} ${GLYPH_COLOR} ${GLYPH_TEXT}
${GLYPH_SVG} ${GLYPH_FONT_SIZE} ${GLYPH_BASELINE} ${MARK_SVG} ${FONT_MONO} ${FONT_SANS}
${TAGLINE_1} ${TAGLINE_2} ${LOGO_WIDTH} ${LOGO_TITLE_FONT_SIZE} ${LOGO_TEXT_SVG}
${SOCIAL_TITLE_FONT_SIZE} ${SOCIAL_TEXT_SVG}'
render() { envsubst "$VARS" < "$1"; }

create_env() {
  local slug=$1 dir="$ASSETS/$1"
  mkdir -p "$dir"
  sed -e "s|^REPO=\"example\"|REPO=\"$slug\"|" \
      -e "s|^DISPLAY_NAME=\"example\"|DISPLAY_NAME=\"$slug\"|" \
      -e "s|^GLYPH_TEXT=\"ex\"|GLYPH_TEXT=\"${slug:0:3}\"|" \
      "$TEMPLATES/asset.env.example" > "$dir/asset.env"
  echo "created ${dir#"$ROOT"/}/asset.env — edit it, then re-run: tools/scaffold-assets.sh $slug"
}

scaffold() {
  local slug=$1 force=$2 dir="$ASSETS/$1"
  [[ $slug == templates ]] && die "'templates' is reserved"
  if [[ ! -f $dir/asset.env ]]; then create_env "$slug"; return 0; fi

  # Each set is scaffolded in a subshell so asset.env values don't leak between sets.
  (
    KIND="" REPO="" DISPLAY_NAME="" ACCENT="" GLYPH_COLOR="" GLYPH_TEXT="" GLYPH_FILE=""
    TAGLINE_1="" TAGLINE_2=""
    # shellcheck source=/dev/null
    source "$dir/asset.env"
    [[ $KIND == org || $KIND == repo ]] || die "$slug: KIND must be 'org' or 'repo'"
    for v in REPO DISPLAY_NAME ACCENT GLYPH_COLOR; do
      [[ -n ${!v} ]] || die "$slug: $v is required"
    done
    [[ -n $GLYPH_FILE || -n $GLYPH_TEXT ]] || die "$slug: set GLYPH_TEXT or GLYPH_FILE"
    (( ${#GLYPH_TEXT} <= 3 )) || echo "warn   $slug: GLYPH_TEXT longer than 3 chars will be tiny" >&2
    local v val
    for v in TAGLINE_1 TAGLINE_2; do
      val=${!v}
      (( ${#val} <= 42 )) || echo "warn   $slug: $v is ${#val} chars; >42 may overflow the social preview" >&2
    done

    # Layout math uses the raw (unescaped) lengths; ~0.6em advance for monospace.
    local name_len=${#DISPLAY_NAME} glyph_len=${#GLYPH_TEXT}
    GLYPH_FONT_SIZE=$(min 96 $(( 10000 / (60 * (glyph_len > 0 ? glyph_len : 1)) )))
    GLYPH_BASELINE=$(( GLYPH_FONT_SIZE * 30 / 100 ))
    LOGO_TITLE_FONT_SIZE=$(min 92 $(( 100000 / (60 * name_len) )))   # keep title ≤ ~1000px
    SOCIAL_TITLE_FONT_SIZE=$(min 120 $(( 62000 / (60 * name_len) )))  # keep title ≤ ~620px
    if [[ $KIND == org ]]; then
      LOGO_WIDTH=800
    else
      LOGO_WIDTH=$(( 290 + $(max 440 $(( name_len * LOGO_TITLE_FONT_SIZE * 62 / 100 ))) + 30 ))
    fi

    REPO=$(xml_escape "$REPO"); DISPLAY_NAME=$(xml_escape "$DISPLAY_NAME")
    GLYPH_TEXT=$(xml_escape "$GLYPH_TEXT")
    TAGLINE_1=$(xml_escape "$TAGLINE_1"); TAGLINE_2=$(xml_escape "$TAGLINE_2")
    export ORG_TITLE KIND REPO DISPLAY_NAME ACCENT GLYPH_COLOR GLYPH_TEXT FONT_MONO FONT_SANS \
           TAGLINE_1 TAGLINE_2 GLYPH_FONT_SIZE GLYPH_BASELINE LOGO_WIDTH \
           LOGO_TITLE_FONT_SIZE SOCIAL_TITLE_FONT_SIZE

    if [[ -n $GLYPH_FILE ]]; then
      [[ -f $TEMPLATES/glyphs/$GLYPH_FILE.svg ]] || die "$slug: no glyph assets/templates/glyphs/$GLYPH_FILE.svg"
      GLYPH_SVG=$(render "$TEMPLATES/glyphs/$GLYPH_FILE.svg")
    else
      GLYPH_SVG=$(render "$TEMPLATES/partials/glyph-text.svg.tmpl")
    fi
    export GLYPH_SVG
    MARK_SVG=$(render "$TEMPLATES/partials/mark.svg.tmpl")
    LOGO_TEXT_SVG=$(render "$TEMPLATES/partials/logo-text.$KIND.svg.tmpl")
    SOCIAL_TEXT_SVG=$(render "$TEMPLATES/partials/social-text.$KIND.svg.tmpl")
    export MARK_SVG LOGO_TEXT_SVG SOCIAL_TEXT_SVG

    for name in icon logo social-preview; do
      local out="$dir/$name.svg"
      if [[ -f $out && $force != 1 ]]; then
        echo "skip   ${out#"$ROOT"/} (exists; use --force to overwrite)"
        continue
      fi
      render "$TEMPLATES/$name.svg.tmpl" > "$out"
      if command -v xmllint >/dev/null && ! xmllint --noout "$out"; then die "invalid XML: $out"; fi
      echo "wrote  ${out#"$ROOT"/}"
    done
  )
}

main() {
  command -v envsubst >/dev/null || die "envsubst not found (install gettext)"
  local force=0 all=0 slugs=()
  while (( $# )); do
    case $1 in
      -f|--force) force=1 ;;
      -a|--all) all=1 ;;
      -h|--help) usage ;;
      -*) die "unknown option: $1" ;;
      *) slugs+=("${1%/}") ;;
    esac
    shift
  done
  if (( all )); then
    for env in "$ASSETS"/*/asset.env; do
      [[ -e $env ]] && slugs+=("$(basename "$(dirname "$env")")")
    done
  fi
  (( ${#slugs[@]} )) || usage 1
  for slug in "${slugs[@]}"; do scaffold "$slug" "$force"; done
}

main "$@"
