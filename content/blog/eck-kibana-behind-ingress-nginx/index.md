---
title: "eck kibana behind ingress-nginx"
date: 2025-04-23T22:58:05+09:00
lastmod: 2025-04-23T02:39:20+09:00
slug: ""
description: "eck kibana behind ingress-nginx"
keywords: []
tags: ["devops", "container", "kubernetes", "eck", "kibana", "ingress-nginx"]
---

## 개요

ingress-nginx 뒤에 있는 kibana에 접속하기 위해서는 다음과 같은 별도 설정이 필요합니다.

&nbsp;

## 배경지식

### ECK (Elastic Cloud on Kubernetes)

ECK Operator와 ECK Stack을 사용해서 Elasticsearch와 Kibana를 설치하는 걸 권장합니다. 쿠버네티스에서 [헬름 차트](https://github.com/elastic/cloud-on-k8s)를 사용해서 쉽게 설치할 수 있고, 클러스터 관리 편의성을 제공합니다. Kibana는 kibana 커스텀 리소스를 사용해서 설치하며, Elasticsearch 클러스터는 elasticsearch 커스텀 리소스를 사용해서 설치합니다. 실제로 Kibana + Elasticsearch 구성에 드는 소요 시간은 약 10분 정도입니다.

&nbsp;

## 환경

헬름 차트:

- eck-operator
- eck-stack 0.15.0: eck-kibana + eck-elasticsearch (헬름 차트로 설치)
- ingress-nginx-controller 1.12.0 (헬름 차트로 설치)

&nbsp;

## 설정

ECK Operator와 ECK Stack 헬름 차트가 설치되어 있는 클러스터 환경이라고 가정합니다.

```mermaid
---
title: Helm chart structure for ECK Operator and ECK Stack
---
flowchart LR
  ca["👨🏻‍💼 Cluster Admin"]

  subgraph k8s[Kubernetes Cluster]
    direction LR
    subgraph ns1["`Namespace elastic-system`"]
      eo["`**Chart**
      eck-operator`"]
      eop["`**Pod**
      eck-operator`"]
    end

    subgraph ns2["`Namespace elastic-stack`"]
      es["`**Chart**
      eck-stack`"]
      esk["`**Custom resource**
      kibana`"]
      ese["`**Custom resource**
      elasticsearch`"]
    end
  end

  ca --helm install--> eo & es
  eo --> eop
  eop e1@--Watch resource--> esk
  eop e2@--Watch resource--> ese
  es --> esk & ese

  style ca fill:none, color:white, stroke-width:1px
  style eo fill:#007bff, color:white
  style es fill:#007bff, color:white

  e1@{ animate: true }
  e2@{ animate: true }
```

&nbsp;

ingress-nginx 뒤에 있는 kibana에 접속하기 위해서는 다음과 같이 `nginx.ingress.kubernetes.io/backend-protocol: HTTPS` 설정이 필요합니다.

```yaml
# eck-stack/values_my.yaml (0.15.0)
eck-kibana:
  enabled: true
  elasticsearchRef:
    name: elasticsearch
  config:
    console.ui.enabled: true
  ingress:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: "/"
      # This annotation is important to support end-to-end HTTPS communication!
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
      nginx.ingress.kubernetes.io/service-upstream: "true"
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
    labels: {}
    pathType: Prefix
    hosts:
      - host: my-kibana.example.com
        path: /
    tls:
      enabled: false
```

그 이유는 kibana가 기본적으로 HTTPS 프로토콜의 tcp/5601 포트를 사용하기 때문입니다.

![kibana](./1.png)

&nbsp;

이 502 에러는 ingress-nginx 컨트롤러가 기본적으로 백엔드 서비스와 HTTP로 통신하려고 시도하지만, ECK Kibana는 HTTPS 연결을 기대하기 때문에 발생하는 프로토콜 불일치 문제입니다.

```mermaid
---
title: Bad Gateway response from ECK Kibana pod
---
flowchart LR
    Client([Client]) 
    NLB["`**NLB**
    Internal`"]
    
    subgraph K8S["Kubernetes Cluster"]
        Service["`**Service**
        LoadBalancer`"]
        IngressPod["`**Pod**
        ingress-nginx`"]
        KibanaPod["`**Pod**
        Kibana`"]
        
        IngressPod --HTTP--> KibanaPod
        KibanaPod --"`Verify
        HTTPS?`"--> KibanaPod
        KibanaPod -.Bad Gateway.-> IngressPod
    end

    Service --Reconcile--> NLB
    
    Client -->|HTTPS| NLB
    NLB --Route--> IngressPod
    IngressPod -.Bad Gateway.-> NLB
    NLB -.Bad Gateway.-> Client
    
    style Client fill:#333,stroke:#fff,color:#fff
    style NLB fill:#333,stroke:#fff,color:#fff
    style IngressPod fill:#333,stroke:#fff,color:#fff
    style KibanaPod fill:#333,stroke:#fff,color:#fff
    style K8S fill:#1a1a1a,stroke:#666,stroke-width:2px,color:#fff

    linkStyle 7 stroke:#ff8c00,stroke-width:1px
    linkStyle 6 stroke:#ff8c00,stroke-width:1px
    linkStyle 2 stroke:#ff8c00,stroke-width:1px

    note1["**Note**: In this diagram, kubernetes service resources was omitted in front of pods for brevity"]
    note1 ~~~ NLB 
    style note1 fill:transparent,color:gray,stroke-width:0px
```

즉, 게이트웨이(ingress-nginx)가 업스트림 서버(Kibana)로부터 유효한 응답을 받지 못해 사용자에게 502 Bad Gateway 에러를 반환하는 것입니다.

&nbsp;

## 관련자료

- [Ingress rule for Kibana webUI gives http code 502 (bad gateway) #2118](https://github.com/elastic/cloud-on-k8s/issues/2118#issuecomment-2823560096)
