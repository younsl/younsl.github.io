---
title: "AIX CPU 정보 및 전체 코어수 확인"
date: 2021-10-15T13:39:10+09:00
lastmod: 2023-08-12T14:26:15+09:00
slug: ""
description: "IBM AIX 운영체제에서 CPU 관련 상세정보를 확인하는 방법"
keywords: []
tags: ["os", "unix", "aix", "hardware"]
---

## 개요

IBM AIX 운영체제에서 CPU 관련 상세정보를 확인할 수 있다.

&nbsp;

이 글을 통해 확인 가능한 CPU 정보는 다음과 같습니다.

- CPU 제원정보 (모델명, Clock Speed 등)
- 물리 CPU 수
- 전체 물리코어 수
- 전체 논리코어 수

&nbsp;

## 환경

- **OS** : IBM AIX 7.2.0.0
- **Shell** : ksh

&nbsp;

## 전제조건

없음

&nbsp;

## TL;DR

**Too long; didn't read**  
시간이 없는 분들을 위해 핵심 명령어들만 요약한다.

```bash
# 1. CPU 소켓 확인
$ lscfg -vp | grep WAY
# 2. CPU 모델명 및 클럭 확인
$ prtconf | grep Processor
# 3. 물리코어, 논리코어 수 확인
$ smtctl
# 4. 물리코어 수 확인
$ lsdev -Cc processor
# 5. 논리코어 수 확인
$ bindprocessor -q
# 6. 전체 CPU 수 확인
$ lparstat -i
```

&nbsp;

## 확인방법

### 1. CPU 소켓 확인

```bash
$ lscfg -vp | grep WAY
      06-WAY PROC CUOD:
      06-WAY PROC CUOD:
```

- `06-WAY PROC CUOD:` : 각 1줄은 물리적 CPU 칩 1개를 의미한다. 결과값이 2줄이므로 해당 서버는 2개의 물리적 CPU 칩이 장착된 상태이다.
- `06-WAY` : CPU 1개당 코어수가 6개임을 의미한다.
- **전체 물리코어 수 계산** : 6 Core x 2 CPU = 12 Core

&nbsp;

### 2. CPU 모델명 및 클럭 확인

```bash
$ prtconf | grep Processor
Processor Type: PowerPC_POWER8
Processor Implementation Mode: POWER 8
Processor Version: PV_8_Compat
Number Of Processors: 2
Processor Clock Speed: 3891 MHz
  Model Implementation: Multiple Processor, PCI bus
+ proc0                                                                          Processor
+ proc8                                                                          Processor
```

#### 주요정보

- `Processor Type` : CPU 모델명
- `Number Of Processors` : 물리적인 CPU 소켓 수
- `Processor Clock Speed` : 해당 CPU의 Clock 속도

&nbsp;

### 3. 물리코어, 논리코어 수 확인

#### SMT 설정 확인

SMT<sup>Simultaneous Multi-Threading</sup>는 물리코어를 여러개의 Thread로 나누는 기술을 의미한다.  
SMT는 Intel의 HTT<sup>Hyper-Threading Technology</sup>와 비슷한 멀티스레딩 기술이다.

```bash
$ smtctl

This system is SMT capable.
This system supports up to 8 SMT threads per processor.
SMT is currently enabled.
SMT boot mode is not set.
SMT threads are bound to the same physical processor.

proc0 has 4 SMT threads.
Bind processor 0 is bound with proc0
Bind processor 1 is bound with proc0
Bind processor 2 is bound with proc0
Bind processor 3 is bound with proc0


proc8 has 4 SMT threads.
Bind processor 4 is bound with proc8
Bind processor 5 is bound with proc8
Bind processor 6 is bound with proc8
Bind processor 7 is bound with proc8
```

- 서버에서 SMT 기능을 사용중이다. (`SMT is currently enabled`)
- 물리코어 수 2개, 논리코어 수 8개

&nbsp;

#### 물리코어 수 확인

```bash
$ lsdev -Cc processor
proc0 Available 00-00 Processor
proc8 Available 00-08 Processor
```

- 물리코어는 총 2개이다. (proc0, proc8)
- 이 물리코어들이 SMT<sup>Simultaneous Multi-Threading</sup>로 인하여 다중의 논리코어<sup>Thread</sup>로 나뉜다.

&nbsp;

#### 논리코어 수 확인

```bash
$ bindprocessor -q
The available processors are:  0 1 2 3 4 5 6 7
```

- 논리코어는 총 8개이다. (Bind processor 0, 1, 2, 3, 4, 5, 6, 7)

&nbsp;

### 4. 전체 CPU 수 확인

`lparstat` 명령어는 LPAR<sup>Logical Partition</sup> 관련된 CPU 정보를 출력한다.

```bash
$ lparstat -i  
Node Name                                  : devserver
Partition Name                             : dev1
Partition Number                           : 1
Type                                       : Dedicated-SMT-4
Mode                                       : Capped
Entitled Capacity                          : 2.00
Partition Group-ID                         : 32769
Shared Pool ID                             : -
Online Virtual CPUs                        : 2
Maximum Virtual CPUs                       : 12
Minimum Virtual CPUs                       : 1
Online Memory                              : 61696 MB
Maximum Memory                             : 61696 MB
Minimum Memory                             : 30720 MB
Variable Capacity Weight                   : -
Minimum Capacity                           : 1.00
Maximum Capacity                           : 12.00
Capacity Increment                         : 1.00
Maximum Physical CPUs in system            : 12
Active Physical CPUs in system             : 12
Active CPUs in Pool                        : -
Shared Physical CPUs in system             : 0
Maximum Capacity of Pool                   : 0
Entitled Capacity of Pool                  : 0
Unallocated Capacity                       : -
Physical CPU Percentage                    : 100.00%
Unallocated Weight                         : -
Memory Mode                                : Dedicated
Total I/O Memory Entitlement               : -
Variable Memory Capacity Weight            : -
Memory Pool ID                             : -
Physical Memory in the Pool                : -
Hypervisor Page Size                       : -
Unallocated Variable Memory Capacity Weight: -
Unallocated I/O Memory entitlement         : -
Memory Group ID of LPAR                    : -
Desired Virtual CPUs                       : 2
Desired Memory                             : 61696 MB
Desired Variable Capacity Weight           : -
Desired Capacity                           : 2.00
Target Memory Expansion Factor             : -
Target Memory Expansion Size               : -
Power Saving Mode                          : Disabled
Sub Processor Mode                         : -
```

`Online Virtual CPUs` 값을 주목해보자.

&nbsp;

```bash
$ lparstat -i  
...
Online Virtual CPUs                        : 2
Maximum Virtual CPUs                       : 12
```

IBM AIX 전용 HMC<sup>Hardware Management Console</sup>을 이용해 전체 12코어(`Maximum Virtual CPUs`)중 2코어(`Online Virtual CPUs`)만 활성화했기 때문에, `Online Virtual CPUs` 값이 2이다.
