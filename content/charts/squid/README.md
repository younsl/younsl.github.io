# squid

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 6.10](https://img.shields.io/badge/AppVersion-6.10-informational?style=flat-square)

A Helm chart for Squid caching proxy

**Homepage:** <https://github.com/younsl/blog>

## Requirements

Kubernetes: `>=1.21.0-0`

## Installation

### Add Helm repository

```console
helm repo add younsl https://younsl.github.io/
helm repo update
```

### Install the chart

Install the chart with the release name `squid`:

```console
helm install squid younsl/squid
```

Install with custom values:

```console
helm install squid younsl/squid -f values.yaml
```

Install a specific version:

```console
helm install squid younsl/squid --version 0.3.0
```

### Install from local chart

Download squid chart and install from local directory:

```console
helm pull younsl/squid --untar --version 0.3.0
helm install squid ./squid
```

The `--untar` option downloads and unpacks the chart files into a directory for easy viewing and editing.

## Upgrade

```console
helm upgrade squid younsl/squid
```

## Uninstall

```console
helm uninstall squid
```

## Configuration

The following table lists the configurable parameters and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` |  |
| fullnameOverride | string | `""` |  |
| replicaCount | int | `2` |  |
| revisionHistoryLimit | int | `10` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| image.repository | string | `"ubuntu/squid"` |  |
| image.tag | string | `"6.10-24.10_beta"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| imagePullSecrets | list | `[]` |  |
| commonLabels | object | `{}` |  |
| commonAnnotations.description | string | `"Squid is a HTTP/HTTPS proxy server supporting caching and domain whitelist access control."` |  |
| annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.automountServiceAccountToken | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `13` |  |
| terminationGracePeriodSeconds | int | `60` |  |
| squidShutdownTimeout | int | `30` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `13` |  |
| securityContext.runAsGroup | int | `13` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| dnsPolicy | string | `"ClusterFirst"` |  |
| dnsConfig | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| service.port | int | `3128` |  |
| service.targetPort | int | `3128` |  |
| service.nodePort | string | `""` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.trafficDistribution | string | `""` |  |
| service.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.className | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.hosts[0].host | string | `"squid.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity | object | `{}` |  |
| topologySpreadConstraints | list | `[]` |  |
| config.allowedNetworks.extra | list | `[]` |  |
| config."squid.conf" | string | Default squid.conf with basic ACLs and security settings. See [values.yaml](https://github.com/younsl/younsl.github.io/blob/main/content/charts/squid/values.yaml) for full configuration. | Squid configuration file content This configuration will be mounted to /etc/squid/squid.conf inside the squid container See: https://www.squid-cache.org/Versions/v6/cfgman/ |
| config.annotations | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.minReplicas | int | `2` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `70` |  |
| autoscaling.annotations | object | `{}` |  |
| autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `600` |  |
| autoscaling.behavior.scaleDown.policies[0].type | string | `"Percent"` |  |
| autoscaling.behavior.scaleDown.policies[0].value | int | `50` |  |
| autoscaling.behavior.scaleDown.policies[0].periodSeconds | int | `60` |  |
| autoscaling.behavior.scaleDown.policies[1].type | string | `"Pods"` |  |
| autoscaling.behavior.scaleDown.policies[1].value | int | `2` |  |
| autoscaling.behavior.scaleDown.policies[1].periodSeconds | int | `60` |  |
| autoscaling.behavior.scaleDown.selectPolicy | string | `"Min"` |  |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.initialDelaySeconds | int | `20` |  |
| livenessProbe.periodSeconds | int | `5` |  |
| livenessProbe.timeoutSeconds | int | `1` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `1` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| persistence.enabled | bool | `false` |  |
| persistence.storageClassName | string | `""` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.size | string | `"1Gi"` |  |
| persistence.volumeName | string | `""` |  |
| persistence.annotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `true` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podDisruptionBudget.annotations | object | `{}` |  |
| squidExporter.enabled | bool | `true` |  |
| squidExporter.image.repository | string | `"boynux/squid-exporter"` |  |
| squidExporter.image.tag | string | `"v1.13.0"` |  |
| squidExporter.image.pullPolicy | string | `"IfNotPresent"` |  |
| squidExporter.port | int | `9301` |  |
| squidExporter.metricsPath | string | `"/metrics"` |  |
| squidExporter.resources.limits.memory | string | `"64Mi"` |  |
| squidExporter.resources.requests.cpu | string | `"10m"` |  |
| squidExporter.resources.requests.memory | string | `"32Mi"` |  |
| squidExporter.squidHostname | string | `"localhost"` |  |
| squidExporter.squidPort | string | `nil` |  |
| squidExporter.squidLogin | string | `""` |  |
| squidExporter.squidPassword | string | `""` |  |
| squidExporter.extractServiceTimes | bool | `true` |  |
| squidExporter.customLabels | object | `{}` |  |
| dashboard.enabled | bool | `false` |  |
| dashboard.grafanaNamespace | string | `""` |  |
| dashboard.annotations | object | `{}` |  |

## Source Code

* <http://www.squid-cache.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| younsl | <cysl@kakao.com> | <https://github.com/younsl> |

## License

This chart is licensed under the Apache License 2.0. See [LICENSE](https://github.com/younsl/younsl.github.io/blob/main/LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a [Pull Request](https://github.com/younsl/younsl.github.io/pulls).

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
