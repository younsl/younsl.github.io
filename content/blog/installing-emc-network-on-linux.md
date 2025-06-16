---
title: "리눅스에서 EMC Networker 에이전트 설치"
date: 2021-07-31T14:39:52+09:00
lastmod: 2023-04-25T04:34:35+09:00
slug: ""
description: "리눅스 서버에 EMC Networker 백업 에이전트를 설치하는 방법"
keywords: []
tags: ["linux", "os"]
---

## 개요

EMC Networker 솔루션을 통해 백업을 받기 위해 백업 에이전트를 설치합니다.

EMC Networker를 사용하는 경우 백업 대상 리눅스 노드에 lgtoclnt와 lgtoxtdclnt 패키지를 모두 설치해야 합니다.

&nbsp;

## 환경

- **OS** : Red Hat Enterprise Linux release 6.5
- **Shell** : bash
- **CPU 아키텍처** : x86_64

&nbsp;

## 배경지식

### EMC Networker 관련 패키지

[EMC Networker](https://en.wikipedia.org/wiki/EMC_NetWorker)는 데이터 백업과 복구 솔루션입니다. lgtoclnt와 lgtoxtdclnt 패키지는 Networker 클라이언트 소프트웨어입니다.  
여기서 lgto는 Legato를 의미합니다. Legato는 EMC Corporation의 소프트웨어 브랜드 중 하나이며, Legato NetWorker는 데이터 백업 및 복구 솔루션으로 알려져 있습니다.

- **lgtoclnt** (Legato Client) : 일반적인 Networker 클라이언트 소프트웨어입니다. 이 패키지는 Windows, Linux, Unix, Mac OS X 등 다양한 플랫폼에서 실행할 수 있습니다. 이 패키지는 특정 클라이언트에서 데이터를 백업하고 복구하기 위해 설치됩니다.
- **lgtoxtdclnt** (Legato Extended Client) : Networker 클라이언트 소프트웨어의 확장 버전입니다. 이 패키지는 특정 데이터베이스, 이메일, 그리고 다른 애플리케이션 등 특정 애플리케이션에서 데이터를 백업하고 복구하기 위해 설치됩니다. 예를 들어, Oracle 데이터베이스에서 데이터를 백업하려면, 해당 클라이언트에 lgtoxtdclnt 패키지를 설치해야 합니다.

요약하자면 lgtoclnt는 일반적인 Networker 클라이언트 소프트웨어이며, lgtoxtdclnt는 특정 애플리케이션에서 데이터를 백업하고 복구하기 위한 확장 패키지입니다.

&nbsp;

## 설치방법

### 1. rpm 설치파일 업로드

SFTP를 사용해서 rpm 설치파일을 업로드합니다.

```bash
$ ls
lgtoclnt-18.2.0.5-1.x86_64.rpm  lgtoxtdclnt-18.2.0.5-1.x86_64.rpm
```

&nbsp;

### 2. 패키지 설치

반드시 `lgtoclnt` 를 먼저 설치후, `lgtoxtdclnt` 를 설치해야 정상적으로 완료됩니다.

&nbsp;

#### lgtoclnt 패키지 설치

```bash
$ rpm -ivh lgtoclnt-18.2.0.5-1.x86_64.rpm 
warning: lgtoclnt-18.2.0.5-1.x86_64.rpm: Header V3 RSA/SHA1 Signature, key ID c5dfe03d: NOKEY
Preparing...                ########################################### [100%]
   1:lgtoclnt               ########################################### [100%]
```

`lgtoclnt` (Legato Client) 패키지 설치가 정상적으로 완료되었습니다.

&nbsp;

#### lgtoxtdclnt 패키지 설치

```bash
$ rpm -ivh lgtoxtdclnt-18.2.0.5-1.x86_64.rpm
warning: lgtoxtdclnt-18.2.0.5-1.x86_64.rpm: Header V3 RSA/SHA1 Signature, key ID c5dfe03d: NOKEY
Preparing...                ########################################### [100%]
   1:lgtoxtdclnt            ########################################### [100%]
```

`lgtoxtdclnt` (Legato Extended Client) 패키지 설치가 정상적으로 완료되었습니다.  

&nbsp;

### 3. 호스트 파일 수정

`/etc/hosts` 파일에 추가할 내용은 다음과 같습니다.

- 백업 관리서버의 IP 주소, Hostname
- 자기 자신의 IP 주소, Hostname

```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

...

### EMC NETWORKER ###
1.1.1.1  testserver1
2.2.2.2  BACKUP_MANAGEMENT_SERVER_HOSTNAME
```

&nbsp;

### 4. NetWorker 서비스 시작

```bash
$ service networker start
```

&nbsp;

### 5. NetWorker 프로세스 확인

```bash
$ ps -ef | grep nsr
root     53433     1  0 13:14 ?        00:00:00 /usr/sbin/nsrexecd
```

NetWorker 데몬인  `nsrexecd` 프로세스가 구동중입니다.

&nbsp;

이것으로 Networker Agent 설치 작업이 완료됩니다.
