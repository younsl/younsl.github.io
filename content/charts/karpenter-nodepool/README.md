# karpenter-nodepool

![Version: 1.5.1](https://img.shields.io/badge/Version-1.5.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.5.0](https://img.shields.io/badge/AppVersion-1.5.0-informational?style=flat-square)

A Helm chart for Karpenter Node pool, it will create the NodePool and the Ec2NodeClass.

**Homepage:** <https://younsl.github.io/charts/>

## Installation

### Add Helm repository

```console
helm repo add younsl https://younsl.github.io/
helm repo update
```

### Install the chart

Install the chart with the release name `karpenter-nodepool`:

```console
helm install karpenter-nodepool younsl/karpenter-nodepool
```

Install with custom values:

```console
helm install karpenter-nodepool younsl/karpenter-nodepool -f values.yaml
```

Install a specific version:

```console
helm install karpenter-nodepool younsl/karpenter-nodepool --version 1.5.1
```

### Install from local chart

Download karpenter-nodepool chart and install from local directory:

```console
helm pull younsl/karpenter-nodepool --untar --version 1.5.1
helm install karpenter-nodepool ./karpenter-nodepool
```

The `--untar` option downloads and unpacks the chart files into a directory for easy viewing and editing.

## Upgrade

```console
helm upgrade karpenter-nodepool younsl/karpenter-nodepool
```

## Uninstall

```console
helm uninstall karpenter-nodepool
```

## Configuration

The following table lists the configurable parameters and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` |  |
| globalLabels | object | `{}` |  |
| globalAnnotations | object | `{}` |  |
| nodePool.default.labels | object | `{}` |  |
| nodePool.default.annotations | object | `{}` |  |
| nodePool.default.nodeClassRef | object | `{}` |  |
| nodePool.default.taints | list | `[]` |  |
| nodePool.default.startupTaints | list | `[]` |  |
| nodePool.default.terminationGracePeriod | string | `nil` |  |
| nodePool.default.requirements | list | `[]` |  |
| nodePool.default.expireAfter | string | `"720h"` |  |
| nodePool.default.kubelet | object | `{}` |  |
| nodePool.default.disruption.consolidationPolicy | string | `"WhenUnderutilized"` |  |
| nodePool.default.limits.cpu | int | `1000` |  |
| nodePool.default.limits.memory | string | `"1000Gi"` |  |
| nodePool.default.overprovisioning.enabled | bool | `false` |  |
| nodePool.default.overprovisioning.nodes | int | `1` |  |
| nodePool.default.overprovisioning.resources.requests.cpu | string | `"3500m"` |  |
| nodePool.default.overprovisioning.resources.requests.memory | string | `"7000Mi"` |  |
| nodePool.default.overprovisioning.resources.limits.cpu | string | `"3500m"` |  |
| nodePool.default.overprovisioning.resources.limits.memory | string | `"7000Mi"` |  |
| nodePool.default.overprovisioning.topologySpreadConstraints[0].maxSkew | int | `1` |  |
| nodePool.default.overprovisioning.topologySpreadConstraints[0].topologyKey | string | `"kubernetes.io/hostname"` |  |
| nodePool.default.overprovisioning.topologySpreadConstraints[0].whenUnsatisfiable | string | `"DoNotSchedule"` |  |
| nodePool.default.overprovisioning.topologySpreadConstraints[0].labelSelector.matchLabels."app.kubernetes.io/component" | string | `"overprovisioning"` |  |
| nodePool.default.overprovisioning.tolerations | list | `[]` |  |
| nodePool.default.overprovisioning.podLabels | object | `{}` |  |
| nodePool.default.overprovisioning.podAnnotations.description | string | `"Overprovisioning pod for maintaining spare capacity"` |  |
| ec2NodeClass.default.amiFamily | string | `"AL2"` |  |
| ec2NodeClass.default.subnetSelectorTerms | list | `[]` |  |
| ec2NodeClass.default.securityGroupSelectorTerms | list | `[]` |  |
| ec2NodeClass.default.role | string | `""` |  |
| ec2NodeClass.default.instanceProfile | string | `""` |  |
| ec2NodeClass.default.amiSelectorTerms | list | `[]` |  |
| ec2NodeClass.default.userData | string | `""` |  |
| ec2NodeClass.default.capacityReservationSelectorTerms | list | `[]` |  |
| ec2NodeClass.default.tags | object | `{}` |  |
| ec2NodeClass.default.metadataOptions | object | `{}` |  |
| ec2NodeClass.default.blockDeviceMappings | list | `[]` |  |
| ec2NodeClass.default.instanceStorePolicy | string | `nil` |  |
| ec2NodeClass.default.detailedMonitoring | bool | `false` |  |
| ec2NodeClass.default.associatePublicIPAddress | bool | `false` |  |

## Source Code

* <https://github.com/younsl/blog>

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
