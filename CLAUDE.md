# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal tech blog built with Zola v0.21.0 and hosted on GitHub Pages at [younsl.github.io](https://younsl.github.io). The blog uses a custom "okb" (1kb) theme created by the author.

## Architecture

### Zola Site Structure
- **config.toml**: Main Zola configuration
- **content/**: Site content
  - `blog/`: Blog posts, each in its own directory with `index.md` and assets
  - `about/`: About page content
- **themes/okb/**: Custom ultra-lightweight Zola theme (1kb)
  - `templates/`: Tera template files (base.html, page.html, index.html, etc.)
  - `sass/`: SCSS stylesheets (main.scss)
  - `static/`: Theme static assets
- **static/**: Site-level static assets served directly
- **public/**: Generated site output (git-ignored)

### Theme Architecture
The custom "okb" theme in `themes/okb/` provides:
- Ultra-lightweight design focused on minimal footprint and maximum performance
- Dark appearance by default (#0f0e0e background, #fafafa text)
- Typography: Montserrat font (16px base size, 1.6 line height) with sans-serif fallback
- Support for Mermaid diagrams via macro
- Syntax highlighting with gray-matter-dark theme
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

## Configuration Notes

### Zola Configuration (config.toml)
- **Base URL**: https://younsl.github.io
- **Theme**: okb (custom, ultra-lightweight)
- **Markdown renderer**: Built-in with syntax highlighting enabled
- **Syntax highlighting theme**: gray-matter-dark
- **SASS compilation**: Enabled (compile_sass = true)
- **HTML minification**: Enabled (minify_html = true)

### Syntax Highlighting
- Highlighted lines use `mark` or `.highlighted` class
- Background color: #2a2a2a
- Text color: #ffffff (white)
- Code blocks background: #111

### Container Support
- Dockerfile provided for local development
- Alpine Linux 3.21 base with Zola installed via apk
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
  - Uses Zola v0.21.0
  - Builds with `zola build --base-url`
  - Deploys to `gh-pages` environment

- **broken-link-finder.yml**: Daily broken link checks using DeadFinder
- **release-theme-okb.yml**: Theme release automation (triggered by version tags)
- **close-pull-request.yml**: Automatically closes PRs (personal repository, no contributions accepted)