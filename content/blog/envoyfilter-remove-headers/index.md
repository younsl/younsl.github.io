---
title: "envoyfilter remove headers"
date: 2025-12-24T10:00:00+09:00
lastmod: 2025-12-24T10:00:00+09:00
description: "How to remove security-sensitive response headers using Istio EnvoyFilter"
keywords: []
tags: ["kubernetes", "istio"]
---

## Overview

This guide is based on Istio 1.25.0.

When exposing services through Istio Gateway, Envoy proxy adds certain response headers by default. These headers can expose internal infrastructure information, making it recommended to remove them for security purposes.

This guide explains how to remove `x-envoy-upstream-service-time` and `server` headers using EnvoyFilter.

## Background

### EnvoyFilter

EnvoyFilter is an Istio custom resource that allows you to customize the Envoy proxy configuration. It provides a way to modify the behavior of Envoy proxies deployed as sidecars or gateways without changing the Istio control plane configuration.

With EnvoyFilter, you can:

- Add, remove, or modify HTTP headers
- Configure rate limiting
- Add custom Lua filters
- Modify routing behavior such as timeouts, retries, and circuit breakers

### Headers to Remove

**x-envoy-upstream-service-time**

This header contains the time in milliseconds spent by the upstream host processing the request. It exposes internal service performance information to external clients.

**server**

This header typically shows `istio-envoy`, revealing the proxy software being used. Attackers can use this information to target known vulnerabilities in specific software versions.

### Example of Exposed Headers

Before applying EnvoyFilter:

```bash
$ curl -I https://example.com/api/health
HTTP/2 200
content-type: application/json
x-envoy-upstream-service-time: 5
server: istio-envoy
date: Tue, 24 Dec 2025 01:00:00 GMT
```

The `x-envoy-upstream-service-time` and `server` headers expose that Istio and Envoy are being used.

## Configuration

### EnvoyFilter Resource

Use EnvoyFilter to remove specific response headers from Gateway context.

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: istio-gateway-remove-headers
  namespace: istio-system
  annotations:
    description: Removes x-envoy-upstream-service-time and server headers from gateway responses for security
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: GATEWAY
    patch:
      operation: MERGE
      value:
        response_headers_to_remove:
        - x-envoy-upstream-service-time
        - server
```

EnvoyFilter is placed in `istio-system` where Istio Gateway runs. This is the recommended pattern to apply the filter to all Gateways cluster-wide.

### Configuration Details

- `applyTo: VIRTUAL_HOST`: Apply the patch at the Virtual Host level
- `match.context: GATEWAY`: Apply only to Istio Gateway, not sidecars
- `patch.operation: MERGE`: Merge with existing configuration
- `response_headers_to_remove`: List of response headers to remove

### Managing with Helm Chart

You can use the [istio-envoyfilters](https://github.com/younsl/charts/tree/main/charts/istio-envoyfilters) Helm chart to manage EnvoyFilter resources.

Example `values.yaml` for istio-envoyfilters chart:

```yaml
# values.yaml
envoyFilters:
  # Remove unnecessary headers from gateway responses
  istio-gateway-remove-headers:
    enabled: true
    annotations:
      description: "Removes x-envoy-upstream-service-time and server headers from gateway responses for security"
    configPatches:
      - applyTo: VIRTUAL_HOST
        match:
          context: GATEWAY
        patch:
          operation: MERGE
          value:
            response_headers_to_remove:
              - x-envoy-upstream-service-time
              - server
```

## Deployment

### Apply EnvoyFilter

```bash
kubectl apply -f envoyfilter.yaml
```

### Verify Creation

Check if the EnvoyFilter was created successfully:

```bash
kubectl get envoyfilter -n istio-system
```

```bash
NAME                           AGE
istio-gateway-remove-headers   10s
```

### Verify Header Removal

Use curl to verify that headers have been removed from responses:

```bash
$ curl -I https://example.com/api/health
HTTP/2 200
content-type: application/json
date: Tue, 24 Dec 2025 01:00:00 GMT
```

The `x-envoy-upstream-service-time` and `server` headers are no longer present in the response.

## Additional Headers to Remove

For enhanced security, consider removing these additional headers:

- `x-envoy-decorator-operation`: Envoy decorator information
- `x-envoy-attempt-count`: Number of retry attempts
- `x-powered-by`: Server framework information

```yaml
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: GATEWAY
    patch:
      operation: MERGE
      value:
        response_headers_to_remove:
        - x-envoy-upstream-service-time
        - server
        - x-envoy-decorator-operation
        - x-envoy-attempt-count
        - x-powered-by
```

## References

- [Istio EnvoyFilter Reference](https://istio.io/latest/docs/reference/config/networking/envoy-filter/)
- [Envoy HTTP Connection Manager](https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/filter/network/http_connection_manager/v2/http_connection_manager.proto)
