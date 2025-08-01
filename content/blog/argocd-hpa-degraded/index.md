---
title: "argocd hpa degraded"
date: 2025-08-01T23:14:00+09:00
lastmod: 2025-08-01T23:14:00+09:00
slug: ""
description: "ArgoCD가 자꾸 HPA를 degraded로 오탐한다"
keywords: []
tags: ["devops", "kubernetes"]
---

## Background 

In an EKS 1.32 cluster with ArgoCD 2.13.4 installed, some Applications with HPA attached are running normally, but occasionally false degraded status alarms are being sent. This is still a valid issue, and the solution appears to be setting up [custom health checks](https://argo-cd.readthedocs.io/en/release-2.13/operator-manual/health/#custom-health-checks) for HPA. (https://github.com/argoproj/argo-cd/discussions/7936, https://github.com/argoproj/argo-cd/issues/6287)

<details>
<summary>Custom health check values HPA</summary>

## Not working for me

This ArgoCD Custom Health Check configuration prevents HPA (Horizontal Pod Autoscaler) from being incorrectly marked as degraded during metric collection delays and initial startup.

This uses ArgoCD's standard naming pattern for custom health checks: `resource.customizations.health.<API_GROUP>_<RESOURCE_NAME>`

```yaml
# charts/argocd/values_my.yaml (appVersion v2.13.4)
configs:
  cm:
    resource.customizations.useOpenLibs.autoscaling_HorizontalPodAutoscaler: "true"
    resource.customizations.health.autoscaling_HorizontalPodAutoscaler: |
      hs = {}
      if obj.status ~= nil then
        if obj.status.conditions ~= nil then
          for i, condition in ipairs(obj.status.conditions) do
            if condition.type == "ScalingActive" and condition.reason == "FailedGetResourceMetric" then
                hs.status = "Progressing"
                hs.message = condition.message
                return hs
            end
            if condition.status == "True" then
                hs.status = "Healthy"
                hs.message = condition.message
                return hs
            end
          end
        end
        hs.status = "Healthy"
        return hs
      end
      hs.status = "Progressing"
      return hs
```

⚠️ **Not working for me**: Still getting false alerts. [Custom health checks](https://argo-cd.readthedocs.io/en/release-2.13/operator-manual/health/#custom-health-checks) not properly applied due to health keyword in the middle. It is also discussed here https://github.com/argoproj/argo-cd/issues/6175.

## Working soltuions

### Custom Health Check

Custom health check for HPA:

```yaml
# charts/argocd/values_my.yaml (appVersion v2.13.4)
configs:
  cm:
    resource.customizations.useOpenLibs.autoscaling_HorizontalPodAutoscaler: "true"
    resource.customizations.useOpenLibs.keda.sh_ScaledObject: "true"
    resource.customizations: |
      autoscaling/HorizontalPodAutoscaler:
        health.lua: |
          hs = {}
          hs.status = "Healthy"
          hs.message = "Force ignoring HPA health check to prevent abnormal false alerts."
          return hs
      
      keda.sh/ScaledObject:
        health.lua: |
          hs = {}
          hs.status = "Healthy"
          hs.message = "Force ignoring KEDA ScaledObject health check to prevent abnormal false alerts."
          return hs
```

I removed health keyword from configuration path. Used nested `|` structure instead of inline configuration and force HPA status to "Healthy" to eliminate false positives.

To verify the custom health check is working:

1. Open ArgoCD UI and navigate to your application
2. Click on the HPA resource
3. Check the HEALTH field displays your custom message: "Force ignoring HPA health check to prevent abnormal false alerts."
4. If you see this message, the configuration is applied correctly

### Notification Delay

As a additional safeguard, I added a 2-minute delay before sending degraded alerts. This is mentioned in https://github.com/argoproj-labs/argocd-notifications/issues/341#issuecomment-927169471. This condition helps reduce false alerts by waiting a bit to see if the issue fixes itself before sending notifications.

argocd-notifications-cm configMap:

```yaml
data:
  trigger.on-health-degraded: |
    - description: Application status is degraded and unhealthy
      send:
      - app-health-issue
      when: app.status.health.status in ['Degraded'] and app.spec.project != 'infra' and time.Now().Sub(time.Parse(app.status.operationState.startedAt)).Minutes() >= 2
```

## References

- [ArgoCD docs: Resource Health](https://argo-cd.readthedocs.io/en/release-2.13/operator-manual/health/#custom-health-checks)
- [HorizontalPodAutoscaler causes degraded status #6287](https://github.com/argoproj/argo-cd/issues/6287)
- [Addition of new trigger: on-health-healthy #341](https://github.com/argoproj-labs/argocd-notifications/issues/341#issuecomment-927169471)
