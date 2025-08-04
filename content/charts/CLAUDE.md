# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with Helm charts in this repository.

## Repository Context

This is the charts directory of a Hugo-based personal tech blog and Helm chart repository. The charts here are served as a Helm repository at [younsl.github.io/charts](https://younsl.github.io/charts).

## Chart Development Commands

### Chart Release Process
```bash
# Package and release a new chart (use this script for all releases)
./cr.sh
# Script will prompt for chart name and handle:
# 1. Chart validation with helm lint
# 2. Chart packaging to .tgz file
# 3. Repository index update
# 4. Moving files between content/charts/ and static/ directories
```

### Manual Chart Operations
```bash
# Validate a specific chart
helm lint {chart-name}

# Package a chart manually (if needed)
helm package {chart-name} --destination .

# Update repository index manually
helm repo index . --url https://younsl.github.io/charts --merge ../../static/index.yaml
```

## Chart Repository Architecture

### File Organization
- **Chart directories**: Each chart has its own directory (e.g., `karpenter-nodepool/`, `rbac/`)
- **Packaged charts**: `.tgz` files are the packaged charts served to users
- **Repository index**: `index.yaml` files are synchronized between here and `../../static/`
- **Release script**: `cr.sh` automates the complete release workflow

### Chart Structure
Each chart follows standard Helm structure:
- `Chart.yaml`: Chart metadata and version
- `values.yaml`: Default configuration values
- `templates/`: Kubernetes manifests with templating
- `README.md`: Chart documentation
- `docs/`: Additional documentation and diagrams

### Repository Synchronization
- Charts are developed in this directory
- Packaged `.tgz` files remain here for organization
- Index files are copied to `../../static/` for Hugo serving
- Hugo serves the static files at the `/charts` URL path

## Important Guidelines

### Chart Versioning
- Always increment chart version in `Chart.yaml` before release
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update `appVersion` if the underlying application version changes

### Release Workflow
1. Make changes to chart in its directory
2. Update `Chart.yaml` version
3. Test chart with `helm lint {chart-name}`
4. Run `./cr.sh` and enter the chart name when prompted
5. Verify the packaged chart and updated index

### File Management
- NEVER manually edit `index.yaml` files
- ALWAYS use `cr.sh` script for releases
- Keep chart directories clean and organized
- Document significant changes in chart README files