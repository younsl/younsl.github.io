
# younsl.github.io

[![Deploy Hugo site to Pages](https://github.com/younsl/younsl.github.io/actions/workflows/hugo.yml/badge.svg)](https://github.com/younsl/younsl.github.io/actions/workflows/hugo.yml)
[![Badge - Last commit](https://img.shields.io/github/last-commit/younsl/younsl.github.io.svg)](https://github.com/younsl/younsl.github.io/commits/main)
![Badge - Github stars](https://img.shields.io/github/stars/younsl/younsl.github.io.svg?label=stars)
![Badge - Github forks](https://img.shields.io/github/forks/younsl/younsl.github.io.svg?label=forks)
[![Badge - License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/younsl/younsl.github.io/blob/main/LICENSE)
[![Badge - contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/younsl/younsl.github.io/issues)

Personal tech blog. Use [etch](https://github.com/LukasJoswiak/etch) as the hugo theme.

&nbsp;

## Installation

You need to install hugo as a preparation.

```bash
$ brew install hugo
$ hugo version
hugo v0.115.4-dc9524521270f81d1c038ebbb200f0cfa3427cc5+extended darwin/arm64 BuildDate=2023-07-20T06:49:57Z VendorInfo=brew
```

&nbsp;

Add `etch` theme as a submodule using git command.

```bash
$ git submodule init
$ git submodule add https://github.com/LukasJoswiak/etch.git themes/etch
$ git submodule update themes/etch
```

&nbsp;

Check the submodule status.

```bash
$ git submodule status
 3286754ceb4e01b4995551f06ffd0a7c43000fe6 themes/etch (heads/master)
```

&nbsp;

## Run for development

Generate your blog site using etch theme.

```bash
$ hugo server -t etch
$ open http://localhost:1313
```

&nbsp;

## Integrations

Several plugins were integrated with this blog using the Partial function.

- [Google AdSense](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/adsense.html)
- [Utterances](https://github.com/younsl/younsl.github.io/blob/main/layouts/partials/comments.html)
- [Google Search Console](https://github.com/younsl/younsl.github.io/blob/main/static/google3e664c168bbd9088.html)
