# blog

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/younsl/blog?style=flat-square&color=black&logo=githubactions&logoColor=white)](https://github.com/younsl/blog/releases/latest)
[![GitHub license](https://img.shields.io/github/license/younsl/blog?style=flat-square&color=black)](https://github.com/younsl/blog/blob/main/LICENSE)

## Summary

Personal tech blog built with [Hugo][hugo] and hosted on GitHub Pages, available at [younsl.github.io](https://younsl.github.io)

This blog is styled with [**okb**][okb] (1kb), an ultra-lightweight theme I created myself, focused on minimal footprint and maximum performance.

[hugo]: https://gohugo.io/
[okb]: ./themes/okb/

## Getting Started

Follow these steps to run the blog locally on your machine.

### Prerequisites

- Hugo CLI v0.148.2 (extended) or higher

On macOS, you can easily install Hugo using Homebrew:

```bash
brew install hugo
hugo version
```

### Local Development

```bash
# Clone the repository
git clone https://github.com/younsl/younsl.github.io.git
cd younsl.github.io

# Run Hugo development server
hugo server -t okb
```

Open http://localhost:1313/ in your browser
