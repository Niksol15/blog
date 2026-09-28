#!/usr/bin/env bash
# Production build. Used by CI and by scripts/staging.sh.
# Usage: scripts/build.sh BASE_URL [DEST_DIR]
set -euo pipefail

base_url=${1:?usage: scripts/build.sh BASE_URL [DEST_DIR]}
dest=${2:-public}

hugo --gc --minify --baseURL "$base_url" --destination "$dest"

# GitHub Pages serves <site>/404.html for any missing path, but a multilingual
# Hugo site renders only per-language ones (en/404.html, uk/404.html).
cp "$dest/en/404.html" "$dest/404.html"
