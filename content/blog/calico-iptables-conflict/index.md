---
title: "calico iptables conflict"
date: 2025-06-17T15:38:15+09:00
lastmod: 2025-06-17T23:09:25+09:00
slug: ""
description: "iptables confliction between calico and kube-proxy"
keywords: []
tags: []
---

## 개요

최근 2주간 쿠버네티스 클러스터의 불특정 노드에서 발생한 네트워킹 이슈에 대해 분석하느라 많은 시간을 보냈습니다.

해당 인시던트에 대한 트러블슈팅 기록입니다.

## 환경

- Calico
  - calico/node:v3.28.1
  - tigera/operator:v1.34.3
- Calico dataplane
  - iptables 1.8.8 (legacy mode)
  - Pod IPAM은 VPC CNI에 의해 관리중
- Orchestrator version: EKS 1.32
- Operating System and version: Amazon Linux 2 v20250519, amd64

## 증상

증상은 이틀간 잘 동작하던 노드 1대가 iptables가 고장나면서 파드간 통신과 파드 to RDS 통신 등 해당 노드에 올라가있는 파드들이 모두 CrashLoopBackOff 상태에 빠지며 kube-apiserver와 타임아웃이 발생하는 것이었습니다.

독특한 점은 70대 노드 중 꼭 한 대의 불특정 노드만 (이틀간 잘 동작하다가) iptables 손상 장애가 갑자기 발생한다는 것입니다.

Workload pod의 timeout:

```bash
# In debugger container (image: netshoot)
$ nc -zv 172.20.0.1 443
nc: connect to 172.20.0.1 port 443 (tcp) failed: Operation timed out

$ curl -k https://172.20.0.1:443/healthz --connect-timeout 5
curl: (28) Failed to connect to 172.20.0.1 port 443 after 4093 ms: Couldn't connect to server
```

kube-proxy의 iptables 에러 로그가 무한정 반복됩니다:

```bash
E0610 07:32:16.910840       1 proxier.go:1564] "Failed to execute iptables-restore" err=
    exit status 2: Ignoring deprecated --wait-interval option.
    iptables-restore v1.8.8 (legacy): Couldn't load target `KUBE-SVC-UOLAULR5MHUYULMB':No such file or directory
    Error occurred at line: 177
    Try `iptables-restore -h' or 'iptables-restore --help' for more information.
 > ipFamily="IPv4"
I0610 07:32:16.910860       1 proxier.go:833] "Sync failed" ipFamily="IPv4" retryingTime="30s"
I0610 07:32:16.910871       1 proxier.go:822] "SyncProxyRules complete" ipFamily="IPv4" elapsed="8.063544ms"
I0610 07:32:18.449102       1 proxier.go:828] "Syncing iptables rules" ipFamily="IPv4"
I0610 07:32:18.500617       1 proxier.go:1547] "Reloading service iptables data" ipFamily="IPv4" numServices=343 numEndpoints=481 numFilterChains=6 numFilterRu
I0610 07:32:18.518037       1 proxier.go:822] "SyncProxyRules complete" ipFamily="IPv4" elapsed="69.273194ms"
I0610 07:32:22.917050       1 proxier.go:828] "Syncing iptables rules" ipFamily="IPv4"
I0610 07:32:22.923749       1 proxier.go:1547] "Reloading service iptables data" ipFamily="IPv4" numServices=343 numEndpoints=481 numFilterChains=6 numFilterRu
E0610 07:32:22.926611       1 proxier.go:1564] "Failed to execute iptables-restore" err=
    exit status 2: Ignoring deprecated --wait-interval option.
    iptables-restore v1.8.8 (legacy): Couldn't load target `KUBE-SVC-3KK4EHREJABVV2YJ':No such file or directory
    Error occurred at line: 105
    Try `iptables-restore -h' or 'iptables-restore --help' for more information.
 > ipFamily="IPv4"
```

## 원인

### kube-proxy와 calico-node의 iptables 경합

문제가 발생한 클러스터에서는 felixconfiguration에 의해 calico가 BPF 모드로 동작하고 있었습니다. kube-proxy와 calico-node 둘 다 iptables 모드를 자동감지하도록 Auto detection 모드로 동작하고 있었으며, 실제로 calico-node도 iptables-legacy를 자동 감지했습니다. calico는 BGP 모드 활성화에 의해 kube-proxy가 주기적으로 생성한 iptables 체인들을 정리(cleanup)했고, 이로 인해 노드의 네트워킹 장애가 발생했습니다.

```mermaid
---
title: Calico BPF vs kube-proxy iptables Conflict Mechanism
---
flowchart LR
  subgraph k8s["Kubernetes Cluster"]
    subgraph node["Worker Node"]
        ipt["`iptables (legacy)
        *conflicted*`"]
        c["`**DaemonSet Pod**
        calico-node`"]
        f["`**CR**
        felixconfiguration`"]
        p["`**DaemonSet Pod**
        kube-proxy`"]

        p --Create iptables chains--> ipt
        c --Dynamic fetch--> f
        c --Cleanup iptables--> ipt
    end
  end

  style ipt fill:darkorange, color:white
```

문제가 발생했던 felixconfiguration 리소스 정보입니다. BGP 모드(bpfEnabled)가 켜져 있는 걸 확인할 수 있습니다.

```yaml
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  annotations:
    operator.tigera.io/bpfEnabled: "false"
  name: default
spec:
  bpfConnectTimeLoadBalancing: TCP
  bpfEnabled: true
  bpfHostNetworkedNATWithoutCTLB: Enabled
  bpfLogLevel: ""
  floatingIPs: Disabled
  healthPort: 9099
  logSeverityScreen: Error
  reportingInterval: 0s
  routeTableRange:
    max: 99
    min: 65
  vxlanVNI: 4096
```

## 해결방법

calico-node의 증상 파악 및 세부 로그를 확인하기 위해 BPF 로그와 일반 로그를 모두 Debug 레벨로 켭니다. 제 경우는 문제가 발생한 클러스터의 Calico에만 BPF 모드가 켜져있었습니다.

```bash
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  annotations:
    operator.tigera.io/bpfEnabled: "false"
  name: default
spec:
  bpfConnectTimeLoadBalancing: TCP
  bpfEnabled: true
  bpfLogLevel: Debug
  # ... omitted ...
  logSeverityScreen: Debug
```

### iptable cleanup 비활성화

Calico 공식문서 [Avoiding conflicts with kube-proxy](https://docs.tigera.io/calico/latest/operations/ebpf/enabling-ebpf#avoiding-conflicts-with-kube-proxy)에 의하면, kube-proxy 데몬셋을 비활성화할 수 없는 경우(예: 쿠버네티스 배포판에서 관리되는 경우), felixconfiguration의 매개변수 BPFKubeProxyIptablesCleanupEnabled를 false로 변경해야 합니다.

tigera operator로 calico를 설치한 경우, felixconfiguration을 수정하더라도 오퍼레이터가 installation 리소스 기준으로 다시 맞춰서 설정이 롤백됩니다.

```mermaid
---
title: Calico configuration
---
flowchart LR
  to["tigera-operator"]
  in["installation"]
  fe["felixconfiguration"]

  to --> in --> fe
```

installation 리소스에서 bgp 설정을 비활성화 해야합니다.

```yaml
# installation
spec:
  calicoNetwork:
    bgp: Disabled
    linuxDataplane: Iptables # Or BGP
```

만약 kube-proxy를 삭제 가능한 쿠버네티스 배포판이라고 하면 이 설정을 사용하기 보다는 [kube-proxy를 삭제](https://docs.tigera.io/calico/latest/operations/ebpf/enabling-ebpf#configure-kube-proxy)하고 BPF 모드의 Calico로 클러스터 네트워킹을 구성하는 것이 더 나은 선택지입니다. ([메인테이너 답변](https://github.com/projectcalico/calico/issues/10538#issuecomment-2982099838))

kubectl을 사용하여 다음과 같이 변경할 수 있습니다. BPFKubeProxyIptablesCleanupEnabled의 기본값은 true 입니다.

```bash
kubectl patch felixconfiguration default --patch='{"spec": {"bpfKubeProxyIptablesCleanupEnabled": false}}'
```

felixconfiguration CRD 스키마에 따르면, bpfKubeProxyIptablesCleanupEnabled 설정은 kube-proxy가 실행 중이 아닐 때만 활성화해야 합니다. 이 설정은 BPF 모드에서 kube-proxy의 iptables 체인을 사전에 정리합니다.

```yaml
# felixconfigurations-crd.yaml
              bpfKubeProxyIptablesCleanupEnabled:
                description: 'BPFKubeProxyIptablesCleanupEnabled, if enabled in BPF
                  mode, Felix will proactively clean up the upstream Kubernetes kube-proxy''s
                  iptables chains.  Should only be enabled if kube-proxy is not running.  [Default:
                  true]'
```

bpfEnabled: true에 bpfKubeProxyIptablesCleanupEnabled: false로 iptables cleanup 동작이 비활성화되어 있습니다.

```yaml
# felixconfig resource
spec:
  bpfConnectTimeLoadBalancing: TCP
  # If you set bpfEnabled to true in calico with kube-proxy
  # must disable bpfKubeProxyIptablesCleanupEnabled value
  bpfEnabled: true
  bpfHostNetworkedNATWithoutCTLB: Enabled
  bpfKubeProxyIptablesCleanupEnabled: false 
  bpfLogLevel: Debug
  floatingIPs: Disabled
  healthPort: 9099
  logSeverityScreen: Debug
  reportingInterval: 0s
  routeTableRange:
    max: 99
    min: 65
  vxlanVNI: 4096
```

### BPF 모드 끄기

혹은 felixconfiguration 리소스에 선언된 Calico의 BPF 모드(bpfEnabled)를 끄면 됩니다.

```bash
# felixconfig
spec:
  bpfEnabled: false
```

bpfKubeProxyIptablesCleanupEnabled 설정을 비활성화한 시점부터 kube-proxy의 iptables-restore 에러 로그가 멈춘 걸 확인할 수 있습니다. 

```bash
iptables-restore v1.8.8 (legacy): Couldn't load target `KUBE-SVC-3KK4EHREJABVV2YJ':No such file or directory
```

이는 iptables cleanup 기능을 비활성화하여 Calico BPF 모드와 kube-proxy 간의 충돌이 해결되었음을 확인합니다. 이는 kube-proxy와 calico 간의 iptables 제어 충돌로 인해 눈송이 클러스터(각 노드마다 미묘하게 다른 설정이나 상태를 가진 일관성 없는 클러스터)에서 발생하는 네트워킹 문제입니다.

1. Calico 설정(felixconfig)에서 BPF 모드(bpfEnabled) 자체를 비활성화하거나
2. Calico BPF 모드를 사용해야 하는 경우, kube-proxy를 삭제합니다. kube-proxy를 삭제할 수 없는 쿠버네티스 배포판이라면 Calico의 BPF 모드를 켠 상태에서 iptables cleanup 동작을 비활성화하면 kube-proxy와의 iptables 경합에 의한 손상 문제를 해결할 수 있습니다. 다시 강조하지만 iptables cleanup 비활성화 설정은 kube-proxy를 삭제할 수 없을 때에만 사용해야 하는 선택지입니다.

## 마치며

BPF 모드에서 Calico는 기본적으로 kube-proxy의 iptables 규칙을 적극적으로 삭제(cleanup)하는데, 이로 인해 kube-proxy가 규칙을 다시 복원하려다가 "No such file or directory" 에러가 발생하는 무한 루프가 반복되면서 네트워킹 장애가 발생했습니다.
 
해결방법은 크게 2가지가 있습니다.

- Calico를 BPF 모드로 켜고 kube-proxy를 삭제합니다. **kube-proxy를 삭제할 수 없는 특수한 경우**에만 bpfKubeProxyIptablesCleanupEnabled: false 설정을 통해 iptables를 삭제(cleanup)하지 못하게 조치합니다.
- Calico의 BPF 모드를 끕니다. Calico는 BPF 모드를 끄면 iptables cleanup을 멈춥니다.

지속적으로 발생하던 kube-proxy iptables 에러 로그를 문제 원인에서 배제한 것이 큰 실책이었습니다.

## 관련자료

Github Issue:
- [calico-node stuck in Not-ready state due to kube-apiserver connectivity timeout #10538](https://github.com/projectcalico/calico/issues/10538#issuecomment-2979312107)

Calico docs:

- [Avoiding conflicts with kube-proxy](https://docs.tigera.io/calico/latest/operations/ebpf/enabling-ebpf#avoiding-conflicts-with-kube-proxy) 
