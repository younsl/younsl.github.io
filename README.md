
# younsl.github.io

[![Deploy Hugo site to Pages](https://github.com/younsl/younsl.github.io/actions/workflows/hugo.yml/badge.svg)](https://github.com/younsl/younsl.github.io/actions/workflows/hugo.yml)
[![Badge - License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/younsl/younsl.github.io/blob/main/LICENSE)

Personal tech blog.

## Installation

**Prerequisite**: You need to install [hugo](https://github.com/gohugoio/hugo) `v0.119.0` or higher

```bash
brew install hugo
hugo version
```

Add `etch` theme as a submodule using git command.

```bash
git submodule init
git submodule add https://github.com/LukasJoswiak/etch.git themes/etch
git submodule update themes/etch
```

Check the submodule status.

```bash
$ git submodule status
 3286754ceb4e01b4995551f06ffd0a7c43000fe6 themes/etch (heads/master)
```

## Run for development

Generate your blog site using [etch](https://github.com/LukasJoswiak/etch) theme.

```bash
hugo server -t etch
open http://localhost:1313
```

## Deployment

Deployment method is github actions (beta), not classic. There is no need for any additional branches.

It is recommended to use the Standard Hugo Workflow provided by Github Pages. See my hugo deployment workflow on [this repository](./.github/workflows/hugo.yml).

## Integrations

Several plugins were integrated with this blog using the [partials](https://gohugo.io/templates/partials/) function.

| Status | Integration Name | Description | Integration Method |
|--------|------------------|-------------|--------------------|
| <small>In-use</small> | Google Adsense | Google Ads | [Hugo partials](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/adsense.html) |
| <small>In-use</small> | Utterances | Page comment plugin | [Hugo partials](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/comments.html) |
| <small>In-use</small> | Google Search Console | SEO for Google | [Static file](https://github.com/younsl/younsl.github.io/blob/main/static/google3e664c168bbd9088.html) |
