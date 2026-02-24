# blog

Personal tech blog built with [Zola](https://www.getzola.org/) and hosted at [younsl.github.io](https://younsl.github.io)

## Project Structure

Zola static site with Tera templates and plain CSS.

```
.
├── config.toml          # Zola configuration
├── content/
│   ├── about/           # About page
│   └── blog/            # Blog posts (each post in its own directory)
├── static/
│   ├── fonts/           # Self-hosted Montserrat font
│   ├── main.css         # Stylesheet
│   └── monochrome.json  # Syntax highlighting theme
└── templates/
    ├── base.html        # Base layout
    ├── index.html       # Homepage (post list)
    ├── page.html        # Individual post
    ├── section.html     # Section listing
    ├── macros.html      # Reusable Tera macros
    └── 404.html         # Error page
```
