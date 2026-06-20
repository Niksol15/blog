#!/usr/bin/env bash
# Render the "all roads lead to write()" funnel diagram from diagram.dot.
# Output goes to the site's assets/ tree so Hugo's image render hook resolves it
# (and prefixes the baseURL subpath, e.g. /blog/images/...).
#
#   ./build-diagram.sh         # render the SVG used by the article
#   ./build-diagram.sh png     # also drop a white-background PNG for previewing
set -eu
cd "$(dirname "$0")"
OUT=../../assets/images
mkdir -p "$OUT"
dot -Tsvg diagram.dot -o "$OUT/hello-world-funnel.svg"
echo "wrote $OUT/hello-world-funnel.svg"
if [ "${1:-}" = png ]; then
    dot -Tpng -Gbgcolor=white -Gdpi=140 diagram.dot -o "$OUT/hello-world-funnel.png"
    echo "wrote $OUT/hello-world-funnel.png"
fi
