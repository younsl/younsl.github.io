---
title: "argocd sharding limit"
date: 2026-01-17T12:54:00+09:00
lastmod: 2026-01-17T12:54:00+09:00
description: "ArgoCD 2.13 sharding works at cluster level, not application level"
keywords: []
tags: ["argocd", "kubernetes", "devops"]
---

## Overview

ArgoCD 2.13 has a sharding limitation that many people don't know about. The application-controller sharding only works at the **cluster level**, not the application level.

This means if you have 450 applications all running in the same cluster (`kubernetes.default.svc`), they all go to one shard. Only one controller pod does all the work. The other controller pods sit idle.

## The Problem

I run 450 applications in a single in-cluster setup. All applications use the same cluster endpoint: `kubernetes.default.svc`.

When I scaled the application-controller StatefulSet from 1 to 2 replicas, I expected the workload to split between them. But that didn't happen.

Looking at the logs from `argocd-application-controller-1`:

```log
time="2025-10-02T10:03:03Z" level=warning msg="The cluster https://kubernetes.default.svc has no assigned shard."
time="2025-10-02T10:03:03Z" level=warning msg="The cluster https://kubernetes.default.svc has no assigned shard."
time="2025-10-02T10:03:03Z" level=warning msg="The cluster https://kubernetes.default.svc has no assigned shard."
time="2025-10-02T10:41:49Z" level=info msg="Cluster https://kubernetes.default.svc has been assigned to shard 0"
```

The cluster got assigned to shard 0. That means `controller-0` handles everything. `controller-1` does nothing.

## Why This Happens

ArgoCD shards by cluster, not by application. The sharding algorithm looks at the cluster URL and assigns it to a shard number.

```text
+------------------+     +------------------+
|  controller-0    |     |  controller-1    |
|  (shard 0)       |     |  (shard 1)       |
+------------------+     +------------------+
        |                        |
        v                        v
  450 applications           0 applications
  (all in-cluster)           (idle)
```

When all your applications use the same cluster, they all go to the same shard. Adding more controller replicas doesn't help.

## Impact

This limitation breaks horizontal scaling for single-cluster setups:

- 1 replica: 1 active controller handles 450 apps
- 2 replicas: 1 active controller handles 450 apps, 1 idle
- 5 replicas: 1 active controller handles 450 apps, 4 idle

No matter how many replicas you add, only one controller does the work. This is because the sharding algorithm hashes the cluster URL to determine which shard handles it. Since all applications point to the same `kubernetes.default.svc`, they always hash to the same shard number.

## Workarounds

### Vertical Scaling

The only working option right now is vertical scaling. Give the single active controller more CPU and memory.

```yaml
# argocd-application-controller StatefulSet
spec:
  resources:
    requests:
      cpu: "2"
      memory: "4Gi"
    limits:
      memory: "8Gi"
```

Note: CPU limits are intentionally not set. This is still debated, but the general recommendation is to avoid CPU limits. CPU limits cause throttling even when the node has spare CPU capacity. This can slow down your controller for no good reason. Memory limits are still recommended to prevent OOM issues.

This approach has its own limits. You can only scale up so far before hitting node resource constraints.

### Centralized ArgoCD

If you use a centralized ArgoCD setup that manages multiple external clusters, sharding works as expected. Each cluster has a different endpoint, so they get assigned to different shards.

```text
+------------------+     +------------------+
|  controller-0    |     |  controller-1    |
|  (shard 0)       |     |  (shard 1)       |
+------------------+     +------------------+
        |                        |
        v                        v
  cluster-a.example.com    cluster-b.example.com
  (150 apps)               (150 apps)
```

This is the architecture that ArgoCD sharding was designed for. If you can move from single in-cluster setup to centralized multi-cluster management, horizontal scaling of application-controller replicas will work.

### Wait for Application-Level Sharding

The ArgoCD community knows about this issue. [Discussion #14346](https://github.com/argoproj/argo-cd/discussions/14346) specifically requests sharding by Application or Project for single-cluster setups. Users report pushing controllers to 4 cores and 12GB memory due to OOMKills when managing hundreds of applications in one cluster.

Application-level sharding would distribute applications evenly across controller replicas, regardless of which cluster they belong to. But this feature is not available yet.

## Key Takeaways

- ArgoCD 2.13 shards by cluster, not by application
- Single-cluster setups cannot benefit from horizontal scaling of application-controller replicas
- All applications in `kubernetes.default.svc` go to shard 0
- Scaling controller replicas from 1 to N gives no performance gain
- Vertical scaling is the only current option for single-cluster deployments

## References

- [ArgoCD High Availability](https://argo-cd.readthedocs.io/en/stable/operator-manual/high_availability/)
- [Discussion #14346: Sharding by Application or Project](https://github.com/argoproj/argo-cd/discussions/14346)
- [Issue #4284: Controller horizontal scaling](https://github.com/argoproj/argo-cd/issues/4284)
- [Issue #6125: Load between controllers (argocd-application-controller) is not evenly distributed](https://github.com/argoproj/argo-cd/issues/6125#issuecomment-3360729444)
