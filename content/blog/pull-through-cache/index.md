---
title: "pull through cache"
date: 2024-12-26T00:47:20+09:00
lastmod: 2024-12-26T22:26:25+09:00
description: "How to bypass Docker Hub rate limit using ECR pull through cache"
keywords: []
tags: ["aws", "ecr", "container"]
---

## Overview

This post shows how to bypass Docker Hub rate limit using [Pull through cache](https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html).

## Background

Docker Hub returns a 429 Too Many Requests error when you exceed the rate limit for image downloads.

Here is the [pull rate limit for each user type](https://docs.docker.com/docker-hub/download-rate-limit/#pull-rate-limit):

| User Type | Pull Rate Limit |
|-----------|-----------------|
| Anonymous (not logged in) | 100 `docker pull` requests per 6 hours |
| Logged in account | 200 `docker pull` requests per 6 hours |
| Pro or higher (logged in) | No limit |

Here are some ways to avoid Docker Hub rate limit:

1. Use [imagePullSecret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) based on Kubernetes secrets to pull public images.
2. Manually pull images and store them in Private ECR.
3. Use Pull through cache to cache public images in Private ECR.
4. Use [Harbor](https://goharbor.io/)'s [Proxy Cache](https://goharbor.io/docs/2.1.0/administration/configure-proxy-cache/) to cache public images in Harbor.

From my experience with all these methods, **Harbor Proxy is the most convenient and vendor-neutral**. It doesn't lock you into a specific cloud, and if you already use Harbor, you just need to create a Proxy Cache project. This post covers option 3.

## Setup

### Before Pull Through Cache

I needed to pull 15 images for an Airbyte version upgrade.

I didn't know about Pull Through Cache at first. So I manually cached all 15 public images to Private ECR using this tedious workflow:

![Manual workflow before using Pull Through Cache](./1.png)

### After Pull Through Cache

With ECR's Pull Through Cache, you only need to run a single `pull` command. This makes caching multiple public images from different registries much easier and saves pull costs.

Private ECR repositories are created automatically and cache the public images. The best part is that it caches both the container image manifest and image files from public registries, so it works for all CPU architectures.

![Simple workflow after using Pull Through Cache](./2.png)

You need to set up these ECR settings first:

- **Create Registry Template**: Auto-define Permission, Tag, and Lifecycle Policy for Private ECR repositories created by Pull Through Cache.
- **Create Pull Through Cache Rule**: Define credentials for the public registry you want to cache.

## Conclusion

Pull Through Cache simplifies caching public images to Private ECR. Once set up, just run a single `pull` command and ECR handles the rest. If you want to avoid vendor lock-in and run a self-hosted registry, consider Harbor Proxy Cache as an alternative.

## Related Links

- [Pull Through Cache](https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html)
- [Announcing Pull Through Cache Repositories for Amazon Elastic Container Registry](https://aws.amazon.com/blogs/aws/announcing-pull-through-cache-repositories-for-amazon-elastic-container-registry/)
