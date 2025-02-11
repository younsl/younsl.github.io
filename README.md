# younsl.github.io

Tech blog and chart repository.

## Getting started

### Prerequisite

> [!NOTE]
> Before installing the blog, You need to install [hugo](https://github.com/gohugoio/hugo) `v0.119.0` or higher.

Install hugo using [brew](https://brew.sh) package manager in your local environment.
 
```bash
brew install hugo
hugo version
```

### Installation

Add `nostyleplease` theme as a submodule using `git` command.

> [!TIP]
> Adding the theme as a submodule allows you to easily update it in the future and keep your blog's design consistent with the latest features and fixes.

```bash
git submodule init
git submodule add https://github.com/hanwenguo/hugo-theme-nostyleplease themes/nostyleplease
git submodule update themes/nostyleplease
```

Theme folders like nostyleplease must be under `themes/` directory for the hugo server to find it when running.

```bash
younsl.github.io
├── content
├── config.toml
├── ... more directories ...
└── themes
    └── nostyleplease
```

Check the submodule status.

```console
$ git submodule status
 2cc41d38a6457d325ef0451a593ece1e00dbe60a themes/nostyleplease (heads/main)
```

### Running hugo server

Create your blog site using the [nostyleplease](https://github.com/hanwenguo/hugo-theme-nostyleplease) theme.

```bash
cd younsl.github.io
hugo server -t nostyleplease
open http://localhost:1313
```

If you're familiar with container environments, you can run hugo server in a container for local development. Use this [dockerfile](https://github.com/younsl/box/tree/main/box/dockerfiles/hugo) to build the image and then run the container.

```bash
# Build blog container using the dockerfile
docker build -t hugo:dev .

# Run blog container in background mode (-d) mounting local blog directory to /app directory
cd younsl.github.io
docker run -d --name hugo -p 1313:1313 -v ${PWD}:/app hugo:dev
```

Verify hugo container is running.

```console
$ docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS        PORTS                    NAMES
5fc4d6457641   hugo:latest   "hugo server -t nost…"   12 hours ago   Up 12 hours   0.0.0.0:1313->1313/tcp   hugo
```

Now, open your browser and go to [http://localhost:1313](http://localhost:1313) to view your hugo blog in real-time and start local development.

## Deployment

This blog repository is hosted on GitHub Pages, using a [custom GitHub Actions workflow](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow) for deployment. No additional branches are required for GitHub Pages deployment. For more details on the GitHub Pages deployment pipeline, please refer to [deploy.yml](./.github/workflows/deploy.yml).

## Integrations

Several plugins were integrated with this blog using the [partials](https://gohugo.io/templates/partials/) function.

| Status | Integration Name | Description | Integration Method |
|--------|------------------|-------------|--------------------|
| <small>In-use</small> | Google Adsense | Google Ads | [Hugo partials](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/adsense.html) |
| <small>In-use</small> | Google Search Console | SEO for Google | [Static file](https://github.com/younsl/younsl.github.io/blob/main/static/google3e664c168bbd9088.html) |
