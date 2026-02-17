# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal tech blog built with Zola v0.22.0 and hosted on GitHub Pages at [younsl.github.io](https://younsl.github.io).

## Architecture

### Zola Site Structure
- **config.toml**: Main Zola configuration
- **content/**: Site content
  - `blog/`: Blog posts, each in its own directory with `index.md` and assets
  - `about/`: About page (index.md, resume.html, resume.pdf)
- **templates/**: Tera template files (base.html, page.html, index.html, etc.)
- **sass/**: SCSS stylesheets (main.scss) and syntax highlighting theme (monochrome.json)
- **static/**: Static assets (fonts, images, etc.)
- **public/**: Generated site output (git-ignored)

### Design
- Ultra-lightweight design focused on minimal footprint and maximum performance
- Dark appearance by default (#000 background, #fafafa text)
- Typography: Montserrat font (16px base size, 1.6 line height) with sans-serif fallback
- Support for Mermaid diagrams via macro
- Syntax highlighting with custom Monochrome theme
- Template files use Tera templating engine

### Template Structure
- **base.html**: Base template with HTML structure, imports macros
- **index.html**: Homepage template showing blog post list
- **page.html**: Individual page/post template with navigation and advertisements
- **section.html**: Section listing template
- **404.html**: Custom 404 error page
- **macros.html**: Reusable template macros (Mermaid script, adsense)

## Development Commands

### Zola Site Development
```bash
# Serve locally for development
zola serve

# Build static site
zola build

# Check content without building
zola check

# Containerized development (using Podman/Docker)
podman build -t zola-blog .
podman run --rm -p 1111:1111 -v $(pwd):/app zola-blog
```

## Content Management

### Blog Posts
- Each post in `content/blog/{post-name}/`
- Contains `index.md` with TOML frontmatter and markdown content
- Images and assets stored alongside in same directory
- Posts appear chronologically on homepage

### Blog Post Frontmatter
```toml
---
title: "post title"
date: 2024-11-23T02:41:15+09:00
lastmod: 2024-11-23T23:34:22+09:00  # optional
description: "Brief description"
keywords: []
tags: ["tag1", "tag2"]

[extra]
pinnedToTop = true  # optional: pins post to top of homepage
---
```

### Creating a New Post
```bash
# Create post directory and file
mkdir -p content/blog/my-new-post
touch content/blog/my-new-post/index.md
# Add frontmatter and content, then place images in same directory
```

### Container Support
- Dockerfile provided for local development
- Alpine Linux 3.22 base with Zola installed via apk
- Default port: 1111
- Live reload enabled

## Important Development Guidelines

### File Management
- ALWAYS prefer editing existing files over creating new ones
- NEVER create documentation files (*.md) or README files unless explicitly requested

### Markdown Formatting
- All headers (#, ##, ###, etc.) must be followed by exactly one blank line
- Never place content directly after a header without a blank line
- Maintain consistent spacing for readability

### Template Editing
- Templates use Tera syntax with `{% %}` for logic and `{{ }}` for variables
- Maintain consistent 2-space indentation in templates
- Add descriptive comments using `{# #}` syntax
- Keep templates readable with logical section separation

## Deployment and CI/CD

### GitHub Actions
The repository uses GitHub Actions for automated deployment:

- **deploy.yml**: Triggers on pushes to `main`, builds and deploys to GitHub Pages
  - Uses Zola v0.22.0
  - Builds with `zola build --base-url`
  - Deploys to `gh-pages` environment

- **broken-link-finder.yml**: Daily broken link checks using DeadFinder