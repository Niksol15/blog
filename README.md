# Nikita Solonko - Personal Tech Blog

A bilingual technical blog about C++, systems programming, and software development. Built with Hugo and the PaperMod theme, deployed on GitHub Pages.

## Features

- **Modern Theme** - Built with [PaperMod](https://github.com/adityatelange/hugo-PaperMod)
- **Bilingual Support** - English and Ukrainian with language switcher
- **Dark/Light Mode** - Theme toggle with preference persistence
- **Comments** - Giscus integration (GitHub Discussions-based) with theme sync
- **Reading Experience** - Reading time, table of contents, syntax highlighting with copy button, breadcrumbs, post navigation
- **Social Sharing** - Twitter/X, LinkedIn, Telegram
- **SEO Optimized** - JSON-LD structured data, Open Graph, Twitter Cards
- **Link Previews** - A 1200x630 card with the title and tags is generated for every page
- **RSS Feeds** - Per-language feeds (`/en/feed.xml`, `/uk/feed.xml`)

## Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) v0.146.0 or later (CI uses v0.162.1)
- [Go](https://go.dev/doc/install) (for Hugo modules)
- Git

## Development

```bash
# Install dependencies
hugo mod get -u

# Run dev server (includes drafts)
hugo server -D

# Build for production (same as CI)
scripts/build.sh https://niksol15.github.io/blog/
```

### Staging

`scripts/staging.sh` builds the git index (what the next commit contains, without untracked drafts) exactly like CI and serves it like GitHub Pages at <http://localhost:1313/blog/>. While it runs, `scripts/check-site.py` crawls it: internal links and assets, Open Graph images, JSON-LD, the 404 page.

```bash
git add <files to commit>
scripts/staging.sh       # terminal 1
scripts/check-site.py    # terminal 2
```

## Project Structure

```text
.
├── content/en/          # English content
├── content/uk/          # Ukrainian content
├── assets/og/           # Open Graph card background and font
├── layouts/partials/    # Custom partials
├── scripts/             # Build, staging and site checks
├── static/              # Static assets
└── hugo.toml            # Configuration
```

## Creating Posts

```bash
# English
hugo new content/en/posts/my-post.md

# Ukrainian
hugo new content/uk/posts/my-post.md
```

## Configuration

Edit [hugo.toml](hugo.toml) for settings (social links, comments, features).

## Deployment

Auto-deploys to <https://niksol15.github.io/blog/> on push to `master` via [GitHub Actions](.github/workflows/hugo.yml).

---

Built with [Hugo](https://gohugo.io/) and [PaperMod](https://github.com/adityatelange/hugo-PaperMod) • [Live Site](https://niksol15.github.io/blog/)
