# younsl.github.io

[![Deploy hugo site to Github Pages](https://github.com/younsl/younsl.github.io/actions/workflows/deploy.yml/badge.svg)](https://github.com/younsl/younsl.github.io/actions/workflows/deploy.yml)
[![Find broken links on a website](https://github.com/younsl/younsl.github.io/actions/workflows/broken-link-finder.yml/badge.svg)](https://github.com/younsl/younsl.github.io/actions/workflows/broken-link-finder.yml)
[![Badge - License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/younsl/younsl.github.io/blob/main/LICENSE)

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

Add `etch` theme as a submodule using `git` command.

```bash
git submodule init
git submodule add https://github.com/LukasJoswiak/etch.git themes/etch
git submodule update themes/etch
```

Check the submodule status.

```console
$ git submodule status
 3286754ceb4e01b4995551f06ffd0a7c43000fe6 themes/etch (heads/master)
```

### Running hugo server

Generate your blog site using [etch](https://github.com/LukasJoswiak/etch) theme.

```bash
hugo server -t etch
open http://localhost:1313
```

If you want to run hugo server locally using the container, use this [dockerfile](https://github.com/younsl/bucket/tree/main/bucket/dockerfiles/hugo) with bootstrap script.

```bash
# Build blog container
docker build -t hugo:dev .

# Run blog container with local blog files mounted
export LOCAL_REPO_PATH=$HOME/github/younsl/younsl.github.io
docker run -d --name hugo -p 1313:1313 -v ${LOCAL_REPO_PATH}:/app hugo:dev
```

Verify the blog container is running.

```console
$ docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS        PORTS                    NAMES
5fc4d6457641   hugo:latest   "hugo server -t etch…"   12 hours ago   Up 12 hours   0.0.0.0:1313->1313/tcp   hugo
```

## Deployment

Deployment method is github actions (beta), not classic. There is no need for any additional branches.

It is recommended to use the Standard Hugo Workflow provided by Github Pages. See my hugo deployment workflow on [this repository](./.github/workflows/hugo.yml).

## Integrations

Several plugins were integrated with this blog using the [partials](https://gohugo.io/templates/partials/) function.

| Status | Integration Name | Description | Integration Method |
|--------|------------------|-------------|--------------------|
| <small>In-use</small> | Google Adsense | Google Ads | [Hugo partials](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/adsense.html) |
| <small>In-use</small> | Google Search Console | SEO for Google | [Static file](https://github.com/younsl/younsl.github.io/blob/main/static/google3e664c168bbd9088.html) |
| <small>In-use</small> | Utterances | Page comment plugin | [Hugo partials](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/comments.html) |
