#!/usr/bin/env bash
# Builds the git index (exactly what the next commit contains, without
# untracked drafts) the same way CI does, and serves it like GitHub Pages:
# under /blog/, with /blog/404.html for missing paths.
# Usage: scripts/staging.sh [PORT]    (default 1313)
set -euo pipefail

port=${1:-1313}
root=$(git rev-parse --show-toplevel)
snap=$(mktemp -d)
trap 'rm -rf "$snap"' EXIT

git -C "$root" checkout-index --all --prefix="$snap/src/"
# enableGitInfo reads lastmod from the history.
ln -s "$root/.git" "$snap/src/.git"
# Reuse the vendored theme if present; otherwise Hugo downloads the module.
if [[ -d "$root/_vendor" ]]; then
    ln -s "$root/_vendor" "$snap/src/_vendor"
fi

(cd "$snap/src" && HUGO_ENVIRONMENT=production TZ=Europe/Kyiv \
    scripts/build.sh "http://localhost:$port/blog/" "$snap/site/blog")

echo "Staging: http://localhost:$port/blog/"
python3 - "$port" "$snap/site" <<'EOF' &
import functools, http.server, os, sys

port, site = int(sys.argv[1]), sys.argv[2]

class Handler(http.server.SimpleHTTPRequestHandler):
    def send_error(self, code, message=None, explain=None):
        page = os.path.join(site, "blog", "404.html")
        if code != 404 or not os.path.exists(page):
            return super().send_error(code, message, explain)
        body = open(page, "rb").read()
        self.send_response(404)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

handler = functools.partial(Handler, directory=site)
http.server.ThreadingHTTPServer(("127.0.0.1", port), handler).serve_forever()
EOF
server=$!
trap 'kill "$server" 2>/dev/null; rm -rf "$snap"' EXIT
wait "$server"
