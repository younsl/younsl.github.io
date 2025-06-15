---
title: "Argo Workflows의 executor plugin 설정"
date: 2022-09-04T14:20:15+09:00
lastmod: 2022-11-05T22:01:15+09:00
slug: ""
description: "Argo Workflows의 executor plugin 설정"
keywords: []
tags: ["devops", "kubernetes"]
---

## 개요

Argo Workflows의 Executor Plugin 기능을 활성화하는 방법입니다.

Workflow Executor는 Argo가 포드 로그 모니터링, 아티팩트 수집, 컨테이너 수명 주기 관리 등과 같은 특정 작업을 수행할 수 있도록 하는 특정 인터페이스를 준수하는 프로세스입니다.

&nbsp;

## 배경지식

### Plugin

플러그인을 사용하면 Argo Workflows를 확장하여 새로운 기능을 추가할 수 있습니다.

### Executor plugin

로컬 환경에 쿠버네티스 클러스터를 설정해서 argo workflow의 executor plugin 개발하고 있는 상황일 때, Executor Plugin 기능을 먼저 활성화 해줘야 합니다.

플러그인 기능은 기본값으로 비활성화되어 있습니다. 기능을 활성화하려면 Workflow 컨트롤러에 `extraEnv` 설정이 필요합니다.

&nbsp;

## 환경

EKS 클러스터에 Argo Wokrflows를 헬름 차트로 배포한 상태입니다.

&nbsp;

## 설정방법

### 차트 변경

헬름 차트로 Argo Workflows를 설치한 경우, 아래와 같이 헬름차트 `values.yaml` 파일에 `controller.extraEnv`를 추가합니다.

```diff
workflow:
  serviceAccount:
    create: true

controller:
  replicas: 2
  metricsConfig:
    enabled: true

  workflowNamespaces:
    - argo-job

  extraArgs:
    - --namespaced
    - --managed-namespace
    - argo-job

+ extraEnv:
+   - name: ARGO_EXECUTOR_PLUGINS
+     value: "true"
+
  resources:
    requests:
      cpu: 500m
      memory: 1024Mi
    limits:
      cpu: 2000m
      memory: 4096Mi

  ...
```

&nbsp;

### 헬름 업그레이드

설정 변경한 차트를 사용해서 argo-workflows 헬름을 업그레이드합니다.

```bash
$ helm upgrade argo-workflows argo/argo-workflows \
    -f values.yaml \
    -n <YOUR-ARGO-WORKFLOWS-NAMESPACE> \
    --wait
```

&nbsp;

### 설정 확인

Helm 업그레이드 이후 `workflow-controller` 파드의 컨테이너에 `ARGO_EXECUTOR_PLUGINS` 환경변수가 추가되었는지 확인합니다.

&nbsp;

`helm upgrade` 후 `workflow-controller` deployment에 정상적으로 환경변수가 추가된 결과는 다음과 같습니다.

```diff
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workflow-controller
spec:
  template:
    spec:
      containers:
        - name: workflow-controller
          env:
+           - name: ARGO_EXECUTOR_PLUGINS
+             value: "true"
          ...
```

&nbsp;

## 참고자료

[Argo Workflows | Plugins](https://argoproj.github.io/argo-workflows/plugins/)  
[Argo Workflows | Executor plugins](https://argoproj.github.io/argo-workflows/executor_plugins/#configuration)
