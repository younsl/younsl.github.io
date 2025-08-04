---
title: "charts"
date: 2024-08-11T15:38:15+09:00
lastmod: 2025-03-06T12:26:00+09:00
slug: ""
description: "Index page for helm chart repoistory"
keywords: []
tags: ["helm", "chart"]
showAdvertisement: false
---

## Summary

Helm chart repository hosted on [blog](https://github.com/younsl/blog).

## Usage

If not installed helm, install first using [brew](https://brew.sh/) or other package manager.

```bash
brew install helm
helm version
```

Add the helm chart repository with the name `younsl`.

```bash
helm repo add younsl https://younsl.github.io/
helm repo update
```

Search all helm charts in the `younsl` chart repository.

```bash
helm search repo younsl
```

The `helm search repo` command checks the status of the charts based on the `index.yaml` file in the helm chart repository.

The `index.yaml` file contains the metadata of the repository and is used for chart search and installation. Check [index file](https://github.com/younsl/blog/blob/main/static/index.yaml) directly.

Download and extract a specific chart locally.

```bash
helm pull younsl/<CHART_NAME> --untar
```

For example, to download and extract the `rbac` chart:

```bash
helm pull younsl/rbac --untar
helm pull younsl/rbac --version 0.2.1 --untar
```

## Available charts

| Chart name | Status | Chart version | App version |
| ---------- | ------ | ------------- | ----------- |
| [**actions-runner**][actions-runner] | Deprecated | 0.1.4 | N/A |
| [**argocd-apps**][argocd-apps] | Active | 1.7.0 | N/A |
| [**backup-utils**][backup-utils] | Deprecated | 0.4.2 | 3.15.1 |
| [**karpenter-nodepool**][karpenter-nodepool] | Active | 1.5.1 | N/A |
| [**rbac**][rbac] | Active | 0.2.1 | N/A |
| [**kube-green-sleepinfos**][kube-green-sleepinfos] | Active | 0.1.0 | N/A |
| [**squid**][squid] | Active | 0.3.0 | 6.10-24.10_beta |

## Important Notes

Please note the following recommendations for deprecated charts. 

1. **backup-utils** (deprecated): Starting from GHES 3.17, this chart has been replaced by the built-in backup service included in the GHES server. It is highly recommended to use the built-in service instead.

2. **actions-runner** (deprecated): Since 2023, it is highly recommended to use the GA (Generally Available) [gha-runner-scale-set](https://github.com/actions/actions-runner-controller/tree/master/charts/gha-runner-scale-set) and [gha-runner-scale-set-controller](https://github.com/actions/actions-runner-controller/tree/master/charts/gha-runner-scale-set-controller) charts instead of this deprecated chart.

[actions-runner]: https://github.com/younsl/blog/tree/main/content/charts/actions-runner/Chart.yaml
[argocd-apps]: https://github.com/younsl/blog/tree/main/content/charts/argocd-apps/Chart.yaml
[backup-utils]: https://github.com/younsl/blog/tree/main/content/charts/backup-utils/Chart.yaml
[karpenter-nodepool]: https://github.com/younsl/blog/tree/main/content/charts/karpenter-nodepool/Chart.yaml
[rbac]: https://github.com/younsl/blog/tree/main/content/charts/rbac/Chart.yaml
[kube-green-sleepinfos]: https://github.com/younsl/blog/tree/main/content/charts/kube-green-sleepinfos/Chart.yaml
[squid]: https://github.com/younsl/blog/tree/main/content/charts/squid/Chart.yaml
