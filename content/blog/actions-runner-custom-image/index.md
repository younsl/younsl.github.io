---
title: actions runner custom image
date: 2025-11-06T14:30:00+09:00
lastmod: 2025-11-06T14:30:00+09:00
description: "한국 환경에 최적화된 GitHub Actions Runner 커스텀 이미지를 빌드하고 배포하는 방법"
tags: ["devops", "kubernetes", "github", "docker"]
---

## 개요

**TL;DR**: Kubernetes에서 Actions Runner를 운영하는 DevOps/SRE 엔지니어를 위한 가이드입니다. 커스텀 이미지를 통해 빌드 시간을 단축하고 패키지 저장소의 안정성을 높일 수 있습니다.

GitHub Actions Runner를 Kubernetes에서 운영하면서 다음과 같은 문제에 직면했습니다:

1. 매번 Workflow 실행 시마다 `make` 같은 빌드 도구를 반복적으로 설치하느라 빌드 시간이 길어짐
2. 기본 패키지 저장소인 `archive.ubuntu.com`의 불안정한 네트워크 상태로 인해 패키지 다운로드가 실패하거나 지연됨

이 글에서는 `make`를 이미지에 포함하여 빌드 타임을 단축하고, Kakao 미러를 추가하여 패키지 저장소를 이중화한 커스텀 이미지를 만드는 방법을 소개합니다.

## 환경

- **Base Image**: [summerwind/actions-runner](https://hub.docker.com/r/summerwind/actions-runner/tags):v2.329.0-ubuntu-24.04
- **OS**: Ubuntu 24.04 LTS (Noble Numbat)
- **추가 구성**: Kakao APT 미러, make 패키지

Actions Runner Controller의 이전 이미지들은 오래된 Ubuntu 버전과 의존성을 사용했으나, v2.329.0부터 Ubuntu 24.04를 지원합니다. 자세한 내용은 [issue #4249](https://github.com/actions/actions-runner-controller/issues/4249)를 참고하세요.

## 커스텀 이미지 구성

커스텀 이미지는 다음과 같은 디렉토리 구조로 구성됩니다:

```bash
actions-runner/
├── Dockerfile
└── kakao-mirror.sources
```

Dockerfile은 Docker Hub의 [summerwind/actions-runner](https://hub.docker.com/r/summerwind/actions-runner) 이미지를 베이스로 사용하며, Kakao 미러와 필수 패키지를 추가합니다:

```dockerfile
FROM summerwind/actions-runner:v2.329.0-ubuntu-24.04

ARG BUILD_DATE

LABEL org.opencontainers.image.base.name="docker.io/summerwind/actions-runner:v2.329.0-ubuntu-24.04" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="actions-runner" \
      org.opencontainers.image.version="0.4.0"

USER root

# Add additional APT sources for better availability
COPY kakao-mirror.sources /etc/apt/sources.list.d/

# Install make and other build essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make \
    && rm -rf /var/lib/apt/lists/*

USER runner
```

베이스 이미지에 Kakao 미러 설정을 추가하고 `make` 패키지를 설치합니다. 패키지 설치 후 `/var/lib/apt/lists/*`를 정리하여 이미지 크기를 최소화합니다.

`kakao-mirror.sources` 파일은 Ubuntu 24.04에서 권장하는 [DEB822](https://repolib.readthedocs.io/en/latest/deb822-format.html) 형식의 APT 소스 설정입니다. APT sources 파일은 기본적으로 `/etc/apt/sources.list.d/` 디렉토리에 `<NAME>.sources` 형식으로 위치합니다:

```text
Enabled: yes
Types: deb
URIs: http://mirror.kakao.com/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

Kakao 미러를 사용하도록 설정하고 Ubuntu 공식 GPG 키로 패키지를 검증합니다. `Suites` 필드는 APT가 참조할 저장소를 지정하는데, `noble`은 Ubuntu 24.04의 기본 패키지 저장소, `noble-updates`는 버그 수정 및 개선 사항, `noble-security`는 보안 패치를 포함합니다.

Ubuntu 버전에 따라 코드명이 달라지므로 베이스 이미지의 Ubuntu 버전과 반드시 일치해야 합니다:

| Ubuntu 버전 | 코드명 | Suites 설정 |
|------------|--------|------------|
| Ubuntu 22.04 LTS | Jammy Jellyfish | jammy jammy-updates jammy-security |
| Ubuntu 24.04 LTS | Noble Numbat | noble noble-updates noble-security |

현재 베이스 이미지가 `ubuntu-24.04`이므로 `noble`을 사용합니다.

## 이미지 빌드

Docker를 사용하여 이미지를 빌드합니다:

```bash
docker build -t actions-runner . --platform linux/amd64
```

M1/M2 Mac에서 빌드할 때는 `--platform linux/amd64` 옵션이 필수입니다. 빌드가 완료되면 다음 명령어로 이미지를 검증할 수 있습니다:

```bash
# Kakao 미러 설정 확인
docker run --rm actions-runner:latest \
  cat /etc/apt/sources.list.d/kakao-mirror.sources

# make 설치 확인
docker run --rm actions-runner:latest which make
```

## 이미지 배포

빌드한 이미지를 Container Registry에 푸시합니다. 이미지 태그는 `<베이스 이미지 버전>-<커스텀 버전>` 형식을 따릅니다. 이는 업스트림 버전과 커스텀 변경사항을 모두 추적할 수 있는 복합 버저닝(Composite Versioning) 전략입니다.

AWS ECR을 사용하는 경우:

```bash
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.ap-northeast-2.amazonaws.com

docker tag actions-runner:latest \
  123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/actions-runner:v2.329.0-ubuntu-24.04-custom-0.1.0

docker push \
  123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/actions-runner:v2.329.0-ubuntu-24.04-custom-0.1.0
```

Kubernetes에서 커스텀 이미지를 사용하려면 RunnerDeployment의 `spec.template.spec.image` 필드를 수정합니다:

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: custom-runner
  namespace: actions-runner
spec:
  template:
    spec:
      enterprise: dogecompany
      image: 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/actions-runner:v2.329.0-ubuntu-24.04-custom-0.1.0
      imagePullPolicy: IfNotPresent
      labels:
        - custom-image
        - ubuntu-24.04
        - v2.329.0
      resources:
        limits:
          cpu: "1.5"
          memory: "6Gi"
        requests:
          cpu: "0.5"
          memory: "1Gi"
```

`image` 필드에 커스텀 이미지 경로를 지정하고, `labels`에 Runner를 식별할 수 있는 라벨을 추가합니다.

## 테스트

배포한 커스텀 이미지가 Runner Pod에서 정상 동작하는지 확인하는 방법은 두 가지가 있습니다.

첫 번째는 `kubectl exec` 명령어로 Runner Pod에 직접 접속하여 확인하는 방법입니다:

```bash
# Runner Pod 이름 확인
kubectl get pod -n actions-runner

# Pod에 접속하여 설정 확인
kubectl exec -it -n actions-runner <pod-name> -- bash

# Kakao 미러 설정 확인
cat /etc/apt/sources.list.d/kakao-mirror.sources
sudo apt-get update

# make 설치 확인
make --version
```

두 번째는 GitHub Actions Workflow를 통해 확인하는 방법입니다:

```yaml
name: Test Custom Runner Image
on:
  workflow_dispatch:

jobs:
  test-custom-image:
    runs-on: [self-hosted, custom-image]
    steps:
      - name: Verify APT sources
        run: cat /etc/apt/sources.list.d/kakao-mirror.sources

      - name: Test package installation
        run: |
          time sudo apt-get update
          time sudo apt-get install -y curl

      - name: Verify make installation
        run: make --version
```

기본 이미지와 커스텀 이미지의 패키지 다운로드 속도 비교:

| 이미지 타입 | apt-get update | 패키지 설치 (curl) |
|-----------|---------------|-------------------|
| 기본 이미지 | ~8초 | ~12초 |
| 커스텀 이미지 (Kakao 미러) | ~2초 | ~3초 |

한국 리전에서 Kakao 미러를 사용할 경우 약 3-4배 빠른 패키지 다운로드 속도를 확인할 수 있습니다.

## 운영 고려사항

커스텀 이미지를 안정적으로 운영하려면 보안, 가용성, 리소스 효율성을 관리해야 합니다:

- **보안 패치**: 베이스 이미지를 정기적으로 업데이트하여 보안 취약점을 해결합니다.
- **미러 서버 가용성**: Kakao 미러 서버 장애에 대비하여 폴백 전략을 마련합니다.
- **이미지 크기**: APT 캐시를 정리하고 `--no-install-recommends` 옵션을 사용하여 이미지 크기를 최소화합니다.

## 관련자료

- [Actions Runner Controller GitHub](https://github.com/actions/actions-runner-controller)
- [Actions Runner 구성 가이드](/blog/actions-runner-admin-guide/)
- [summerwind/actions-runner on Docker Hub](https://hub.docker.com/r/summerwind/actions-runner)
- [Kakao Mirror](https://mirror.kakao.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
