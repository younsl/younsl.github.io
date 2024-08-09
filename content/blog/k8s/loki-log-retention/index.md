---
title: "loki log retention"
date: 2024-08-05T20:15:45+09:00
lastmod: 2024-08-05T20:15:45+09:00
slug: ""
description: "compactor로 loki-distributed 차트에서 log retetnion 적용"
keywords: []
tags: ["devops", "kubernetes", "loki"]
---

{{< toc >}}

&nbsp;

## 개요

이 가이드는 Loki-distributed 차트에서 사용하여 로그 보존(retention)을 설정하는 방법을 설명합니다.

쿠버네티스 클러스터 환경에서 loki를 운영하고 관리하는 DevOps Engineer, SRE를 대상으로 작성된 가이드입니다.

&nbsp;

## 환경

- **Kubernetes 클러스터**: EKS v1.28 (amd64)
- **Helm 차트**: loki-distributed v0.79.2 (appVersion: loki v2.9.8)
- **Loki 저장소 유형**: gp3 유형의 EBS storageClass에 의해 백업된 persistentVolume 사용
  - 스토리지로 Object Storage<sup>S3</sup>를 사용하지 않았습니다.

&nbsp;

## 배경 지식

### Loki에서의 로그 보존

- Loki에서 로그 보존은 Table Manager 또는 Compactor를 통해 관리됩니다.
- `compactor`는 loki에서 인덱스 파일 압축 및 로그 보존 적용을 담당합니다.

&nbsp;

### `compactor`와 `table-manager` 비교

loki-distributed 차트 v0.79.2 (loki v2.9.8)에서는 Table Manager가 기본적으로 비활성화되어 있으며 `Values.loki.config`에서 관련 설정이 전혀 포함되어 있지 않습니다. Table Manager는 더 이상 사용되지 않으며<sup>deprecated</sup>, 새로 구성하는 최신 버전 Loki에는 권장되지 않습니다. 그 기능은 이제 `compactor`가 대체하며, `compactor`는 로그 보존 및 테이블 관리를 포함한 여러 기능을 처리하도록 설계되었습니다.

기본적으로, `table_manager.retention_deletes_enabled` 또는 `compactor.retention_enabled` 플래그가 설정되지 않은 경우 Loki로 전송된 로그는 무기한 보존됩니다.

자세한 내용은 [보존 페이지](https://grafana.com/docs/loki/v2.9.x/operations/storage/retention/)를 참조하세요.

&nbsp;

## TLDR

- Compactor StatefulSet을 배포하려면 `compactor.enabled`를 `false`에서 `true`로 수정합니다.
- `loki.config.compactor.retention_enabled`를 `true`로 설정합니다.
- `loki.config.compactor.limits_config.retention_period`를 원하는 값(예: `168h`, `7d`, `2w`)으로 설정합니다.

&nbsp;

## 해결방법

기본적으로, loki-distributed 차트에서 Compactor는 비활성화되어 있습니다. 먼저, loki-distributed 차트에서 Compactor StatefulSet을 활성화합니다.

```yaml
# charts/loki-distributed/values.yaml
compactor:
  enabled: true
```

&nbsp;

인덱스 저장을 위해 boltdb-shipper를 사용하고 청크 저장을 위해 gp3 유형의 PV가 마운트된 파일 시스템을 사용하고 있습니다.

```bash
$ kubectl get pvc -n loki -o=jsonpath='{.items[*].spec.volumeName}' | xargs -n1 kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                       STORAGECLASS   REASON   AGE
pvc-4e05529b-7ae4-46dc-bc81-9f47d00dbe1c   10Gi       RWO            Delete           Bound    loki/data-loki-distributed-compactor-0   gp3                     81m
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
pvc-797e97ab-62b7-4d94-86ac-1e50cb7b330d   30Gi       RWO            Delete           Bound    loki/data-loki-distributed-ingester-0   gp3                     4h54m
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
pvc-62448f5f-9a8e-4903-8412-ffca13c720a7   30Gi       RWO            Delete           Bound    loki/data-loki-distributed-ingester-1   gp3                     117m
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
pvc-2ef08f10-0a32-43a2-bbe2-e4a998838e23   30Gi       RWO            Delete           Bound    loki/data-loki-distributed-ingester-2   gp3                     80m
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                     STORAGECLASS   REASON   AGE
pvc-f91c89e4-853d-4e76-882b-64ecea5bbf8e   10Gi       RWO            Delete           Bound    loki/data-loki-distributed-querier-0   gp3                     3d3h
```

&nbsp;

관련 스토리지 구성은 Helm 차트의 `Values.loki`에서 찾을 수 있습니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  # -- Check https://grafana.com/docs/loki/latest/configuration/#schema_config for more info on how to configure schemas
  schemaConfig:
    configs:
    - from: "2020-09-07"
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: loki_index_
        period: 24h

  # -- Check https://grafana.com/docs/loki/latest/configuration/#storage_config for more info on how to configure storages
  storageConfig:
    boltdb_shipper:
      shared_store: filesystem
      active_index_directory: /var/loki/index
      cache_location: /var/loki/cache
      cache_ttl: 168h
    filesystem:
      directory: /var/loki/chunks
```

&nbsp;

[loki v2.9.x 공식문서](https://grafana.com/docs/loki/v2.9.x/operations/storage/table-manager/#retention)에 따르면 로그 보존기간<sup>Log retention</sup> 기능은 인덱스 기간이 `24h`인 경우에만 사용할 수 있습니다. 단일 저장소 TSDB 및 단일 저장소 BoltDB는 내부 구현으로 인해 24시간 인덱스 기간이 필요합니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  schemaConfig:
    configs:
      index:
        prefix: loki_index_
        period: 24h
```

&nbsp;

다음으로 아래와 같이 `loki.config`에 `compactor` 설정을 추가합니다. 기본적으로 compactor 구성 요소는 `loki-distributed` 차트에서 비활성화되어 있습니다.

로그 보존 구성에 대한 자세한 내용은 [Retention 페이지](https://grafana.com/docs/loki/v2.9.x/operations/storage/table-manager/#retention)를 참조하세요.

다음은 `compactor`에 로그 보존기간 설정이 적용된 헬름차트 구성입니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    # ... truncated
    compactor:
      shared_store: filesystem
      working_directory: /var/loki/compactor
      compaction_interval: 10m
      retention_enabled: true
      retention_delete_delay: 2h
      retention_delete_worker_count: 150
      delete_request_store: filesystem
    
    limits_config:
      retention_period: 7d
```

&nbsp;

`compactor` 파드 내의 Loki 설정 파일이 올바르게 적용되었는지 확인합니다.

```bash
kubectl exec -it -n loki loki-distributed-compactor-0 -- cat /etc/loki/config/config.yaml
```

compactor 설정 파일은 파드 안의 `/etc/loki/config/config.yaml`에 위치합니다.

&nbsp;

`kubectl exec` 실행 결과값:

```yaml
# /etc/loki/config/config.yaml file from loki-distributed-compactor-0 pod
...
compactor:
  compaction_interval: 10m
  delete_request_store: filesystem
  retention_delete_delay: 2h
  retention_delete_worker_count: 150
  retention_enabled: true
  shared_store: filesystem
  working_directory: /var/loki/compactor
...
limits_config:
  retention_period: 7d
```

이제 로그 보존 설정과 `limits_config.retention_period`가 의도한 대로 성공적으로 추가된 것을 확인할 수 있습니다.

&nbsp;

## 관련자료

**Loki 공식문서**  
[Loki v2.9.x의 로그 보존기간](https://grafana.com/docs/loki/v2.9.x/operations/storage/retention/)<sup>Retention</sup>  
[Example configuration for retention](https://grafana.com/docs/loki/v2.9.x/operations/storage/retention/#example-configuration)

**Loki Github**  
[loki issue#9207](https://github.com/grafana/loki/issues/9207)
