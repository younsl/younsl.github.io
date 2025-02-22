# Configuration

## Summary

This document describes the details of the configuration of the `void` theme.

## Configuration details

### Show more contents in main page

If you want to setup read more feature in main page, you need to set the following configuration in your `hugo.yaml` file.

```yaml
# <YOUR_HUGO_REPOSITORY>/hugo.yaml
params:
  entries:
  - post_list:
      limit: 5
      show_more: true
      show_more_text: ""
      # If all contents are located in the content/blog directory,
      # you can set show_more_url as "/blog"
      show_more_url: "/blog"
```