---
title: "elasticsearch admin guide"
date: 2024-01-31T03:15:30+09:00
lastmod: 2024-01-31T03:15:55+09:00
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

**증상**  
Kibana URL로 접근시 503 에러코드와 함께 Http request timed out connecting 에러 발생하는 증상이었습니다.

**원인**  
문제의 근본 원인은 OpenSearch 도메인을 blue-green 배포가 필요한 Elasticsearch_6.8에서 Elasticsearch_7.1 버전으로 업그레이드했기 때문입니다. blue-green 배포에는 이전 클러스터에서 새 클러스터로의 인덱스 마이그레이션이 포함됩니다. 샤드 재할당이 완료되면 Kibana가 완전히 작동하게 됩니다. 이 경우 Kibana 인덱스 마이그레이션 프로세스에서 클러스터에 경쟁 조건이 발생했습니다.

**해결방법**  
AWS 엔지니어가 Manual Intervention 처리해서 해결할 수 있습니다. 이 Manual Intervention은 AWS Support 티켓을 올려 내부팀 에스컬레이션 후 처리됩니다.
