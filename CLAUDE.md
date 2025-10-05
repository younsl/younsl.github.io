# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal tech blog built with Hugo and hosted on GitHub Pages at [younsl.github.io](https://younsl.github.io). The blog uses a custom "okb" (1kb) theme created by the author.

## Architecture

### Hugo Site Structure
- **hugo.yaml**: Main Hugo configuration (requires Hugo v0.148.2 extended)
- **content/**: Site content
  - `blog/`: Blog posts, each in its own directory with `index.md` and assets
  - `about/`: About page content
  - `slides/`: Marp-based presentation slides
- **themes/okb/**: Custom ultra-lightweight Hugo theme (1kb)
- **static/**: Static assets served directly
- **public/**: Generated site output (git-ignored)

### Theme Architecture
The custom "okb" theme in `themes/okb/` provides:
- Ultra-lightweight design focused on minimal footprint and maximum performance
- Dark appearance by default
- Support for Mermaid diagrams
- Custom shortcodes for enhanced content

## Development Commands

### Hugo Site Development
```bash
# Serve locally for development
hugo server

# Serve in production mode
hugo server --environment production --theme okb

# Build static site
hugo

# Build with minification
hugo --environment production --minify

# Containerized development (using Podman/Docker)
podman build -t hugo-blog .
podman run --rm -p 1313:1313 -v $(pwd):/app hugo-blog
```

### Presentation Slides
Located in `content/slides/`. Uses Marp for markdown-to-PDF conversion.

```bash
cd content/slides

# Serve presentations with live reload
make serve

# Build all presentations to PDF
make build

# Preview build without generating files
make build-dry-run

# Clean generated PDFs
make clean
```

### Repository Maintenance
```bash
# Clean entire commit history (use with extreme caution!)
./commit-history-cleaner.sh
# Creates new orphan branch and force-pushes to reset history
```

## Content Management

### Blog Posts
- Each post in `content/blog/{post-name}/`
- Contains `index.md` with frontmatter and content
- Images and assets stored alongside in same directory
- Posts appear chronologically on the site

### Presentations
- Located in `content/slides/{presentation-name}/`
- Source files named `slide-deck.md`
- Build process converts to PDF using containerized Marp
- Generated PDFs stored in `content/slides/`

## Configuration Notes

### Hugo Configuration
- **Minimum Hugo version**: 0.148.2 (extended)
- **Theme**: okb (custom, ultra-lightweight)
- **Markdown renderer**: Goldmark with custom settings
- **Syntax highlighting**: Built-in with `rrt` style
- **Content filtering**: Ignores slide `.md` files during Hugo build

### Container Engine
Podman is the preferred container engine throughout the codebase (Makefiles, scripts), but remains compatible with Docker.

## Important Development Guidelines

### File Management
- ALWAYS prefer editing existing files over creating new ones
- NEVER create documentation files (*.md) or README files unless explicitly requested
- When working with presentations, use the existing build scripts

### Markdown Formatting
- All headers (#, ##, ###, etc.) must be followed by exactly one blank line
- Never place content directly after a header without a blank line
- Maintain consistent spacing for readability

## Deployment and CI/CD

### GitHub Actions
The repository uses GitHub Actions for automated deployment:

- **deploy.yml**: Triggers on pushes to `main`, builds and deploys to GitHub Pages
  - Uses Hugo 0.148.2 extended
  - Includes minification and optimization
  - Deploys to `gh-pages` environment

- **broken-link-finder.yml**: Daily broken link checks using DeadFinder
- **release-theme-okb.yml**: Theme release automation (triggered by version tags)
- **close-pull-request.yml**: Automatically closes PRs (personal repository, no contributions accepted)

### Container Support
- Dockerfile provided for local development
- Alpine Linux base with Hugo extended
- Supports amd64 and arm64 architectures
- Default port: 1313