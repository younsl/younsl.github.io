---
title: "loki tuning"
date: 2024-08-28T00:37:45+09:00
lastmod: 2024-08-28T00:37:45+09:00
slug: ""
description: "best practices for loki tuning"
keywords: []
tags: ["devops", "observability", "kubernetes", "loki"]
---

## 개요

Loki 튜닝 가이드. `loki-distributed` 차트를 기준으로 설명합니다.

> [loki-distributed](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed) 차트는 마이크로서비스 형태로 Loki 리소스를 관리할 수 있도록 해주는 헬름 차트입니다.

`loki`를 운영하는 DevOps Engineer를 대상으로 작성되었습니다.

&nbsp;

## 환경

- **EKS**: v1.28
- **헬름 차트**: loki-distributed (loki v2.9.8)

&nbsp;

## 필수 세팅

### retention (compactor)

Grafana Loki의 보존은 Table Manager 또는 Compactor라는 컴포넌트를 통해 수행됩니다.

기본적으로, loki-distributed 차트에서 Compactor는 비활성화되어 있습니다. 이는 한 번 저장된 로그를 영구 보관<sup>live forever</sup>한다는 의미입니다.

&nbsp;

로그 보관주기<sup>log retention</sup>을 설정하려면 loki-distributed 차트에서 `compactor`를 활성화합니다. `compactor` 파드는 statefulset에 의해 배포됩니다.

```yaml
# charts/loki-distributed/values.yaml
compactor:
  enabled: true
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

> **중요**: Loki에서 로그 보관주기<sup>log retention</sup> 기능은 인덱스 기간<sup>`period`</sup>이 `24h`인 경우에만 사용할 수 있습니다.

&nbsp;

다음은 `compactor`에 로그 보존기간 설정이 적용된 `loki-distributed` 헬름차트 설정입니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    # ... truncated
    compactor:
      shared_store: s3
      working_directory: /var/loki/compactor
      compaction_interval: 10m
      retention_enabled: true
      retention_delete_delay: 2h
      retention_delete_worker_count: 150
      delete_request_store: s3
    
    limits_config:
      retention_period: 7d
```

`retention_enabled`를 `true`로 설정합니다. 이 설정이 없는 경우 compactor는 테이블 압축만 `compaction_interval` 시간(위 설정의 경우는 10분)마다 수행합니다.

&nbsp;

`retention_period`에 보존기간을 지정합니다. (e.g. `168h`, `7d`)

Log retention의 중요 설정만 보면 다음과 같습니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    compactor:
      retention_enabled: true

    limits_ocnfig:
      retention_period: 7d
```

&nbsp;

차트 설정을 업그레이드한 이후에는 `compactor` 파드 내의 Loki 설정 파일이 올바르게 적용되었는지 확인합니다.

```bash
# loki namespace의 compactor pod에서 Loki 설정 파일(config.yaml)을 출력하는 명령어

kubectl exec -it -n loki \
  loki-distributed-compactor-0 \
  -- cat /etc/loki/config/config.yaml
```

더 자세한 사항은 Loki 공식문서의 [Retention](https://grafana.com/docs/loki/v2.9.x/operations/storage/retention/) 페이지와 [#9207](https://github.com/grafana/loki/issues/9207) 이슈를 참고합니다.

&nbsp;

### storage의 최대 조회기간 (ingester)

`max_look_back_period`는 Loki 인제스터가 검색 쿼리 시 검색할 수 있는 최대 기간을 정의합니다. 이 값이 설정되면, 사용자 쿼리가 이 기간을 넘는 데이터에 대해서는 검색할 수 없습니다.

예를 들어, `max_look_back_period`가 720시간(30일)으로 설정되면, 쿼리가 30일보다 오래된 데이터에 대해 검색할 수 없게 됩니다. 이는 데이터의 양이 너무 많아져서 인제스터가 과도한 리소스를 소비하지 않도록 방지합니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    chunk_store_config:
      max_look_back_period: 720h
```

&nbsp;

### Replication Factor (ingester)

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    ingester:
      lifecycler:
        ring:
          kvstore:
            store: memberlist
          replication_factor: 3
```

Loki ingester의 RF가 3인 경우, 3개 파드 모두 동일한 데이터를 가지고 있기 때문에 rollingUpdate 발생시에도 데이터의 내구성과 가용성도 잘 유지됩니다. PDB도 추가하도록 합니다.

```yaml
# charts/loki-distributed/values.yaml
ingester:
  maxUnavailable: 1
```

&nbsp;

### heartbeat_timeout (ingester)

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    ingester:
      lifecycler:
        ring:
          kvstore:
            store: memberlist
          replication_factor: 3
          heartbeat_timeout: 10m
```

`heartbeat_timeout`은 ingester(로그 데이터를 처리하는 노드)가 일정 시간 동안 응답하지 않을 때, 더 이상 해당 노드로 로그 데이터를 보내지 않고 건너뛰는 시간을 의미합니다. 이 설정이 중요한 이유는, 링(ring)이라는 구조에서 모든 ingester가 일정 시간 동안 응답하지 않으면, 그 시간 이후에는 모든 노드가 건너뛰어져서 클러스터 전체에서 로그 데이터를 받을 수 없게 되어 데이터 수집이 중단될 수 있기 때문입니다.

따라서, heartbeat timeout을 너무 짧게 설정하면 잠깐의 네트워크 지연이나 일시적인 문제로 인해 로그 수집이 중단될 위험이 있습니다. 반대로, 너무 길게 설정하면 실제로 문제가 있는 ingester가 너무 오랜 시간 동안 데이터를 받으려 시도하다가 문제가 확산될 수 있습니다. `heartbeat_timeout`을 10분<sup>`10m</sup>으로 설정할 것을 권장하며, 이는 링이 비정상적으로 응답하지 않을 경우(예: Consul이 중지되었다가 다시 시작되는 경우)에도 충분히 복구될 수 있는 시간을 확보하기 위함입니다.

별도로 `heartbeat_timeout`을 선언하지 않은 경우, `heartbeat_timeout`은 기본값 1분<sup>`1m`</sup>으로 설정됩니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    ingester:
      lifecycler:
        ring:
          kvstore:
            store: memberlist
          # The heartbeat timeout after which ingesters are skipped for
          # reads/writes. 0 = never (timeout disabled).
          # CLI flag: -pattern-ingester.ring.heartbeat-timeout
          [heartbeat_timeout: <duration> | default = 1m]
```

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    ingester:
      lifecycler:
        ring:
          heartbeat_timeout: 1m
```

&nbsp;

### chunk_encoding (ingester)

`chunk_encoding`은 Loki에서 청크(chunk) 데이터를 저장할 때 사용하는 압축 알고리즘 설정값입니다. 기본값으로는 압축률이 가장 좋은 `gzip`이 사용되지만, 더 빠른 압축 해제 속도를 제공해 쿼리 속도를 높일 수 있는 `snappy`를 사용할 것을 권장합니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    ingester: |
      chunk_encoding: snappy
```

&nbsp;

### chunk_idle_period (ingester)

`chunk_idle_period` 청크 유휴 기간은 스트림이 유휴 상태이거나 오래되어 청크가 플러시될 것으로 간주하기 전에 Loki가 로그 항목을 기다리는 최대 시간입니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    ingester:
      # default: 30m
      chunk_idle_period: 1h
```

`chunk_idle_period`는 로그 스트림이 비활성 상태 또는 오래된 것으로 간주되기 전에 기다리는 최대 시간을 의미하며, 이 시간이 지나면 로그 데이터가 메모리에서 영구 저장소로 옮겨집니다(플러시). 이 값을 너무 낮게 설정하면 로그 스트림이 천천히 기록될 때 너무 작은 데이터 조각들이 자주 영구 저장소로 옮겨질 수 있고, 너무 높게 설정하면 불필요하게 메모리를 오래 사용할 수 있습니다. 일반적으로 1시간에서 2시간 사이로 설정하는 것이 좋습니다. 이 값은 max_chunk_age와 동일하게 설정할 수 있지만, 더 길게 설정할 경우 로그 데이터가 항상 max_chunk_age에서 영구 저장소로 옮겨지므로 일부 메트릭이 덜 정확해질 수 있습니다.

&nbsp;

### loki의 rate limit

Loki에서 테넌트가 설정된 로그 수집 속도 제한을 초과하면 `rate_limited` 에러가 발생합니다. `loki-distributor` 차트에서 `distributor` 파드(컴포넌트)는 테넌트당 최대 데이터 수집 속도를 기준으로 들어오는 로그의 속도를 제한할 수도 있습니다.

이 문제를 해결하기 위한 한 가지 방법은 Loki 클러스터의 속도 제한을 증가시키는 것입니다. 이러한 제한은 `limits_config` 블록에서 전역적으로 수정하거나, runtime overrides 파일에서 테넌트별로 조정할 수 있습니다. 사용할 수 있는 설정 옵션은 `ingestion_rate_mb`와 `ingestion_burst_size_mb` 입니다.

이와 함께 Loki 클러스터가 이러한 높은 한도를 처리할 수 있도록 충분한 리소스가 프로비저닝되어 있는지 확인해야 합니다. 그렇지 않으면, 더 많은 로그 라인을 처리하려다 클러스터의 성능 저하가 발생할 수 있습니다.

&nbsp;

로그를 수집하는 promtail에서 아래와 같은 Rate Limit에 의한 거부 에러가 발생할 수 있습니다.

```bash
server returned HTTP status 429 Too Many Requests (429): Maximum active stream limit exceeded, reduce the number of active streams (reduce labels or reduce label values), or contact your Loki administrator to see if the limit can be increased
```

&nbsp;

loki의 rate limit 기본 설정은 다음과 같습니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    limits_config:
      ingestion_rate_mb: 4
      ingestion_burst_size_mb: 6
```

&nbsp;

기본값으로 운영하면 promtail이 로그를 보낼 때 간헐적으로 loki 서버에 의해 스로틀링이 걸릴 수 있습니다. 이 때 promtail에서 `429 Too Many Requests` 에러가 발생합니다. 다음과 같이 기본 20MB, burst size 30MB로 늘려서 운영하는 걸 권장합니다.

```yaml
# charts/loki-distributed/values.yaml
loki:
  config: |
    limits_config:
      ingestion_rate_mb: 20
      ingestion_burst_size_mb: 30
```

&nbsp;

Rate Limit 관련한 자세한 사항은 아래 2개 Loki 공식문서를 참고합니다.

- [Distributor](https://grafana.com/docs/loki/latest/get-started/components/#distributor)
- [Rate-Limit Errors](https://grafana.com/docs/loki/latest/operations/request-validation-rate-limits/#rate-limit-errors)

&nbsp;

## 참고자료

**Loki Official Blog**  
[The essential config settings you should use so you won’t drop logs in Loki](https://grafana.com/blog/2021/02/16/the-essential-config-settings-you-should-use-so-you-wont-drop-logs-in-loki/)

**Tistory Blog**  
[로그 시스템 Loki 도입을 위한 몇가지 운영 팁](https://nyyang.tistory.com/167)

**Charts**  
[loki-distributed](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed)
