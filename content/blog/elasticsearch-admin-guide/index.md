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
