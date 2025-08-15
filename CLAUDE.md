# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Hugo-based personal tech blog and Helm chart repository hosted at younsl.github.io. It serves dual purposes:
- Personal tech blog at [younsl.github.io](https://younsl.github.io)
- Helm chart repository at [younsl.github.io/charts](https://younsl.github.io/charts)

## Architecture

### Hugo Site Structure
- **hugo.yaml**: Main Hugo configuration file (minimum Hugo v0.148.2 extended)
- **content/**: Site content organized by type
  - `blog/`: Blog posts (each in its own directory with `index.md` and assets)
  - `about/`: About page content
  - `charts/`: Helm charts and chart repository files
  - `slides/`: Presentation slides (Marp markdown to PDF)
- **themes/void/**: Custom Hugo theme (minimalistic, content-first design)
- **static/**: Static assets served directly (includes synchronized chart index)
- **public/**: Generated site output (git-ignored in development)

### Theme Architecture
The site uses a custom Hugo theme called "void" located in `themes/void/`. This theme follows Hugo's standard layout structure with custom SCSS and JavaScript components for a minimalistic design.

## Development Commands

### Hugo Site Development
```bash
# Serve site locally for development
hugo server

# Serve in production mode for testing
hugo server --environment production --theme void

# Build static site
hugo

# Build with specific environment
hugo --environment production --minify

# Build and serve using Docker/Podman (alternative local development)
podman build -t hugo-blog .
podman run --rm -p 1313:1313 -v $(pwd):/app hugo-blog
```

### Presentation Slides
```bash
# Serve presentations with live reload (uses Podman/Docker)
cd content/about/slides
make serve

# Build all presentations to PDF
make build

# Preview build without generating files
make build-dry-run

# Clean generated PDFs
make clean
```

### Helm Chart Management
```bash
# Package and release a new chart
cd content/charts
./cr.sh
# Script will prompt for chart name and handle:
# 1. Chart validation with helm lint
# 2. Chart packaging
# 3. Repository index update
# 4. Moving files to correct locations
```

### Repository Maintenance
```bash
# Clean entire commit history (use with extreme caution!)
./commit-history-cleaner.sh
# This will delete all commit history and create a new initial commit
```

## Content Management

### Blog Posts
- Each blog post lives in `content/blog/{post-name}/`
- Contains `index.md` with frontmatter and content
- Images and assets stored alongside in same directory
- Posts automatically appear in chronological order

### Charts Repository
- Helm charts stored in `content/charts/`
- Chart packages (`.tgz` files) served directly
- Repository index managed via `cr.sh` script
- Index files synchronized between `content/charts/` and `static/`

### Presentations
- Located in `content/about/slides/{presentation-name}/`
- Uses Marp for PDF generation via containerized environment
- Source files named `slide-deck.md`
- Automated build process converts to PDF format
- PDFs are generated in `content/about/slides/` directory

## Configuration Notes

### Hugo Configuration
- Minimum Hugo version: 0.148.2 (extended)
- Theme: void (custom, included in repository)
- Markdown renderer: Goldmark with custom settings
- Syntax highlighting: Built-in with `rrt` style
- Robot.txt and sitemap generation enabled

### Theme Features
- Dark appearance by default
- Minimal footer and navigation
- Support for mathematical expressions via MathJax
- Mermaid diagram support
- Custom shortcodes for enhanced content

### Content Filtering
- Slides directory `.md` files ignored during Hugo build
- Slide assets filtered from Hugo processing
- Clear separation between blog content and presentation content

## Important Development Guidelines

### File Management
- ALWAYS prefer editing existing files over creating new ones
- NEVER create documentation files (*.md) or README files unless explicitly requested
- When working with Helm charts, use the existing `cr.sh` script for packaging and releasing

### Markdown Formatting Rules
- All headers (#, ##, ###, ####, #####, ######) must be followed by exactly one blank line
- Never place content directly after a header without a blank line
- Maintain consistent spacing for better readability

### Chart Release Process
The `cr.sh` script in `content/charts/` automates the complete chart release workflow:
1. Validates chart with `helm lint`
2. Packages chart to `.tgz` file
3. Updates repository index
4. Synchronizes index between `content/charts/` and `static/` directories

## Deployment and CI/CD

### GitHub Actions
The repository uses GitHub Actions for automated deployment:
- **Deploy workflow** (`.github/workflows/deploy.yml`): Triggers on pushes to `main` branch, builds Hugo site with production settings
- **Hugo version**: 0.148.2 (extended) is used in CI/CD pipeline
- **Build process**: Includes minification and optimized asset handling
- **Target**: Deploys to GitHub Pages automatically

Additional workflows:
- **broken-link-finder.yml**: Checks for broken links in the site
- **clean-workflow-runs.yml**: Cleans up old workflow runs
- **release-theme.yml**: Handles theme releases

### Container Support
- Dockerfile provided for containerized local development
- Uses Alpine Linux base with Hugo extended binary
- Supports both Podman and Docker container engines
- Default port: 1313 for local development server
- Architecture: Supports both amd64 and arm64

## Container Engine Preference
The project uses Podman as the preferred container engine throughout the codebase. All Makefiles and scripts are configured to use Podman by default but remain compatible with Docker.