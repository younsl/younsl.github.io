# actions-runner

Self-hosted actions runner chart include runnerDeployment, horizontalRunnerAutoscaler and serviceAccount.

Tested in EKS v1.29 based AL2 amd64 environment.

> [!WARNING]
> This documentation covers the legacy mode of ARC (resources in the actions.summerwind.net namespace). If you're looking for documentation on the newer autoscaling runner scale sets, it is available in [GitHub Docs](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller). This `actions-runner` helm chart deploys actions-runner pods controlled by runnerDeployments resource. Since it is a legacy resource, it is recommended to use runnetSet distributed by [gha-runner-scale-set-controller](https://github.com/actions/actions-runner-controller/tree/master/charts/gha-runner-scale-set-controller).

## Prerequisites

1. Install [helm3](https://helm.sh/) CLI tool
2. [ARC](https://github.com/actions/actions-runner-controller)<sup>actions runner controller</sup> must first be installed in your kubernetes cluster.

### Chart dependency

actions-runner chart relies on [custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) included in the [actions-runner-controller](https://github.com/actions/actions-runner-controller/tree/master/charts/actions-runner-controller) chart.  
The following custom resources must exist in your Kubernetes cluster before install actions-runner chart.

```bash
kubectl api-resources \
  --api-group actions.summerwind.dev \
  -o wide
```

```bash
NAME                          SHORTNAMES   APIVERSION                        NAMESPACED   KIND                         VERBS                                                        CATEGORIES
horizontalrunnerautoscalers   hra          actions.summerwind.dev/v1alpha1   true         HorizontalRunnerAutoscaler   delete,deletecollection,get,list,patch,create,update,watch
runnerdeployments             rdeploy      actions.summerwind.dev/v1alpha1   true         RunnerDeployment             delete,deletecollection,get,list,patch,create,update,watch
runnerreplicasets             rrs          actions.summerwind.dev/v1alpha1   true         RunnerReplicaSet             delete,deletecollection,get,list,patch,create,update,watch
runners                                    actions.summerwind.dev/v1alpha1   true         Runner                       delete,deletecollection,get,list,patch,create,update,watch
runnersets                                 actions.summerwind.dev/v1alpha1   true         RunnerSet                    delete,deletecollection,get,list,patch,create,update,watch
```

## Usage

Installation method only supports helm chart.

### Installation

We strongly recommend using different namespaces for actions-runner-controller and actions-runner resources.

```bash
helm upgrade \
  --install \
  --create-namespace \
  --namespace actions-runner \
  actions-runner . \
  --values values_example.yaml \
  --wait
```

```bash
helm list -n actions-runner
```

### Delete

```bash
helm uninstall -n actions-runner actions-runner
```

## Advanced configuration

### scheduledOverrides

Runner pods can be automatically disabled during Weekly and Daily by the `scheduledOverrides` spec of HorizontalRunnerAutoscaler.

If you need to disable this configuration, comment out (or delete) `autoscaling.scheduledOverrides` spec in the helm chart:

```yaml
    autoscaling:
      enabled: true
      scaleDownDelaySecondsAfterScaleOut: 300
      minReplicas: 1
      maxReplicas: 1
      scheduledOverrides: {}
      # minReplicas 값을 토요일 오전 0시(KST)부터 월요일 오전 0시(KST)까지 0로 지정
      # - startTime: "2023-07-15T00:00:00+09:00"
      #   endTime: "2023-07-17T00:00:00+09:00"
      #   recurrenceRule:
      #     frequency: Weekly
      #   minReplicas: 0
      # - startTime: "2024-02-05T00:00:00+09:00"
      #   endTime: "2024-02-05T08:00:00+09:00"
      #   recurrenceRule:
      #     frequency: Daily
      #   minReplicas: 0
```

Then run `helm upgrade` command:

```bash
helm upgrade \
  --install \
  --create-namespace \
  --namespace actions-runner \
  actions-runner . \
  --values values_example.yaml \
  --wait
```
