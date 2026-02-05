---
title: "gpu operator glibc"
date: 2025-08-12T23:40:40+09:00
lastmod: 2028-08-12T23:40:45+09:00
description: ""
keywords: []
tags: ["devops", "kubernetes", "gpu-operator"]
---

## 개요

Amazon Linux 2 GPU AMI에서 GPU Operator 설치 시 발생하는 glibc 버전 호환성과 중복 symlink 문제 해결 방법을 정리합니다. 주요 이슈는 nvidia-container-toolkit의 glibc 2.26 호환성 문제로 인한 파드 실패와 nvidia-operator-validator의 기존 CUDA 설치와의 symlink 충돌로 인한 초기화 실패입니다.

## 환경

- EKS 1.32
- **EKS AMI**: amazon-eks-gpu-node-1.32-v20250715 (linux/amd64)
- [gpu-operator](https://github.com/NVIDIA/gpu-operator) v25.3.2 (official helm install)

## TLDR

Amazon Linux 2 Nvidia GPU 워커노드에서 GPU Operator 운영 시 두 가지 핵심 설정:

1. **nvidia-container-toolkit**: `v1.14.6-ubi8`로 다운그레이드하여 glibc 2.26 호환성 확보
2. **nvidia-operator-validator**: `CUDA_DRIVER_SKIP_DUPLICATE_LINKS=true` 환경변수 추가로 중복 symlink 생성 건너뛰기

nvidia-container-toolkit daemonset은 컨테이너가 호스트 GPU를 사용할 수 있도록 런타임 브릿지 역할을 하는 핵심 구성 요소입니다. 이 파드가 먼저 정상 실행되어야 validator가 검증을 통과하고, 이후 다른 GPU 관련 파드들이 순차적으로 정상화됩니다.

## 설정 가이드

### nvidia-operator-validator

gpu-operator가 관리하는 nvidia-operator-validator 파드 관련 설정입니다.

nvidia-operator-validator 파드가 g4dn.xlarge 타입의 GPU 노드에 스케줄링된 이후 CrashLoopBackOff 상태에 빠졌습니다.

gpu-operator-validator는 GPU 노드의 "헬스체크"와 "환경 설정"을 담당하는 게이트키퍼 역할을 하며, 설정한 CUDA_DRIVER_SKIP_DUPLICATE_LINKS 환경변수는 기존 CUDA 설치와의 충돌을 방지하여 멱등한 배포를 보장하는 설정입니다

```bash
$ kubectl get pod -n gpu-operator
NAME                                                          READY   STATUS                  RESTARTS      AGE
gpu-feature-discovery-n4mf8                                   2/2     Running                 0             7m49s
gpu-operator-5798b5b564-xbq5h                                 1/1     Running                 0             7d1h
gpu-operator-node-feature-discovery-gc-86f6495b55-fxgnm       1/1     Running                 0             7d1h
gpu-operator-node-feature-discovery-master-694467d5db-6mkmb   1/1     Running                 0             14d
gpu-operator-node-feature-discovery-worker-2jwqt              1/1     Running                 0             7m58s
nvidia-container-toolkit-daemonset-k9c8r                      1/1     Running                 0             7m49s
nvidia-dcgm-exporter-sj7p6                                    1/1     Running                 0             7m49s
nvidia-device-plugin-daemonset-wp5p9                          2/2     Running                 0             7m49s
nvidia-operator-validator-xbf9q                               0/1     Init:CrashLoopBackOff   3 (37s ago)   81s
```

nvidia-operator-validator 파드의 에러로그:

```bash
driver-validation time="2025-08-12T02:21:46Z" level=info msg="Creating link /host-dev-char/243:112 => /dev/nvidia-caps/nvidia-cap112"
driver-validation time="2025-08-12T02:21:46Z" level=warning msg="Could not create symlink: symlink /dev/nvidia-caps/nvidia-cap112 /host-dev-char/243:112: file exists"
# ... omitted for brevity ...
driver-validation time="2025-08-12T02:21:46Z" level=info msg="Creating link /host-dev-char/243:136 => /dev/nvidia-caps/nvidia-cap136"
driver-validation time="2025-08-12T02:21:46Z" level=warning msg="Could not create symlink: symlink /dev/nvidia-caps/nvidia-cap136 /host-dev-char/243:136: file exists"
driver-validation time="2025-08-12T02:21:46Z" level=info msg="Creating link /host-dev-char/243:137 => /dev/nvidia-caps/nvidia-cap137"
driver-validation time="2025-08-12T02:21:46Z" level=warning msg="Could not create symlink: symlink /dev/nvidia-caps/nvidia-cap137 /host-dev-char/243:137: file exists
```

Symlink가 이미 있어, 중복 생성 불가하다는 에러가 반복됩니다.

gpu-operator-validator에 CUDA_DRIVER_SKIP_DUPLICATE_LINKS 환경변수를 추가해서 중복 심링크 생성을 건너뛰도록 설정합니다.

gpu-operator 25.3.2 헬름 차트 설정:

```yaml,hl_lines=16-17
# charts/gpu-operator/values_my.yaml
validator:
  repository: nvcr.io/nvidia/cloud-native
  image: gpu-operator-validator
  # If version is not specified, then default is to use chart.AppVersion
  #version: ""
  imagePullPolicy: IfNotPresent
  imagePullSecrets: []
  env: []
  args: []
  resources: {}
  plugin:
    env:
      - name: WITH_WORKLOAD
        value: "false"
      - name: CUDA_DRIVER_SKIP_DUPLICATE_LINKS
        value: "true"
```

clusterpolicy 리소스 설정:

```yaml,hl_lines=10-11
# clusterpolicy
spec:
  validator:
    image: gpu-operator-validator
    imagePullPolicy: IfNotPresent
    plugin:
      env:
      - name: WITH_WORKLOAD
        value: "false"
      - name: CUDA_DRIVER_SKIP_DUPLICATE_LINKS
        value: "true"
    repository: nvcr.io/nvidia/cloud-native
    version: v25.3.2
```

CUDA_DRIVER_SKIP_DUPLICATE_LINKS 환경변수가 추가된 걸 확인할 수 있습니다.

### nvidia-container-toolkit

gpu-operator가 관리하는 nvidia-container-toolkit 파드 관련 설정입니다.

원인은 Amazon Linux 2 Nvidia GPU AMI에 설치된 glibc 버전과 Nvidia Toolkit 간의 버전 호환성입니다.

기본적으로 gpu-operator 25.3.2 기준으로 nvidia-toolkit이 v1.17.8-ubuntu20.04 이미지를 사용하도록 되어 있습니다. 이 경우, Amazon Linux 2 Nvidia GPU 머신에 설치된 glibc 2.26 버전과 호환성이 맞지 않아, GPU 노드 검증 단계에서 실패합니다.

EKS GPU 워커노드가 사용하는 glibc 버전은 워커노드에 접속 후 ldd 명령어로 확인할 수 있습니다.

```bash
ldd --version
```

amazon-eks-gpu-node-1.32-v20250715 (linux/amd64) 기준으로 glibc 2.26을 사용합니다.

```bash
# In worker node via node-shell pod
$ ldd --version
ldd (GNU libc) 2.26
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
Written by Roland McGrath and Ulrich Drepper.
```

해결 방법:

이 문제를 해결하기 위해서는 EKS GPU 노드에 배포되는 nvidia toolkit에서 v1.17.8-ubuntu20.04로 선언된 기본값을 v1.14.6-ubi8으로 다운그레이드하면 glibc 2.26과 호환되어 문제가 해결됩니다.

```yaml
# gpu-operator/values_dev_raptor.yaml (gpu-operator v25.3.2)
toolkit:
  enabled: true
  repository: nvcr.io/nvidia/k8s
  image: container-toolkit
  # downgraded to v1.14.6-ubi8 for glibc 2.26 compatibility on amazon linux 2 nodes
  # original v1.17.8-ubuntu20.04 requires glibc 2.27+ but nodes only have glibc 2.26
  version: v1.14.6-ubi8
  imagepullpolicy: ifnotpresent
  imagepullsecrets: []
  env: []
  resources: {}
  installdir: "/usr/local/nvidia"
```

위 .Values.toolkit.version 설정에 의해 nvidia-container-toolkit-daemonset의 이미지 태그 설정이 아래와 같이 반영됩니다.

```yaml,hl_lines=6
# gpu-operator/nvidia-container-toolkit-daemonset (daemonset)
spec:
  template:
    spec:
      containers:
        - image: nvcr.io/nvidia/k8s/container-toolkit:v1.14.6-ubi8
          imagePullPolicy: IfNotPresent
```

toolkit.version 설정을 변경하면 주로 nvidia-container-toolkit-daemonset 파드가 정상화되고, 이를 통해 연쇄적으로 다음 파드들이 정상화됩니다:

1. nvidia-container-toolkit-daemonset: glibc 호환성 문제 해결로 정상 실행
2. nvidia-operator-validator: toolkit이 정상화되면서 GPU 노드 검증 통과

## 관련자료

GPU Operator official docs:

- [NVIDIA GPU Operator docs](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html)

Github Issue:

- [CentOS 7.8/AL2 GLIBC_2.27 compatibility - GitHub Issue #72](https://github.com/NVIDIA/gpu-operator/issues/72) 
