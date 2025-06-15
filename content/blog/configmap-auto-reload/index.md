---
title: "configmap auto reload"
date: 2024-08-09T17:06:40+09:00
lastmod: 2024-08-09T17:55:40+09:00
slug: ""
description: "쿠버네티스 configMap이 변경되면 파드가 자동으로 재시작되도록 하는 방법"
keywords: []
tags: ["devops", "kubernetes", "helm"]
---

## 개요

헬름 차트에서 ConfigMap 리소스에 들어있는 내용<sup>data</sup>이 변경되었을 때 Kubernetes 파드를 자동으로 재시작하는 방법을 소개합니다.

&nbsp;

## 배경

운영하고 있는 `kafka-connect-ui` 차트에서 configMap의 data를 변경해도 해당 `configMap`을 마운트하고 있는 파드가 재시작되지 않는 이슈가 있었습니다.

이를 항상 `kubectl rollout restart` 등으로 매번 재시작해주는 게 번거로워서 개선이 필요했습니다.

&nbsp;

## 개선방법

### checksum 기반 자동 재시작

configMap에 들어있는 데이터의 내용이 변경되면 재시작할 수 있게, `checksum/config` annotation을 파드에 부여합니다.

&nbsp;

## 설정하기

개선하려고 하는 `kafka-connect-ui` 헬름 차트의 디렉토리 구조는 다음과 같습니다.

```bash
$ tree -L 2 .
.
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── Chart.yaml
└── values.yaml
```

&nbsp;

`_helpers.tpl` 파일에 다음과 같이 configMap의 데이터 내용을 읽어 checksum 값으로 계산하는 템플릿을 추가합니다.

```go
{{/*
Generate a hash of the configmap to trigger pod restarts
if the configMap data is changed.
*/}}
{{- define "kafka-connect-ui.configmap.checksum" }}
{{- if .Values.config.data }}
checksum/config: {{ .Values.config.data | toYaml | sha256sum }}
{{- else }}
checksum/config: "no-config-data"
{{- end }}
{{- end }}
```

`Values.config.data`에 대한 sha256 값을 계산하여 이를 Kubernetes의 annotations에 추가하는 방식으로 파드의 재시작을 관리할 수 있습니다. 이렇게 하면 `configMap` 리소스의 `data` 내용이 변경되었을 때만 파드가 재시작되며, `configMap` 리소스의 `label` 또는 `annotation` 변경 등 불필요한 상황에서는 파드 재시작이 발생하지 않습니다.

&nbsp;

헬름차트에 `config.data` 값이 `null`이거나 선언되지 않은 경우는 `checksum/config: no-config-data` annotation이 파드에 붙게 됩니다.

```yaml
# kafka-connect-ui/values.yaml
config:
  data: null
```

&nbsp;

`_helpers.tpl`의 kafka-connect-ui.configmap.checksum 템플릿에서 계산된 checksum 값을 pod annotation에 넣도록 `deployment.yaml`을 변경합니다.

```yaml
# kafka-connect-ui/templates/deployment.yaml
spec:
  template:
    metadata:
      annotations:
        {{- include "kafka-connect-ui.configmap.checksum" . | nindent 8 }}
```

&nbsp;

실제 헬름 차트로 배포된 파드에는 `checksum/config` 어노테이션이 추가됩니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    checksum/config: 7d26f9f86ba6c4413b41ddfe08e125d80b50fb6ed23aaef9be557af2dd972a32
    kubectl.kubernetes.io/restartedAt: "2024-08-07T16:52:13+09:00"
```

헬름차트로 배포된 `configMap`의 `data`가 업데이트될 때마다 `checksum/config` annotation 값도 같이 업데이트 됩니다. 결과적으로 파드가 재시작되며 새 configMap의 데이터를 자동으로 들고오게 됩니다.

&nbsp;

## 다른 대안

### reloader

`checksum` 기반 외에 다른 대안으로는 Stakater의 [reloader](https://github.com/stakater/Reloader)가 있습니다.

reloader는 ConfigMap 또는 Secret이 변경될 때 이를 감지하고 관련 파드를 자동으로 재시작해 주는 Kubernetes 컨트롤러입니다.

제가 stakater의 reloader를 사용하지 않은 가장 큰 이유는 3가지입니다.

- 관리 포인트인 서드파티 관리 컨트롤러를 하나 더 늘리고 싶지 않았습니다. 이미 충분히 인 클러스터에 배포된 관리 포인트들은 많습니다.
- 리소스 절약<sup>FinOps</sup> 측면에서도 Reloader는 파드가 추가로 배포되고 클러스터 전체 중 일부 CPU, Memory 자원 소비가 발생합니다.
- 튜닝의 끝은 순정이기 때문에 쿠버네티스와 헬름 차트의 네이티브한 기능만 가지고 해결하고 싶었습니다.

&nbsp;

## 마치며

개인적으로 Kubernetes 네이티브하게 파드의 `spec` 설정이나 configMap의 설정을 통해 지원해주면 편할 것 같습니다.

&nbsp;

## 관련자료

**Blog**  
[Leveraging Helm for ConfigMap Updates](https://www.baeldung.com/ops/kubernetes-restart-configmap-updates#3-leveraging-helm-for-configmap-updates)

**Reloader**  
[skater/reloader repository](https://github.com/stakater/Reloader)  
[Reloader docs](https://docs.stakater.com/reloader/)
