# Configuration

## Summary

This document describes the details of the configuration of the `void` theme.

## Configuration details

### Show more contents in main page

If you want to setup read more feature in main page, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# your.github.io/hugo.yaml
params:
  entries:
  - post_list:
      limit: 2
      # Post list page includes only posts in the content/blog/ directory.
      section: blog
      show_more: true
      show_more_text: "Show more ..."
      show_more_url: /blog
```

Only 2 posts are displayed in the main page. Show more button will redirect to `/blog` page.

If you want to hide the show more button, you can set the following configuration to disable the show more feature.

```yaml
# your.github.io/hugo.yaml
params:
  entries:
  - post_list:
      limit: 0
      # Post list page includes only posts in the content/blog/ directory.
      section: blog
      show_more: false
      show_more_text: null
      show_more_url: null
```

If you want to include all posts anywhere, you can omit `section` parameter.

```yaml
# your.github.io/hugo.yaml
params:
  entries:
  - post_list:
      limit: 0
      show_more: false
      show_more_text: null
      show_more_url: null
```

### Appearance

This theme supports three types of appearance: **dark mode**, **light mode**, and **auto**.

If you want to toggle **dark mode**, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# your.github.io/hugo.yaml
params:
  theme_config:
    appearance: dark
```

If you want to toggle **light mode**, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# your.github.io/hugo.yaml
params:
  theme_config:
    appearance: light
```

If you want to  automatically by user preference, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# your.github.io/hugo.yaml
params:
  theme_config:
    appearance: auto
```

### Toggle footer

If you want to toggle footer appearance, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# your.github.io/hugo.yaml
params:
  theme_config:
    isShowFooter: false
```

If you want to show footer, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# your.github.io/hugo.yaml
params:
  theme_config:
    isShowFooter: true
```