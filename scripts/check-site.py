#!/usr/bin/env python3
"""Crawls a running build of the blog, starting from the home page and
sitemap.xml, and checks what a visitor or a link preview would hit: every
internal link and asset answers 200, every page has a 1200x630 og:image,
JSON-LD parses, and a missing path gets the 404 page.

Usage: scripts/check-site.py [BASE_URL]    (default http://localhost:1313/blog/)
"""
import html
import json
import re
import struct
import sys
import urllib.error
import urllib.request
from html.parser import HTMLParser
from urllib.parse import urldefrag, urljoin

BASE = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:1313/blog/"


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links, self.og_images, self.json_ld = [], [], []
        self._in_json_ld = False

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        for key in ("href", "src"):
            if a.get(key):
                self.links.append(a[key])
        if tag == "meta" and a.get("property") == "og:image":
            self.og_images.append(a.get("content", ""))
        self._in_json_ld = tag == "script" and a.get("type") == "application/ld+json"

    def handle_data(self, data):
        if self._in_json_ld:
            self.json_ld.append(data)

    def handle_endtag(self, tag):
        self._in_json_ld = False


def fetch(url):
    try:
        with urllib.request.urlopen(url) as r:
            return r.status, r.headers.get_content_type(), r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.headers.get_content_type(), e.read()


def png_size(data):
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    return struct.unpack(">II", data[16:24])


def sitemap_pages(url):
    """All <loc> entries, following a sitemap index into per-language sitemaps."""
    status, _, body = fetch(url)
    if status != 200:
        return []
    pages = []
    for loc in map(html.unescape, re.findall(r"<loc>(.*?)</loc>", body.decode("utf-8"))):
        pages += sitemap_pages(loc) if loc.endswith(".xml") else [loc]
    return pages


errors = []
statuses = {}
queue, seen_pages = [BASE] + sitemap_pages(urljoin(BASE, "sitemap.xml")), set()
og_checked = {}

while queue:
    url = queue.pop()
    if url in seen_pages:
        continue
    seen_pages.add(url)
    status, ctype, body = fetch(url)
    statuses[url] = status
    if status != 200 or ctype != "text/html":
        continue

    page = Page()
    page.feed(body.decode("utf-8"))

    for link in page.links:
        target = urldefrag(urljoin(url, link))[0]
        if not target.startswith(BASE):
            continue
        if target.endswith("/") or target.endswith(".html"):
            queue.append(target)
        elif target not in statuses:
            statuses[target] = fetch(target)[0]

    if "/404.html" not in url:
        if len(page.og_images) != 1:
            errors.append(f"{url}: {len(page.og_images)} og:image tags")
        for img in page.og_images:
            if img not in og_checked:
                s, _, data = fetch(img)
                og_checked[img] = (s, png_size(data) if s == 200 else None)
            s, size = og_checked[img]
            if s != 200 or size != (1200, 630):
                errors.append(f"{url}: og:image {img} -> HTTP {s}, size {size}")

    for block in page.json_ld:
        try:
            json.loads(block)
        except json.JSONDecodeError as e:
            errors.append(f"{url}: invalid JSON-LD ({e})")

for url, status in sorted(statuses.items()):
    if status != 200:
        errors.append(f"{url}: HTTP {status}")

status, _, body = fetch(urljoin(BASE, "no-such-page/"))
if status != 404 or b"error-code" not in body:
    errors.append(f"missing page: HTTP {status}, custom 404 page not served")

print(f"pages: {len(seen_pages)}, urls: {len(statuses)}, og images: {len(og_checked)}")
for e in errors:
    print("FAIL", e)
sys.exit(1 if errors else 0)
