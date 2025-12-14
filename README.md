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
- **RSS Feeds** - Per-language feeds (`/en/feed.xml`, `/uk/feed.xml`)

## Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) v0.139.0 or later
- [Go](https://go.dev/doc/install) (for Hugo modules)
- Git

## Development

```bash
# Install dependencies
hugo mod get -u

# Run dev server (includes drafts)
hugo server -D

# Build for production
hugo --gc --minify
```

## Project Structure

```text
.
├── content/en/          # English content
├── content/uk/          # Ukrainian content
├── layouts/partials/    # Custom partials
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
