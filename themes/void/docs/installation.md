# Installation

## Summary

This document describes that how to install the `void` theme in your hugo site.

## Prerequisites

### hugo CLI

You need to install hugo in your machine. Please refer to the [Hugo Installation Guide](https://gohugo.io/getting-started/installing/) for more details.

If you are using [homebrew](https://brew.sh/) as your package manager, you can install hugo CLI by the following command easily.

```bash
brew install hugo
hugo version
```

## Theme Installation

### 1. Install void theme as a submodule

Void theme have to be installed in the `themes` directory in your hugo repository. For example, the tree of the hugo repository is as follows.

> [!WARNING]
> With v0.109.0 and earlier the basename of the site configuration file was `config.yaml` instead of `hugo.yaml`. The `config.yaml` file is deprecated. Please use the `hugo.yaml` file instead.

```bash
younsl.github.io/
├── LICENSE
├── README.md
├── hugo.toml
├── content/
│   ├── _index.md
│   └── blog/
├── static/
└── themes/    # All themes are located in the themes directory
    └── void/  # All themes are located in the themes directory
```

You can install void theme as a submodule in your hugo repository:

```bash
git submodule init
git submodule add https://github.com/younsl/younsl.github.io themes/void
git submodule update themes/void
```

### 2. Set site configuration

You need to set the site configuration in your hugo repository named `hugo.toml` or `hugo.yaml`. Hugo configuration file supports these three syntaxes: `.toml`, `.yaml`, and `.json`. See more details in [Hugo Configuration](https://gohugo.io/getting-started/configuration/) page.

#### YAML syntax (recommended)

Highly recommended to use YAML syntax rather than TOML syntax for the site configuration.

Why YAML is recommended rather than TOML:
- Readability: Indentation-based structure is more intuitive than TOML
- Simplicity: Less syntax characters (no curly braces or brackets needed)
- Better for complex configs: Simpler way to write lists and nested maps
- Ease of use: YAML is more user-friendly for configuration files

Set the following configuration in your `hugo.yaml` file.

- `baseURL` : The base URL of your site. This should be your GitHub Pages URL (e.g. `https://<YOUR_GITHUB_USERNAME>.github.io`).
- `title` : The title of your site.
- `theme` : The theme you want to use. The important thing is that the theme name has to be `void`.
- `languageCode` : The language code of your site.
- `disableKinds` : The kinds of content you want to disable.
- `ignoreLogs` : The logs you want to ignore.

The following is an example of the configuration in the `hugo.yaml` file.

```yaml
baseURL: https://younsl.github.io
title: younsl
theme: void
languageCode: en-US
disableKinds: 
  - taxonomy
  - term
ignoreLogs: 
  - warning-goldmark-raw-html

module:
  hugoVersion:
    extended: true
    min: 0.144.0

markup:
  goldmark:
    parser:
      attribute:
        block: true
        title: true
  
  highlight:
    anchorLineNos: true
    codeFences: true
    guessSyntax: true
    hl_Lines: ''
    hl_inline: false
    lineAnchors: ''
    lineNoStart: 1
    lineNos: false
    lineNumbersInTable: true
    noClasses: true
    noHl: false
    style: rrt
    tabWidth: 4
  
  tableOfContents:
    startLevel: 2
    endLevel: 3
    ordered: false

params:
  theme_config:
    appearance: dark
    back_home_text: ".."
    date_format: 2006-01-02
    isListGroupByDate: false
    isShowFooter: false
    titleLinkEnable: true
    titleLink: /about
  
  entries:
  - post_list:
      limit: 0
      section: blog
      show_more: false
      show_more_text: ""
      show_more_url: ""
```

#### TOML syntax

The following is an example of the configuration in the `hugo.toml` file. It's all the same as the above YAML syntax. However, it's not recommended to use TOML syntax for the site configuration file due to the complexity of the syntax and the readability.

```toml
baseURL      = "https://younsl.github.io"
title        = "younsl"
theme        = "void"
languageCode = "en-US"
disableKinds = ["taxonomy", "term"]
ignoreLogs   = ['warning-goldmark-raw-html']

[module]
  [module.hugoVersion]
    extended = true
    min      = "0.144.0"

[markup]
  [markup.goldmark]
    [markup.goldmark.parser]
      [markup.goldmark.parser.attribute]
        block = true
        title = true

  [markup.highlight]
    anchorLineNos      = true
    codeFences         = true
    guessSyntax        = true
    hl_Lines           = ''
    hl_inline          = false
    lineAnchors        = ''
    lineNoStart        = 1
    lineNos            = false
    lineNumbersInTable = true
    noClasses          = true
    noHl               = false
    style              = 'rrt'
    tabWidth           = 4
  
  [markup.tableOfContents]
    startLevel = 2
    endLevel   = 3
    ordered    = false

[params]
  [params.theme_config]
    appearance        = "dark"
    back_home_text    = ".."
    date_format       = "2006-01-02"
    isListGroupByDate = false
    isShowFooter      = false
    titleLinkEnable   = true
    titleLink         = "/about"

  [[params.entries]]
    [params.entries.post_list]
      limit          = 0
      section        = "blog"
      show_more      = false
      show_more_text = ""
      show_more_url  = ""
```

### 3. Verify running the theme locally

To run the `void` theme locally, you need to install the theme in the `themes` directory in your hugo repository.

And then, you can run your blog applying the `void` theme by the following command.

```bash
hugo server --theme void
```

Or shortly,

```bash
hugo server -t void
```

You can access your blog by opening the following URL in your chrome browser.

```bash
open http://localhost:1313
```

Basically hugo server is watching for changes in the `{assets,content,layouts,static}` directory in your hugo repository. If you update any content in the `content` directory, you can see the changes by refreshing the page in real time.

## Next steps

- [Configuration](./configuration.md)

## Reference

- [Hugo Configuration](https://gohugo.io/getting-started/configuration/)