# How to deploy your Hugo site

## Summary

Void theme supports deploying through Github Actions to Github Pages.

## Deployment guide

### Github Actions (recommended)

To deploy your Hugo site to Github Pages, you need to create a actions workflow file named `deploy.yml` in the `.github/workflows` directory.

Here is an example workflow file:

```yaml
name: Deploy hugo site to Github Pages
run-name: 🚀 Deploy hugo site to Github Pages

on:
  push:
    branches: ["main"]

  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

defaults:
  run:
    shell: bash

jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - name: Set architecture
        id: set-arch
        run: |
          ARCH=$(uname -m)
          if [ "$ARCH" == "x86_64" ]; then
            echo "ARCH=amd64" >> $GITHUB_ENV
          elif [ "$ARCH" == "aarch64" ]; then
            echo "ARCH=arm64" >> $GITHUB_ENV
          else
            echo "Unsupported architecture: $ARCH"
            exit 1
          fi

      - name: Install Hugo CLI
        env:
          HUGO_VERSION: 0.144.0
        run: |
          wget -O ${{ runner.temp }}/hugo.deb \
            https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${{ env.HUGO_VERSION }}_linux-${{ env.ARCH }}.deb \
          && sudo dpkg -i ${{ runner.temp }}/hugo.deb
          
      - name: Install Dart Sass
        run: sudo snap install dart-sass
        
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
          
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5
        
      - name: Install Node.js dependencies
        run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
        
      - name: Build with Hugo
        env:
          # For maximum backward compatibility with Hugo modules
          HUGO_ENVIRONMENT: production
          HUGO_ENV: production
        run: |
          hugo \
            --minify \
            --baseURL "${{ steps.pages.outputs.base_url }}/"
          
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    environment:
      name: gh-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-24.04
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

#### Workflow details

- **Production environment**: You need to set the `HUGO_ENVIRONMENT` and `HUGO_ENV` to `production` in the `build` job.
- **Minify**: To minify the output files (HTML, CSS, and JavaScript), you can use the `--minify` flag. This will reduce file sizes by removing unnecessary whitespace, comments, and formatting, improving page load speeds.

## References

- [minify](https://gohugo.io/configuration/all/#minify)
- [Official hugo command line arguments](https://gohugo.io/commands/hugo/)