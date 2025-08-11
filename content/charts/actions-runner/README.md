# actions-runner

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square)

A Helm chart for Kubernetes to deploy GitHub Actions runners include horizontalRunnerAutoscaler and serviceAccount

> **:exclamation: This Helm Chart is deprecated!**

## Deprecation Notice

The actions-runner chart is deprecated. Please use gha-runner-scale-set and gha-runner-scale-set-controller instead: https://github.com/actions/actions-runner-controller

ARC provides better integration with GitHub Actions and more features for managing self-hosted runners on Kubernetes.

## Installation

### Add Helm repository

```console
helm repo add younsl https://younsl.github.io/
helm repo update
```

### Install the chart

Install the chart with the release name `actions-runner`:

```console
helm install actions-runner younsl/actions-runner
```

Install with custom values:

```console
helm install actions-runner younsl/actions-runner -f values.yaml
```

Install a specific version:

```console
helm install actions-runner younsl/actions-runner --version 0.1.4
```

### Install from local chart

Download actions-runner chart and install from local directory:

```console
helm pull younsl/actions-runner --untar --version 0.1.4
helm install actions-runner ./actions-runner
```

The `--untar` option downloads and unpacks the chart files into a directory for easy viewing and editing.

## Upgrade

```console
helm upgrade actions-runner younsl/actions-runner
```

## Uninstall

```console
helm uninstall actions-runner
```

## Configuration

The following table lists the configurable parameters and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `nil` |  |
| fullnameOverride | string | `nil` |  |
| runnerDeployments[0].runnerName | string | `"doge-basic-runner"` |  |
| runnerDeployments[0].enterprise | string | `"doge-company"` |  |
| runnerDeployments[0].group | string | `""` |  |
| runnerDeployments[0].podLabels | object | `{}` |  |
| runnerDeployments[0].podAnnotations | object | `{}` |  |
| runnerDeployments[0].labels[0] | string | `"DOGE-EKS-CLUSTER"` |  |
| runnerDeployments[0].labels[1] | string | `"m6i.xlarge"` |  |
| runnerDeployments[0].labels[2] | string | `"ubuntu-22.04"` |  |
| runnerDeployments[0].labels[3] | string | `"v2.311.0"` |  |
| runnerDeployments[0].labels[4] | string | `"build"` |  |
| runnerDeployments[0].dnsConfig | object | `{}` |  |
| runnerDeployments[0].securityContext.fsGroup | int | `1001` |  |
| runnerDeployments[0].dockerVolumeMounts[0].mountPath | string | `"/tmp"` |  |
| runnerDeployments[0].dockerVolumeMounts[0].name | string | `"tmp"` |  |
| runnerDeployments[0].volumeMounts[0].mountPath | string | `"/tmp"` |  |
| runnerDeployments[0].volumeMounts[0].name | string | `"tmp"` |  |
| runnerDeployments[0].volumes[0].name | string | `"tmp"` |  |
| runnerDeployments[0].volumes[0].emptyDir | object | `{}` |  |
| runnerDeployments[0].resources.limits.cpu | string | `"1.5"` |  |
| runnerDeployments[0].resources.limits.memory | string | `"6Gi"` |  |
| runnerDeployments[0].resources.requests.cpu | string | `"0.5"` |  |
| runnerDeployments[0].resources.requests.memory | string | `"1Gi"` |  |
| runnerDeployments[0].nodeSelector."node.kubernetes.io/name" | string | `"basic"` |  |
| runnerDeployments[0].autoscaling.enabled | bool | `true` |  |
| runnerDeployments[0].autoscaling.scaleDownDelaySecondsAfterScaleOut | int | `300` |  |
| runnerDeployments[0].autoscaling.minReplicas | int | `2` |  |
| runnerDeployments[0].autoscaling.maxReplicas | int | `16` |  |
| runnerDeployments[0].autoscaling.scheduledOverrides[0].startTime | string | `"2023-07-15T00:00:00+09:00"` |  |
| runnerDeployments[0].autoscaling.scheduledOverrides[0].endTime | string | `"2023-07-17T00:00:00+09:00"` |  |
| runnerDeployments[0].autoscaling.scheduledOverrides[0].recurrenceRule.frequency | string | `"Weekly"` |  |
| runnerDeployments[0].autoscaling.scheduledOverrides[0].minReplicas | int | `1` |  |
| runnerDeployments[0].autoscaling.metrics[0].type | string | `"PercentageRunnersBusy"` |  |
| runnerDeployments[0].autoscaling.metrics[0].scaleUpThreshold | string | `"0.75"` |  |
| runnerDeployments[0].autoscaling.metrics[0].scaleDownThreshold | string | `"0.25"` |  |
| runnerDeployments[0].autoscaling.metrics[0].scaleUpFactor | string | `"2"` |  |
| runnerDeployments[0].autoscaling.metrics[0].scaleDownFactor | string | `"0.5"` |  |
| runnerDeployments[0].automountServiceAccountToken | bool | `true` |  |
| runnerDeployments[0].serviceAccount.create | bool | `true` |  |
| runnerDeployments[0].serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `"arn:aws:iam::111122223333:role/doge-eks-cluster-actions-build-runner-s3-access-irsa-role"` |  |
| runnerDeployments[0].topologySpreadConstraints | object | `{}` |  |

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
