---
title: "Kyverno"
date: 2023-08-27T21:33:45+09:00
lastmod: 2023-09-04T23:58:45+09:00
slug: ""
description: "Kyverno 운영 가이드"
keywords: []
tags: ["devops", "kubernetes"]
---

## 목차

- [목차](#목차)
- [개요](#개요)
- [배경지식](#배경지식)
  - [Kyverno](#kyverno)
  - [Admission Controllers](#admission-controllers)
- [Kyverno 운영 가이드](#kyverno-운영-가이드)
  - [정책 마켓플레이스](#정책-마켓플레이스)
  - [정책 타입](#정책-타입)
  - [정책 모드](#정책-모드)
  - [Kyverno 컨트롤러](#kyverno-컨트롤러)
  - [고가용성](#고가용성)
  - [설치방식](#설치방식)
    - [필요 차트](#필요-차트)
    - [설치 순서](#설치-순서)
  - [정책 운영 팁](#정책-운영-팁)
    - [Validate Rule](#validate-rule)
- [더 나아가서](#더-나아가서)
  - [정책 현황 시각화](#정책-현황-시각화)

&nbsp;

## 개요

Kyverno 운영 가이드입니다.

쿠버네티스 클러스터를 운영하고 보안을 관리하는 DevOps Engineer, SRE 그리고 클라우드 보안 엔지니어를 대상으로 작성된 문서입니다.

&nbsp;

## 배경지식

### Kyverno

[Kyverno](https://github.com/kyverno/kyverno)는 Kubernetes용으로 설계된 정책 엔진입니다.

Kyverno의 정책은 ClusterPolicy라고 하는 Kubernetes 리소스(CRD)로 관리됩니다. Kyverno는 [OPA](https://github.com/open-policy-agent/opa)와 달리 정책을 작성하는 데 새로운 프로그래밍 언어가 필요하지 않습니다.

&nbsp;

### Admission Controllers

쿠버네티스에서 사용할 수 있는 대표적인 Admission Controllers 3가지

![대표적인 3가지 Kuberntes Admission Controller 비교](./2.png)

- **PSS**<sup>Pod Security Standard</sup> : PSS는 Kubernetes v1.21에서 deprecated된 PSP<sup>Pod Security Policy</sup>를 대체하는 쿠버네티스 기본 Admission Controller 입니다.
- **OPA**<sup>Open Policy Agent</sup> : Rego 문법 기반의 Rule 작성. 토스뱅크가 대표적으로 OPA를 잘 사용하는 회사입니다.
- **Kyverno** : YAML 문법 기반의 Rule 작성. OPA의 [Rego](https://www.openpolicyagent.org/docs/latest/policy-language/#what-is-rego)와 같은 언어 학습이 필요 없어서 운영이 쉽습니다.

OPA와 Kyverno 둘다 사용해본 AWS Solutions Architect의 경우, OPA 보다 정책 작성이 쉬운 Kyverno를 적극 추천했습니다.

&nbsp;

## Kyverno 운영 가이드

### 정책 마켓플레이스

모든 Policy의 YAML을 처음부터 작성할 필요 없이 약 292개의 정책이 이미 올라와 있습니다.

[Kyverno Policies](https://kyverno.io/policies/)  
[Github: kyverno/policies](https://github.com/kyverno/policies)

&nbsp;

### 정책 타입

Kyverno는 쿠버네티스 리소스를 검증, 변경, 생성 및 정리하고 컨테이너 이미지 검증을 수행할 수 있는 정책을 생성합니다.

![Kyverno 주요 룰 종류](./1.png)

총 5개 타입의 룰을 사용할 수 있습니다.

- **validate** rule: 리소스의 설정을 검증하는 룰
- **mutate** rule: 리소스의 설정을 변경하는 룰
- **generate** rule: 조건에 따라 리소스를 생성하는 룰
- **verifyImage** rule: 컨테이너 이미지를 검증하는 룰
- **cleanup** rule: 리소스를 정리하는 룰

Kyverno 정책 작성 방법은 Kyverno 공식문서 [Writing Policies](https://kyverno.io/docs/writing-policies/)를 참고합니다.

&nbsp;

### 정책 모드

Validate Policy는 2개의 모드 중 하나로 동작합니다.

- **Enforce**: Enforce 모드는 위반한 리소스를 생성 거부합니다.
- **Audit**: Audit 모드는 정책에서 위반하더라도 해당 리소스 생성을 허용합니다. 대신 정책 위반사항을 PolicyReport에 기록합니다.

요약하자면, Enforce 모드는 실제로 정책을 리소스에 적용하여 적절한 변경을 강제화하는 반면, Audit 모드는 정책의 영향을 사전에 확인하고 분석하기 위해 사용되는 모드입니다.

&nbsp;

ClusterPolicy 리소스에서는 `spec.validationFailureAction`에서 설정할 수 있습니다.

```yaml
apiVersion: kyverno.io/v1
# The `ClusterPolicy` kind applies to the entire cluster.
kind: ClusterPolicy
metadata:
  name: require-ns-purpose-label
# The `spec` defines properties of the policy.
spec:
  # The `validationFailureAction` tells Kyverno if the resource being validated should be allowed but reported (`Audit`) or blocked (`Enforce`).
  validationFailureAction: Enforce # or `Audit`
```

&nbsp;

### Kyverno 컨트롤러

Kyverno는 4개의 컨트롤러 파드로 구성됩니다.  
각 컨트롤러 파드별 역할은 공식문서 [Controllers in kyverno](https://kyverno.io/docs/high-availability/#controllers-in-kyverno)를 참고합니다.

![Kyverno 파드 아키텍처](./3.png)

- **Admission Controller** : Kubernetes API 서버로부터 AdmissionReview 요청 수신을 담당합니다. `validate`, `mutate`, `verifyImage` rule 처리를 담당합니다.
- **Background Controller** : `generate` rule, 기존 리소스에 대한 `mutate` rule 처리를 담당합니다.
- **Cleanup Controller** : cleanup policy 처리
- **Reports Controller** : Validate Rule의 스캔 결과에 대한 보고서 생성

&nbsp;

### 고가용성

[kyverno 헬름 차트](https://github.com/kyverno/kyverno/blob/main/charts/kyverno/values.yaml)는 각 컨트롤러에 대해 여러 개의 파드를 구성하기 위한 설정값을 제공합니다. 공식문서에서 권장하는 고가용성 설정은 다음과 같습니다.

```bash
admissionController.replicas: 3
backgroundController.replicas: 2
cleanupController.replicas: 2
reportsController.replicas: 2
```

> **Note**  
> Kyverno 설치시 반드시 Admission Controller Pod가 포함되어 있어야 합니다. Admission Controller의 `replicas` 파드 개수는 2개를 지원하지 않습니다. 고가용성 구성으로 Kyverno를 설치해야하는 경우, Admission Controller가 지원하는 유일한 `replicas` 개수는 `3`개입니다.

자세한 사항은 Kyverno 공식문서 [High Availability](https://kyverno.io/docs/high-availability/)를 참고합니다.

&nbsp;

### 설치방식

#### 필요 차트

Kyverno를 운영하려면 2개의 헬름 차트 설치가 필요합니다.

- **kyvenro** : (Required) Kyverno 정책 엔진 헬름 차트. kyverno 정책 엔진 관련 리소스는 모두 전용 네임스페이스인 `kyverno`에 위치하게 됩니다.
- **kyverno-policies** : (Required) ClusterPolicy를 모아놓은 헬름 차트
- **policy-reporter** : (Optional) 클러스터 정책 현황을 시각화해주는 Web UI 컴포넌트입니다. 조직의 요구사항에 따라 설치하면 되며, `policy-reporter` 대신 Prometheus + Grafana 연동으로 대체할 수 있습니다.

Kyverno는 [설치 방식](https://kyverno.io/docs/installation/methods/)<sup>Installation method</sup>으로 [오퍼레이터 패턴](https://kubernetes.io/ko/docs/concepts/extend-kubernetes/operator/)을 지원하지 않으며, 헬름 차트와 YAML 직접 설치 방식만 지원하고 있습니다.

&nbsp;

#### 설치 순서

기본적으로 Kyverno 정책 엔진인 `kyverno`를 먼저 설치한 다음, 정책 리소스 모음 차트인 `kyvenro-policies`를 배포합니다.

이를 그림으로 표현하면 다음과 같습니다.

![helm 차트 설치 과정](./4.png)

&nbsp;

### 정책 운영 팁

Kyverno를 운영하면서 가장 높은 비중을 차지하는 정책 타입은 리소스 YAML로부터 설정을 검증하는 Validate Policy 입니다. Validate Policy를 작성하고 적용하는 과정에서 유용하게 쓸 수 있는 몇 가지 팁을 소개합니다.

#### Validate Rule

- 검증<sup>Validate</sup> 정책을 개발하는 상황에서 테스트할 때, 정책적용 보고서<sup>PolicyReport</sup>를 볼 필요 없이 즉시 결과를 확인할 수 있도록 `validationFailureAction: Enforce`을 설정하는 것이 간편합니다.
- 프로덕션 환경에 Validate 정책을 적용할 경우, `validationFailureAction: Audit`으로 되어 있는지 확인하여 정책이 의도하지 않은 결과를 초래하지 않도록 방지합니다. 이후 안정성이 검증되었고 정책을 강제해야한다고 판단이 들 때 `validationFailureAction: Force`로 전환하여 강제 적용합니다.
- Validate 정책은 다른 규칙<sup>Rule</sup>에 대응할 수 없습니다. 예를 들어 모든 이미지가 레지스트리 `reg.corp.com`에서 나오도록 작성된 규칙과, 해당 이미지가 `reg.corp.com`에서 나오지 않도록 작성된 또 다른 규칙<sup>Rule</sup>은 사실상 모든 이미지 가져오기를 불가능하게 만들고 아무것도 실행되지 않게 됩니다. 규칙<sup>Rule</sup>이 정의된 위치나 순서는 중요하지 않습니다.

자세한 사항은 Kyverno 공식문서 [Tips & Tricks](https://kyverno.io/docs/writing-policies/tips/)를 참고합니다.

&nbsp;

## 더 나아가서

### 정책 현황 시각화

저희가 Kyverno 엔진을 설치하고 ClusterPolicy를 적용하는 업무의 최종 목적지는 결국 모범사례를 위반된 리소스들을 인지하고 개선하기 위함입니다.  
클러스터에 배포된 Kyverno 정책의 현황, 정책에 위반된 리소스들을 `kubectl`로 필터링해 볼 수 있습니다만, 방법이 복잡하고 명령어를 매번 치기 귀찮습니다. 또한 보안 직군과 같은 쿠버네티스 이해도가 다른 사람과 정책 운영 업무를 협업하는 건 현실적으로 어렵습니다.

&nbsp;

Kyverno는 이 문제를 해결하기 위해 정책 운영결과 시각화 도구 2가지를 제공합니다.

1. [Policy Reporter UI](https://github.com/kyverno/policy-reporter)
2. [Prometheus + Grafana](https://kyverno.io/docs/monitoring/) : Grafana 대시보드 생성을 위한 공식 `.json` 파일도 같이 제공하고 있습니다.

Policy Reporter UI는 공식 [헬름차트](https://github.com/kyverno/policy-reporter/tree/main/charts/policy-reporter)로 간단하게 설치할 수 있습니다. 사내망에서만 접근 가능한 Policy Reporter를 아래와 같이 구성할 수 있습니다.

![Policy Reporter 구성 예시](./5.png)

&nbsp;

`kyverno` 헬름차트를 설치하면 기본적으로 8000번 포트로 각 컨트롤러마다 prometheus 수집을 위한 메트릭 서비스가 생성됩니다.

```bash
# values.yaml (helm chart for kyverno)

admissionController:
  ...
  metricsService:
    create: true
    port: 8000
    type: ClusterIP

backgroundController:
  ...
  metricsService:
    create: true
    port: 8000
    type: ClusterIP

cleanupController:
  ...
  metricsService:
    create: true
    port: 8000
    type: ClusterIP

reportsController:
  ...
  metricsService:
    create: true
    port: 8000
    type: ClusterIP
```

메트릭 수집 전용 서비스 타입이 TCP/8000에 `ClusterIP`로 생성되므로 기본적으로 같은 클러스터의 Prometheus 서버만 메트릭을 수집할 수 있다는 한계가 있습니다.

&nbsp;

외부에 있는 Prometheus 서버가 메트릭을 수집하려면, 다음과 같이 metrics용 서비스를 기본값 `ClusterIP`에서 `NodePort`로 변경해야 합니다.

```bash
# values.yaml (helm chart for kyverno)

admissionController:
  metricsService:
    create: true
    type: NodePort
    port: 8000
    nodePort: 8000
  # ...

backgroundController:
  metricsService:
    create: true
    type: NodePort
    port: 8000
    nodePort: 8000
  # ...

cleanupController:
  metricsService:
    create: true
    type: NodePort
    port: 8000
    nodePort: 8000
  # ...

reportsController:
  metricsService:
    create: true
    type: NodePort
    port: 8000
    nodePort: 8000
  # ...
```

기본값 `ClusterIP`를 `NodePort`로 변경해서 노출하게 되면, Kyverno Pod들이 위치한 클러스터 바깥에 Prometheus Server가 있더라도 Kyverno 메트릭을 수집해갈 수 있습니다.

![외부 노출을 위한 NodePort 구성](./6.png)

&nbsp;

서비스 타입을 `NodePort` 말고 `LoadBalancer` 타입을 쓰는 방법도 있습니다. 자세한 사항은 Kyverno 공식문서의 [Monitoring](https://kyverno.io/docs/monitoring/#installation-and-setup) 페이지를 참고합니다.
