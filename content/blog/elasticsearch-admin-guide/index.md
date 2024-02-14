---
title: "elasticsearch admin guide"
date: 2024-01-31T03:15:30+09:00
lastmod: 2024-02-13T11:15:55+09:00
slug: ""
description: "DevOps Engineer를 위한 ElasticSearch 클러스터 운영 가이드"
keywords: []
tags: ["webtob"]
---

{{< toc >}}

&nbsp;

## 개요

OpenSeearch, ElasticSearch 운영자를 위한 가이드

&nbsp;

## 환경

- AWS OpenSearch
- Elasticsearch 7.1.1

&nbsp;

## 제약사항

### ElasticSearch 관리자의 API 제한

- AWS Managed Service 중 하나인 OpenSearch는 Elasticsearch를 기반으로 하지만, 모든 Elasticsearch 버전의 모든 관리자 API를 지원하지는 않으며 ElasticSearch 버전마다 지원되는 API 목록도 다릅니다.
- OpenSearch 버전별 지원되는 Administration API 목록은 [AWS 공식문서](https://docs.aws.amazon.com/ko_kr/opensearch-service/latest/developerguide/supported-operations.html#version_7_1)에서 확인하실 수 있습니다.

&nbsp;

대표적인 관리자 API 제한의 예시는 다음과 같습니다.

Amazon OpenSearch 서비스 기준, ElasticSearch 7.1 버전 클러스터에서는 `/<INDEX_NAME>/_close`, `/_cluster/settings`와 같은 관리자 API를 사용 못하도록 AWS 측에서 막아놓은 상태입니다.

```bash
curl \
  -X PUT \
  -H 'Content-Type: application/json' \
  -d '{
    "persistent": {
      "index.number_of_shards": "5"
    }
  }' \
  "$ES_ENDPOINT/_cluster/settings"
```

```bash
{"Message":"Your request: '/_cluster/settings' payload is not allowed."}
```

위와 같이 `/_cluster/settings` API를 사용해서 `index.number_of_shards` 값을 변경하는 걸 금지하고 있습니다.

&nbsp;

## 관리 명령어 Cheatsheet

ElasticSearch 클러스터를 운영 관리할 때 주로 사용되는 명령어입니다.

&nbsp;

> **중요**  
> 지금부터 설명하는 모든 ElasticSearch 클러스터 관리 명령어는 Amazon OpenSearch의 ElasticSearch v7.1 기준으로 작성되었습니다.

&nbsp;

명령어 실행 전 `ES_ENDPOINT` 환경변수 설정이 필요합니다.

```bash
ES_ENDPOINT="https://xxxxyyyyzzzz.ap-northeast-2.es.amazonaws.com"
```

&nbsp;

### 클러스터 상태 확인

```bash
curl \
  --location \
  --request GET \
  "$ES_ENDPOINT/_cat/health?v"
```

```bash
epoch      timestamp cluster                           status node.total node.data discovered_master shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1707787301 01:21:41  111122223333:krdev-eks-pod-log    yellow          1         1              true     94  94    0    0       79             0                  -                 54.3%
```

&nbsp;

### 디스크 사용률 확인

Elasticsearch 클러스터의 현재 상태와 디스크 사용량을 파악하는 데 도움이 됩니다.

```bash
curl \
  --silent \
  --location \
  --request GET \
  "$ES_ENDPOINT/_cat/allocation?v" \
  | column -t
```

```bash
shards  disk.indices  disk.used  disk.avail  disk.total  disk.percent  host     ip       node
94      4.3gb         34.4gb     457.4gb     491.9gb     7             x.x.x.x  x.x.x.x  0543ab69abe3219a760597764596e007
84      UNASSIGNED
```

결과값으로 제공되는 각 컬럼의 의미는 다음과 같습니다.

- `shards`: 클러스터 내에서 사용 중인 샤드(shard)의 수입니다.
- `disk.indices`: 클러스터 내에서 모든 인덱스(index)의 데이터 크기를 합한 값입니다.
- `disk.used`: 클러스터에서 현재 사용 중인 디스크 공간의 크기입니다.
- `disk.avail`: 디스크에서 사용 가능한 공간의 크기입니다.
- `disk.total`: 디스크의 총 용량입니다.
- `disk.percent`: 디스크 사용량의 백분율입니다.
- `host`: 해당 노드가 호스팅되는 호스트의 이름입니다.
- `ip`: 해당 노드의 IP 주소입니다.
- `node`: Elasticsearch 클러스터 내에서 노드를 고유하게 식별하는 노드의 이름입니다.

&nbsp;

### 전체 인덱스 조회

```bash
curl \
  --location \
  --request GET \
  "$ES_ENDPOINT/_cat/indices?v"
```

&nbsp;

### 특정 인덱스 조회

```bash
curl \
  --location \
  --request GET \
  "$ES_ENDPOINT/_cat/indices/podlog-*?v"
```

```bash
health status index              uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   podlog-2024.02.08  6W43rShCTLWWKC7nB5--Tw   5   1  249584305            0    204.5gb        204.5gb
yellow open   podlog-2024.02.12  vEjL6abBTjaUNCPiPgeROA   5   1       6975            0      2.6mb          2.6mb
yellow open   podlog-2024.02.09  lh0Ff-s-RHSQICezWQdZag   5   1    7949874            0        2gb            2gb
yellow open   podlog-2024.02.11  upcTdSE9QV-fLOKftAU2Eg   5   1      22611            0      9.8mb          9.8mb
yellow open   podlog-2024.02.10  lx0h-wzDQM6FxhTwSqe08w   5   1     721369            0    286.9mb        286.9mb
```

&nbsp;

### 인덱스 삭제

```bash
curl \
  --location \
  --request DELETE \
  "$ES_ENDPOINT/podlog-2024.02.07"
```

명령이 성공적으로 실행되면 Elasticsearch는 `acknowledged:true`와 같은 응답을 반환합니다. 이것은 삭제 요청이 성공적으로 처리되었음을 나타냅니다.

```bash
{"acknowledged":true}
```

&nbsp;

## 싱글 노드 설정

1개의 데이터 노드로 구성된 ElasticSearch 클러스터의 권장 설정은 [single-node-es.md](https://gist.github.com/angristan/9d251d853d11f265899b8a4725bff756) 문서를 참고합니다.

&nbsp;

### 신규 인덱스의 Default 설정

기본 인덱스 템플릿 설정을 업데이트합니다.

```bash
curl \
  --location \
  --request PUT \
  --header 'Content-Type: application/json' \
  --data '{
    "index_patterns": ["*"],
    "order": -1,
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
    }
  }' \
  "$ES_ENDPOINT/_template/default"
```

설정값에 대한 상세설명

- `index_patterns` : 이 템플릿이 적용될 인덱스 패턴을 나타냅니다. 여기서 "*"는 모든 인덱스에 해당 템플릿이 적용됨을 의미합니다.
- `order` : 이 템플릿이 다른 템플릿보다 우선적으로 적용되는 순서를 결정합니다. 여기서 `-1`은 다른 모든 템플릿보다 먼저 적용되도록 강제하는 것을 의미합니다.
- `settings.number_of_shards` : `number_of_shards`를 `1`로 설정하여 인덱스당 샤드 수를 1개로 설정합니다. 이 설정은 기존 인덱스에 영향을 주지 못하며 새로운 인덱스가 생성될 때 적용됩니다.
- `settings.number_of_replicas` : `0`으로 설정하여 복제본을 사용하지 않음을 나타냅니다. 이 설정은 기존 인덱스에 영향을 주지 못하며 새로운 인덱스가 생성될 때 적용됩니다.

```bash
{"acknowledged":true}
```

&nbsp;

적용된 기본 인덱스 탬플릿 설정을 확인합니다.

```bash
curl \
  --location \
  --request GET \
  "$ES_ENDPOINT/_template/default?pretty"
```

```json
{
  "default" : {
    "order" : -1,
    "index_patterns" : [
      "*"
    ],
    "settings" : {
      "index" : {
        "number_of_shards" : "1",
        "number_of_replicas" : "0"
      }
    },
    "mappings" : { },
    "aliases" : { }
  }
}
```

`default` 인덱스 템플릿에 `number_of_shards`, `number_of_replicas` 값이 새로 추가된 걸 확인할 수 있습니다.

&nbsp;

### 기존 인덱스 설정

기존 인덱스 설정을 확인합니다.

```bash
curl \
  --request GET \
  "$ES_ENDPOINT/_all/_settings?pretty"
```

&nbsp;

전체 인덱스에 `number_of_replicas` 설정 적용

```bash
curl \
  --request PUT \
  --header 'Content-Type: application/json' \
  --data '{
    "index": {
        "number_of_replicas": "0"
    }
  }' \
  "$ES_ENDPOINT/_all/_settings"
```

```bash
{"acknowledged":true}
```

&nbsp;

## 인덱스 관리

### ISM Policy

![ISM Policy](./1.png)

인덱스는 처음에 hot 상태입니다. 2일 후 ISM이 인덱스를 old 상태로 전환합니다. old 상태로 전환될 떄 스토리지 공간 절약을 위해 인덱스 복제본<sup>Replicas</sup>을 0으로 변경합니다. 인덱스가 3일을 경과한 후에는 ISM이 인덱스를 삭제합니다.

```json
{
    "policy": {
        "policy_id": "delete_old_kubelog_dev_retention_3days",
        "description": "delete kubelog retention 3 days (DEV)",
        "last_updated_time": 1704246457086,
        "schema_version": 1,
        "error_notification": null,
        "default_state": "hot",
        "states": [
            {
                "name": "hot",
                "actions": [],
                "transitions": [
                    {
                        "state_name": "old",
                        "conditions": {
                            "min_index_age": "2d"
                        }
                    }
                ]
            },
            {
                "name": "old",
                "actions": [
                    {
                        "replica_count": {
                            "number_of_replicas": 0
                        }
                    }
                ],
                "transitions": [
                    {
                        "state_name": "delete",
                        "conditions": {
                            "min_index_age": "3d"
                        }
                    }
                ]
            },
            {
                "name": "delete",
                "actions": [
                    {
                        "delete": {}
                    }
                ],
                "transitions": []
            }
        ],
        "ism_template": [
            {
                "index_patterns": [
                    "kubelog-*"
                ],
                "priority": 100,
                "last_updated_time": 1658891261769
            }
        ]
    }
}
```

자세한 사항은 [인덱스 상태 관리](https://docs.aws.amazon.com/ko_kr/opensearch-service/latest/developerguide/ism.html#ism-example)를 참고합니다.

&nbsp;

## Kibana

### ElasticSearch 업그레이드 후 Kibana 접근 불가 에러

AWS 콘솔을 사용해서 ElasticSearch v6.8을 v7.1로 업그레이드한 직후 경험했던 문제.

&nbsp;

#### 증상

Kibana URL로 접근시 503 에러코드와 함께 Http request timed out connecting 에러 발생하는 증상이었습니다.

&nbsp;

#### 발생 환경

- **플랫폼** : AWS OpenSearch
- **ElasticSearch** v7.1

&nbsp;

#### 원인

문제의 근본 원인은 OpenSearch 도메인을 blue-green 배포가 필요한 Elasticsearch_6.8에서 Elasticsearch_7.1 버전으로 업그레이드했기 때문입니다. blue-green 배포에는 이전 클러스터에서 새 클러스터로의 인덱스 마이그레이션이 포함됩니다. 샤드 재할당이 완료되면 Kibana가 완전히 작동하게 됩니다. 이 경우 Kibana 인덱스 마이그레이션 프로세스에서 클러스터에 경쟁 조건이 발생했습니다.

&nbsp;

#### 해결방법

AWS 엔지니어가 수동 조치<sup>Manual Intervention</sup> 처리해서 해결할 수 있습니다. 이 Manual Intervention은 AWS 사용자가 Support 티켓을 올려야하며, AWS 내부팀 에스컬레이션이 된 후 처리됩니다.

![Kibana 조치 다이어그램](./2.png)
