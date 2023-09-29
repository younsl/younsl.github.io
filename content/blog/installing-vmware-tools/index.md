---
title: "VMware Tools 설치"
date: 2021-08-30T00:54:12+09:00
lastmod: 2023-09-30T01:00:20+09:00
slug: ""
description: "가상머신에 VMware Tools를 설치하여 원활하게 시스템 운영하기"
keywords: []
tags: ["os", "linux", "vmware"]
---

## 개요

가상머신에 [VMware Tools](https://docs.vmware.com/kr/VMware-Tools/11.1.0/com.vmware.vsphere.vmwaretools.doc/GUID-28C39A00-743B-4222-B697-6632E94A8E72.html)를 설치할 수 있다.

&nbsp;

## 배경지식

### VMware Tools

가상 머신에 설치된 게스트(Guest) 운영체제의 성능과 가상 머신의 관리 기능을 향상시키기 위한 소프트웨어 집합이다.  

VMware Tools 데몬은 가상머신의 IP, Hostname 등의 정보를 수집해 가상화 관리 프로그램(vSphere Client)에 표출해준다.  

원활한 가상화 시스템 운영을 위해서 모든 가상머신에 VMware Tools를 설치가 필요하다.

&nbsp;

## 환경

- **ESXi** : ESXi 5.x
- **vSphere Client 관리자 계정**에 로그인되어 있어야 함
- **가상머신의 ID** : root
- **가상머신의 Shell** : bash

&nbsp;

## 작업절차

### 1. root 로그인

VMware Tools 설치 작업은 root 계정으로만 가능하다. 가상머신에 접속 후 root 계정에 로그인한다.

```bash
$ su -
Password: [패스워드 입력]
#
```

&nbsp;

### 2. VMware Tools 설치 / 업그레이드 버튼 클릭

vSphere Client 접속 → '가상머신' 오른쪽 마우스 클릭 → 'VMware Tools 설치 / 업그레이드' 버튼 클릭

&nbsp;

### 3. 리눅스 서버에 CD-ROM mount

```bash
# mount /dev/cdrom /mnt
mount: block device /dev/sr0 is write-protected, mounting read-only
```

&nbsp;

### 4. VMware Tools 설치파일 복사

CD-ROM 을 mount한 경로인 `/mnt` 로 이동한다.

```bash
# cd /mnt
# ls
VMwareTools-9.0.10-1481436.tar.gz  manifest.txt
```

&nbsp;

`VMwareTools-9.0.10-1481436.tar.gz` 파일을 `/tmp` 로 복사한다.

```bash
# cp VMwareTools-9.0.10-1481436.tar.gz /tmp
```

&nbsp;

### 5. VMware Tools 설치파일 압축해제

```bash
# tar -zxvf VMwareTools-9.0.10-1481436.tar.gz
[...]
vmware-tools-distrib/etc/scripts/vmware/
vmware-tools-distrib/etc/scripts/vmware/network
```

&nbsp;

### 6. VMware Tools 설치

VMware Tools 설치시 방법은 2가지가 있다.

- 기본 설정값(Default) 설치
- 커스텀 설치

각자 환경에 맞게 설치한다. 특별한 경우가 아니라면, 일반적으로 기본 설정값 설치를 해도 모니터링 및 정보수집 기능에 전혀 문제없다.

&nbsp;

#### 방법1. 기본 설정값(Default) 설치

```bash
# cd /tmp/vmware-tools-distrib/
# ls
FILES  INSTALL  bin  doc  etc  installer  lib  vmware-install.pi
# ./vmware-install.pi -default
```

VMware Tools를 기본 설정값(`-default`)으로 설치한다.

&nbsp;

#### 방법2. 커스텀 설치

```bash
# cd /tmp/vmware-tools-distrib/
# ls
FILES  INSTALL  bin  doc  etc  installer  lib  vmware-install.pi
# ./vmware-install.pi
```

설치 과정에서 여러가지 설치환경 값들을 물어보는데, 모두 엔터를 눌러 Default 값으로 설정하거나, 변경을 원하는 설정값이 있으면 변경해서 입력하면 된다.

&nbsp;

VMware Tools가 정상적으로 설치됐을 때 마지막 메세지.

```bash
...
Enjoy,

--the VMware team

Found VMware Tools CDROM mounted at /mnt. Ejecting device /dev/sr0 ...
```

&nbsp;

### 7. VMware Tools 동작여부 확인

```bash
# ps -ef | grep vmtoolsd
root    19777   1  0 13:17  ?      00:00:00 /usr/sbin/vmtoolsd
```

VMware Tools 데몬(`vmtoolsd`)이 정상 실행중인 걸 확인한다.

&nbsp;

```bash
# vmtoolsd -v
VMware Tools daemon, version 9.0.10.29005 (build-1481436)
```

VMware Tools 데몬이 버전 정보를 정상 반환하는 거 확인.

&nbsp;

이제 VMware Tools 에이전트 설치 및 구성 작업이 완료되었습니다.

&nbsp;

## 참고자료

[VMware Tools 설치](https://docs.vmware.com/kr/VMware-Tools/11.3.0/com.vmware.vsphere.vmwaretools.doc/GUID-D8892B15-73A5-4FCE-AB7D-56C2C90BD951.html)  
위 링크는 VMware 공식문서로 한국어로 친절하게 작성된 가이드다.  
위 내용도 같이 참조하면 문제 해결에 도움이 된다.
