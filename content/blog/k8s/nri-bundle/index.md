---
title: "nri-bundle"
date: 2024-02-16T16:25:40+09:00
lastmod: 2024-02-16T16:25:45+09:00
slug: ""
description: "Node Termination Handler를 사용해서 EKS 스팟 워커노드 안전하게 운영하는 방법을 소개합니다. NTH의 원리, 개념, 설치방법 등을 다룹니다."
keywords: []
tags: ["devops", "kubernetes", "spot"]
---

{{< toc >}}

&nbsp;

## 개요

Newrelic 통합 차트를 사용해서 쿠버네티스 클러스터에 모니터링 수집 플랫폼 구축하는 방법을 소개합니다.

이 가이드 문서에서 언급되는 Newrelic 헬름 차트는 통합 차트인 nri-bundle을 사용합니다.

&nbsp;

## 배경지식

### nri-bundle

여러 개의 뉴렐릭 모니터링 구성요소를 쉽게 배포하기 위해 New Relic Kubernetes 솔루션의 개별 차트를 그룹화한 통합 차트입니다.

nri-bundle 차트에는 아래와 같이 [Sub chart](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle#bundled-charts)들이 포함되어 있습니다.

```bash
# -- main chart
nri-bundle                            5.0.18   https://newrelic.github.io/nri-bundle
└── charts/
    |   # -- sub charts
    ├── newrelic-infrastructure       3.19.0   https://newrelic.github.io/nri-kubernetes
    ├── nri-prometheus                2.1.16   https://newrelic.github.io/nri-prometheus
    ├── newrelic-prometheus-agent     1.2.1    https://newrelic.github.io/newrelic-prometheus-configurator
    ├── nri-metadata-injection        4.3.1    https://newrelic.github.io/k8s-metadata-injection
    ├── newrelic-k8s-metrics-adapter  1.2.0    https://newrelic.github.io/newrelic-k8s-metrics-adapter
    ├── kube-state-metrics            4.23.0   https://prometheus-community.github.io/helm-charts
    ├── nri-kube-events               3.1.0    https://newrelic.github.io/nri-kube-events
    ├── newrelic-logging              1.14.2   https://newrelic.github.io/helm-charts
    ├── newrelic-pixie                2.1.1    https://newrelic.github.io/helm-charts
    ├── pixie-operator-chart          0.1.1    https://pixie-operator-charts.storage.googleapis.com
    └── newrelic-infra-operator       2.2.1    https://newrelic.github.io/newrelic-infra-operator
```

&nbsp;

#### nri-bundle로 배포시 장점

nri-bundle 통합 차트를 사용하는 것에는 여러 가지 장점이 있습니다.

- **관리의 간소화**: 각 구성 요소를 개별적으로 관리하는 대신에, 'nri-bundle'을 사용하면 여러 개의 New Relic 통합 및 관련 도구를 한 번에 배포하고 관리할 수 있습니다.
- **일관성**: 번들 내의 모든 구성 요소는 함께 잘 작동하는 것이 검증되어 있습니다. 이는 일관된 경험을 제공합니다.
- **상호 운용성**: 번들 내의 구성 요소들은 서로 매끄럽게 통합되도록 설계되어 있습니다. 이는 호환성 문제를 줄이고 업무 흐름을 간소화합니다.
- **배포의 용이성**: 전체 번들을 배포하는 것은 한 번의 명령어 또는 구성 단계만으로 가능합니다. 이는 각 구성 요소를 별도로 배포하는 것과 비교하여 시간과 노력을 절약해줍니다.
- **최적화된 성능**: 번들 내의 구성 요소들은 함께 효율적으로 작동하도록 최적화되어 있습니다. 이는 서로 다른 솔루션을 사용하는 것보다 더 나은 성능을 제공할 수 있습니다.
- **중앙 집중식 지원**: 단일 번들을 사용하면 New Relic 또는 커뮤니티로부터 중앙 집중식 지원을 받을 수 있어요. 이는 문제를 해결하고 해결하는 데 더욱 편리합니다.

결론적으로, nri-bundle 헬름 차트를 사용해서 뉴렐릭 모니터링 인프라를 구성할 경우, Kubernetes 환경에 대한 더 일관되고 효율적인 모니터링 솔루션을 제공함으로써 New Relic 통합 및 관련 도구의 배포 및 관리가 단순화됩니다.

&nbsp;

## 설치

헬름 차트 레포지터리를 로컬에 다운로드 받습니다.

```bash
git clone https://github.com/newrelic/helm-charts.git
cd helm-charts/charts/nri-bundle
```

&nbsp;

하위 차트들을 로컬에 다운로드 받습니다.

```bash
helm dependency update
```

&nbsp;

현재 디렉토리에 구성된 하위 차트 목록을 확인합니다.

```bash
$ helm dependency list
NAME                          VERSION  REPOSITORY                                                   STATUS
newrelic-infrastructure       3.19.0   https://newrelic.github.io/nri-kubernetes                    ok
nri-prometheus                2.1.16   https://newrelic.github.io/nri-prometheus                    ok
newrelic-prometheus-agent     1.2.1    https://newrelic.github.io/newrelic-prometheus-configurator  ok
nri-metadata-injection        4.3.1    https://newrelic.github.io/k8s-metadata-injection            ok
newrelic-k8s-metrics-adapter  1.2.0    https://newrelic.github.io/newrelic-k8s-metrics-adapter      ok
kube-state-metrics            4.23.0   https://prometheus-community.github.io/helm-charts           ok
nri-kube-events               3.1.0    https://newrelic.github.io/nri-kube-events                   ok
newrelic-logging              1.14.2   https://newrelic.github.io/helm-charts                       ok
newrelic-pixie                2.1.1    https://newrelic.github.io/helm-charts                       ok
pixie-operator-chart          0.1.1    https://pixie-operator-charts.storage.googleapis.com         ok
newrelic-infra-operator       2.2.1    https://newrelic.github.io/newrelic-infra-operator           ok
```

&nbsp;

`nri-bundle` 메인 차트를 클러스터의 `newrelic` 네임스페이스에 설치합니다.

```bash
helm upgrade \
  --install \
  --create-namespace \
  --namespace newrelic \
  nri-bundle . \
  --values values.yaml \
  --wait
```

&nbsp;

## 설정 가이드

### 비용 최적화 기법

#### Low data mode 켜기

**연관된 차트 이름**: `nri-bundle` (메인 차트)

`lowDataMode` 토글은 Newrelic으로 전송되는 데이터를 줄이는 가장 간단한 방법입니다. nri-bundle 차트에서 `global.lowDataMode` 값을 `true`로 설정하면 기본 스크레이핑 간격이 `15s`(기본값)에서 `30s`로 변경됩니다.

```yaml
# nri-bundle/values.yaml
# nri-bundle chart version v5.0.18
global:
  # -- (bool) Reduces number of metrics sent in order to reduce costs
  # @default -- false
  lowDataMode: true
```

lowDataMode가 활성화되면 기본 스크레이핑 간격이 `15s`에서 `30s`로 변경됩니다. 그리고 아래 4개 차트에 미리 세팅된 비용 최적화 세팅들이 자동 적용됩니다.

- Newrelic Infrastructure
- Prometheus Agent Integration
- Newrelic Logging
- Newrelic Pixie Integration

&nbsp;

어떤 이유로 인해 초 수를 미세 조정해야 하는 경우 `common.config.interval` 설정에 직접 선언해서 적용할 수 있습니다.

```yaml
# nri-bundle/values.yaml
# nri-bundle chart version v5.0.18
...
newrelic-infrastructure:
  common:
    config:
      interval: 15s
...
```

&nbsp;

#### 메트릭 샘플링 주기 변경

**연관된 차트 이름**: `newrelic-infrastructure` (하위 차트)

메트릭 샘플링 주기를 좀 더 길게 변경합니다.

```yaml
# nri-bundle/values.yaml
# nri-bundle chart version v5.0.18
...
newrelic-infrasturcture:
  common:
    agentConfig:
      disable_all_plugin: true
      metrics_network_sample_rate: -1
      metrics_process_sample_rate: 300
      metrics_storage_sample_rate: 300
      metrics_system_sample_rate: 300
      metrics_nfs_sample_rate: 300
...
```

**관련문서**  
[newrelic-infrasturcture 에이전트 설정 (disable_all_plugin)](https://docs.newrelic.com/kr/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings/#%ED%94%8C%EB%9F%AC%EA%B7%B8%EC%9D%B8-%EB%B3%80%EC%88%98)  
[newrelic-infrasturcture 에이전트 설정 (sample_rate)](https://docs.newrelic.com/kr/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings/#%EC%83%98%ED%94%8C-%EB%B3%80%EC%88%98)

&nbsp;

#### 네임스페이스 필터링

**연관된 차트 이름**: `newrelic-infrastructure` (하위 차트)

지정된 네임스페이스의 메트릭만 수집하도록 필터링합니다.

```yaml
# nri-bundle/values.yaml
# nri-bundle chart version v5.0.18
...
newrelic-infrastructure:
  common:
    config:
      namespaceSelector:
        - default
        - backoffice
...
```