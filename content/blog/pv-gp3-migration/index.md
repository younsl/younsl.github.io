---
title: "pv gp3 migration"
date: 2025-01-17T12:05:15+09:00
lastmod: 2025-01-17T12:05:15+09:00
slug: ""
description: "EKS 클러스터에서 gp2 타입의 PV를 gp3 타입으로 마이그레이션"
keywords: []
tags: ["aws", "eks"]
---

## 개요

EKS 클러스터에서 `gp2` 타입으로 생성된 PersistentVolume을 `gp3` 타입으로 마이그레이션하는 방법을 설명합니다.

&nbsp;

## 배경지식

### gp3 볼륨을 써야하는 이유

- `gp3` 타입의 볼륨을 사용하면 `gp2` 볼륨과 다르게 스토리지 크기를 늘리지 않고도 IOPS와 처리량(Throughput)을 독립적으로 프로비저닝할 수 있으므로 GB당 **최대 20% 비용**을 절감할 수 있습니다.
- `gp3`는 최대 16,000 IOPS에 1,000MB/s의 처리량을 제공합니다.
- `gp3`의 최고 성능은 `gp2` 볼륨의 최대 처리량보다 4배 빠릅니다.

자세한 사항은 [Amazon EBS 볼륨을 gp2에서 gp3으로 마이그레이션하고 최대 20% 비용 절감하기](https://aws.amazon.com/ko/blogs/korea/migrate-your-amazon-ebs-volumes-from-gp2-to-gp3-and-save-up-to-20-on-costs/) 블로그 포스트를 참고해주세요.

&nbsp;

## 환경

- EBS CSI Snapshot Controller v8.2.0

&nbsp;

## 준비사항

- EBS CSI Driver가 EKS 클러스터에 설치되어 있어야 합니다.

&nbsp;

## 작업 절차

### gp3 디폴트 설정

기본적으로 EKS 클러스터를 생성하면 `gp2` 타입의 스토리지 클래스가 디폴트로 설정됩니다. `gp3` 스토리지 클래스를 디폴트로 설정하면 앞으로 생성될 EBS 기반의 PV들이 모두 `gp3`로 일관성 있게 유지되도록 도와줍니다.

`gp2` 타입의 스토리지 클래스의 디폴트 설정을 해제합니다.

```bash
kubectl patch sc gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

&nbsp;

`gp3` 타입의 스토리지 클래스를 디폴트로 설정합니다.

```bash
kubectl patch sc gp3 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

&nbsp;

`kubectl` 명령어를 실행하면 다음과 같은 응답을 받아야 합니다.

```bash
storageclass.storage.k8s.io/gp3 patched
```

&nbsp;

`gp3` 타입의 스토리지 클래스가 디폴트로 설정되었는지 확인합니다. `(default)` 표시가 붙은 것을 확인할 수 있습니다.

```bash
$ kubectl get sc
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2             kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   true                   4y310d
gp3 (default)   ebs.csi.aws.com         Delete          WaitForFirstConsumer   true                   584d
```

&nbsp;

`gp3` 스토리지 클래스의 설정을 확인합니다. `storageclass.kubernetes.io/is-default-class` 필드가 `true`로 설정되어 있는 것을 확인할 수 있습니다.

```bash
kubectl get sc gp3 -o yaml
```

```yaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: gp3
parameters:
  type: gp3
  fsType: ext4
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

&nbsp;

### EBS CSI Snapshot Controller 설치

실제 gp2에서 gp3로 전환하는 작업은 EBS CSI Snapshot Controller가 수행합니다. 클러스터에 이 컨트롤러를 먼저 설치합니다.

&nbsp;

EBS CSI Snapshot에 필요한 Custom Resource를 설치합니다.

```bash
curl -s -O https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
curl -s -O https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
curl -s -O https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml

kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml
```

&nbsp;

총 3개의 Custom Resource가 설치되었습니다.

- `volumesnapshots` (Namespaced)
- `volumesnapshotclasses` (Cluster-scoped)
- `volumesnapshotcontents` (Cluster-scoped)

```bash
customresourcedefinition.apiextensions.k8s.io/volumesnapshots.snapshot.storage.k8s.io created
customresourcedefinition.apiextensions.k8s.io/volumesnapshotclasses.snapshot.storage.k8s.io created
customresourcedefinition.apiextensions.k8s.io/volumesnapshotcontents.snapshot.storage.k8s.io created
```

&nbsp;

`kubectl` 명령어를 사용해서 설치된 Custom Resource를 확인합니다.

```
kubectl api-resources --api-group snapshot.storage.k8s.io
```

```bash
NAME                     SHORTNAMES          APIVERSION                   NAMESPACED   KIND
volumesnapshotclasses    vsclass,vsclasses   snapshot.storage.k8s.io/v1   false        VolumeSnapshotClass
volumesnapshotcontents   vsc,vscs            snapshot.storage.k8s.io/v1   false        VolumeSnapshotContent
volumesnapshots          vs                  snapshot.storage.k8s.io/v1   true         VolumeSnapshot
```

&nbsp;

EBS CSI Snapshot Controller를 설치합니다. 기본적으로 `kube-system` 네임스페이스에 설치됩니다.

```bash
curl -s -O https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
curl -s -O https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
kubectl apply -f rbac-snapshot-controller.yaml,setup-snapshot-controller.yaml
```

&nbsp;

아래 쿠버네티스 리소스들이 설치되었습니다.

```
serviceaccount/snapshot-controller created
clusterrole.rbac.authorization.k8s.io/snapshot-controller-runner created
clusterrolebinding.rbac.authorization.k8s.io/snapshot-controller-role created
role.rbac.authorization.k8s.io/snapshot-controller-leaderelection created
rolebinding.rbac.authorization.k8s.io/snapshot-controller-leaderelection created
deployment.apps/snapshot-controller created
```

&nbsp;

EBS CSI Snapshot Controller가 정상적으로 설치되었는지 확인합니다.

```bash
kubectl get pod \
  -n kube-system \
  -l app.kubernetes.io/name=snapshot-controller
```

&nbsp;

기본적으로 고가용성을 위해 `snapshot-controller`는 2개의 파드로 구성되어 있습니다.

```bash
NAME                                   READY   STATUS    RESTARTS   AGE
snapshot-controller-668549b974-jj9s9   1/1     Running   0          4m9s
snapshot-controller-668549b974-tcbsq   1/1     Running   0          5m20s
```

&nbsp;

### EBS 볼륨 마이그레이션

`VolumeSnapshotContent` 리소스를 생성하기 위해서는 먼저 대상 볼륨의 ID를 알아야 합니다.

다음 `kubectl` 명령어를 사용해서 실제 PV를 구성하는 본체인 EBS 볼륨의 ID를 알아낼 수 있습니다. `PV_NAME`에는 `gp2` 타입을 `gp3`로 옮길 대상 PV의 이름인 `metadata.name` 필드 값을 입력합니다.

```bash
kubectl get pv [PV_NAME] -o jsonpath='{.spec.awsElasticBlockStore.volumeID}'
```

&nbsp;

`gp2`에서 `gp3`로 전환할 작업대상 PV 리소스를 찾습니다.

다음 명령어를 사용해서 EBS 볼륨의 ID를 알아낼 수 있습니다.

```bash
VID=$(kubectl get pv pvc-861e1a3d-6315-4624-8a11-d87535d18302 -o jsonpath='{.spec.awsElasticBlockStore.volumeID}')
echo $VID
```

&nbsp;

다음 명령어를 사용해서 대상 EBS 볼륨의 스냅샷을 생성합니다.

```bash
aws ec2 create-snapshot \
  --volume-id $VID \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key="ec2:ResourceTag/ebs.csi.aws.com/cluster",Value="true"}]'
```

EBS Snapshot 생성 시 `ec2:ResourceTag/ebs.csi.aws.com/cluster` 태그를 추가해야 나중에 EBS CSI Driver가 스냅샷과 볼륨을 삭제할 수 있습니다. 이 설정은 EBS CSI Driver가 사용하는 [AmazonEBSCSIDriverPolicy](https://docs.aws.amazon.com/ko_kr/aws-managed-policy/latest/reference/AmazonEBSCSIDriverPolicy.html) [관리형 정책](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#aws-managed-policies)과 연관이 있습니다.

&nbsp;

해당 AWS CLI를 실행하면 다음과 같은 응답을 받게 됩니다.

```json
{
    "Tags": [
        {
            "Key": "ec2:ResourceTag/ebs.csi.aws.com/cluster",
            "Value": "true"
        }
    ],
    "SnapshotId": "snap-<REDACTED>",
    "VolumeId": "vol-<REDACTED>",
    "State": "pending",
    "StartTime": "2025-01-16T08:54:04.990000+00:00",
    "Progress": "",
    "OwnerId": "111122223333",
    "Description": "",
    "VolumeSize": 10,
    "Encrypted": false
}
```

&nbsp;

생성한 EBS 스냅샷이 `completed` 상태가 될 때까지 기다립니다.

```bash
aws ec2 describe-snapshots \
  --snapshot-ids snap-[SNAPSHOT_ID]
```

```bash
{
    "Snapshots": [
        {
            ...
            "State": "completed",
            "StartTime": "2025-01-16T08:54:04.990000+00:00",
            "Progress": "100%",
            ...
        }
    ]
}
```

&nbsp;

이제 `VolumeSnapshotClass` 리소스를 생성합니다.

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: ebs-csi-aws
driver: ebs.csi.aws.com
deletionPolicy: Delete
EOF
```

```bash
volumesnapshotclass.snapshot.storage.k8s.io/ebs-csi-aws created
```

&nbsp;

`VolumeSnapshotClass` 리소스가 정상적으로 생성되었는지 확인합니다.

```bash
$ kubectl get volumesnapshotclass
NAME          DRIVER            DELETIONPOLICY   AGE
ebs-csi-aws   ebs.csi.aws.com   Delete           2m55s
```

&nbsp;

`VolumeSnapshotContent` 리소스를 생성합니다. `YOUR_SNAPSHOT_ID`에는 앞서 `aws ec2 create-snapshot` 명령어를 통해 생성한 스냅샷의 ID인 `SnapshotId` 필드 값을 입력합니다.

이 작업이 왜 필요한지 이해하기 어려워 보이겠지만, 기존 스냅샷에 대한 양방향(Bidirectional) 바인딩을 위해 필요합니다.

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotContent
metadata:
  name: imported-aws-snapshot-content
spec:
  # VolumeSnapshot 은 아직 만들지 않았지만 상관 없다. 다음 스탭에서 만들어도 괜찮습니다.
  volumeSnapshotRef:
    kind: VolumeSnapshot
    name: imported-aws-snapshot
    namespace: monitoring
  source:
    snapshotHandle: snap-[YOUR_SNAPSHOT_ID] # <-- snapshot ID to import
  driver: ebs.csi.aws.com
  deletionPolicy: Delete
  volumeSnapshotClassName: ebs-csi-aws
EOF
```

&nbsp;

`VolumeSnapshot` 리소스를 생성합니다.

1. `volumeSnapshotClassName`에는 앞서 생성한 `VolumeSnapshotClass` 리소스의 `metadata.name` 필드 값과 일치해야 합니다.
2. `volumeSnapshotContentName`에는 앞서 생성한 `VolumeSnapshotContent` 리소스의 `metadata.name` 필드 값과 일치해야 합니다.

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: imported-aws-snapshot
  namespace: monitoring
spec:
  # [1] Set volumeSnapshotClassName to VolumeSnapshotClass metadata.name
  volumeSnapshotClassName: ebs-csi-aws
  source:
    # [2] Set volumeSnapshotContentName to VolumeSnapshotContent metadata.name
    volumeSnapshotContentName: imported-aws-snapshot-content
EOF
```

&nbsp;

`VolumeSnapshot` 리소스가 정상적으로 생성되었는지 확인합니다.

```bash
$ kubectl get volumesnapshot -n monitoring
NAME                    READYTOUSE   SOURCEPVC   SOURCESNAPSHOTCONTENT           RESTORESIZE   SNAPSHOTCLASS   SNAPSHOTCONTENT                 CREATIONTIME   AGE
imported-aws-snapshot   true                     imported-aws-snapshot-content   10Gi          ebs-csi-aws     imported-aws-snapshot-content   42m            31m
```

&nbsp;

제 경우, Grafana의 PV를 gp2에서 gp3로 마이그레이션 하는 시나리오입니다. 기존의 PVC 설정을 백업합니다.

```bash
kubectl get pvc -n monitoring grafana -o yaml > grafana-pvc.yaml.bak
```

&nbsp;

PVC 교체:

파드의 PV는 PVC를 통해 접근합니다. 따라서 파드의 PV를 gp2에서 gp3로 교체하려면 PVC의 설정 정보도 업데이트하고 교체해야 합니다.

`gp2`를 쓰던 볼륨을 `gp3`로 교체하려면 Pod가 사용하고 있는 PVC 항목을 바꿔야 합니다. 제 경우, Helm 차트로 구성된 Grafana 파드의 볼륨을 `gp2`에서 `gp3`로 교체해야 했습니다.

PVC의 이름은 기존과 동일하게 `grafana`로 가져가야 했습니다.

> 기존에 이미 한 번 만들어진 PVC의 `spec` 필드는 수정할 수 없습니다.

```bash
kubectl scale deployment -n monitoring --replicas 0 grafana
kubectl delete pvc -n monitoring grafana
```

```bash
cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana
  namespace: monitoring
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp3
  dataSource:
    name: imported-aws-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
EOF
```

**중요**: `spec.dataSource.name` 필드에는 앞서 생성한 `VolumeSnapshot` 리소스의 이름을 입력합니다.

&nbsp;

`PersistentVolumeClaim` 리소스가 정상적으로 생성되었는지 확인합니다.

```bash
kubectl get pvc -n monitoring grafana -o yaml
```

&nbsp;

이후 다시 잠시 내려놓은 Grafana 파드를 다시 올립니다.

```bash
kubectl scale deployment -n monitoring --replicas 1 grafana
```

파드가 정상적으로 올라오면 PVC를 통해 새로운 `gp3` 타입의 PV가 연결(Bound)됩니다.

&nbsp;

PVC가 정상적으로 파드에 연결(Bound)되었는지 확인합니다.

```bash
$ kubectl get pvc -n monitoring grafana
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
grafana   Bound    pvc-cbd219d2-441f-4d19-b3ae-b4996bd4a1a8   10Gi       RWO            gp3            <unset>                 9m22s
```

&nbsp;

현재 PV 상태도 확인합니다. 과거에 사용하던 `gp2` 타입의 PV가 Released 상태로 남아 있는 것을 확인할 수 있습니다. `gp3` 타입의 PV는 현재 파드와 연결되어 Bound 상태입니다.

```bash
$ kubectl get pv | grep 'monitoring/grafana'
pvc-861e1a3d-6315-4624-8a11-d87535d18302   10Gi       RWO            Retain           Released   monitoring/grafana                                          gp2            <unset>                          449d
pvc-cbd219d2-441f-4d19-b3ae-b4996bd4a1a8   10Gi       RWO            Delete           Bound      monitoring/grafana                                          gp3            <unset>                          10m
```

서비스가 정상임을 확인한 후에는 과거에 사용하던 gp2 타입의 PV를 삭제하면 작업은 끝납니다.

&nbsp;

## 관련자료

- [EBS CSI Snapshot Controller](https://github.com/kubernetes-csi/external-snapshotter)
- [EBS CSI Snapshot Controller 문서](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/csi-snapshot-controller.html)
- [Migrating Amazon EKS clusters from gp2 to gp3 EBS volumes](https://aws.amazon.com/ko/blogs/containers/migrating-amazon-eks-clusters-from-gp2-to-gp3-ebs-volumes/): AWS Blog
- [Amazon EBS 볼륨을 gp2에서 gp3으로 마이그레이션하고 최대 20% 비용 절감하기](https://aws.amazon.com/ko/blogs/korea/migrate-your-amazon-ebs-volumes-from-gp2-to-gp3-and-save-up-to-20-on-costs/): AWS Blog
