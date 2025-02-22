---
title: "리눅스 메인보드 메모리 슬롯 확인"
date: 2021-09-29T19:28:30+09:00
lastmod: 2022-09-03T17:30:33+09:00
slug: ""
description: "리눅스 서버에서 메인보드의 메모리 슬롯 정보를 확인하는 방법"
keywords: []
tags: ["os", "linux", "hardware"]
---

## 개요

리눅스 서버에서 명령어<sup>Command</sup>를 이용해 메인보드의 메모리 슬롯 정보를 확인할 수 있다.

&nbsp;

### 확인 가능한 핵심 정보

- 전체 메모리 슬롯 개수
- 사용중인 메모리 슬롯 개수
- 증설 가능한 최대 메모리 용량
- 메모리 제원정보 (Part Number, 규격, 사이즈, 제조사 등)

&nbsp;

## 환경

- **OS** : CentOS Linux release 7.6.1810 (Core)
- **Shell** : bash
- **Package** : dmidecode 3.1

&nbsp;

## 전제조건

dmidecode 패키지가 이미 설치되어 있는 리눅스 시스템

&nbsp;

## 작업절차

### 1. dmidecode 패키지 확인

패키지 관리자인 <abbr title="RPM Package Manager">RPM</abbr>을 사용해서 dmidecode 패키지가 설치되어 있는지 확인한다.

```bash
$ rpm -qa | grep dmidecode
dmidecode-3.1-2.el7.x86_64
```

현재 서버에는 dmidecode 패키지 `3.1-2` 버전이 설치된 상태이다.

&nbsp;

### 2. 서버 메모리 확인

```bash
$ free -m
              total        used        free      shared  buff/cache   available
Mem:          31670        2020         237         310       29412       28841
Swap:         32767           2       32765
```

`-m`은 메모리 용량을 MB<sup>Megabytes</sup> 단위로 출력한다.  
서버의 전체 메모리 용량은 32GB이다.

&nbsp;

### 3. 메인보드 메모리 슬롯 확인 (간단히)

메인보드의 메모리 슬롯 정보를 간단하게 확인한다.

```bash
$ dmidecode -t 17 | egrep 'Memory|Size'
```

&nbsp;

명령어 실행 결과는 다음과 같다.

```bash
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: 16384 MB
Memory Device
        Size: No Module Installed
Memory Device
        Size: 16384 MB
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
Memory Device
        Size: No Module Installed
```

전체 24개 메모리 슬롯중 2개 메모리 슬롯을 사용중이다. 16GB 용량의 메모리 2개가 장착된 상태이다.  
`No Module Installed` 는 빈 메모리 슬롯을 의미한다.

&nbsp;

#### Tip. dmidecode -t 뒤의 숫자 의미

`-t` 옵션 뒤의 숫자는 Type Number 를 의미한다.  
Type Number 값만 다르게 주면 메모리 뿐만 아니라 다양한 정보를 얻을 수 있다.  
dmidecode의 Type Number 목록은  `man dmidecode` 명령어로 확인할 수 있다.  

```bash
$ man dmidecode
...
DMI TYPES
       The SMBIOS specification defines the following DMI types:

       Type   Information
       ────────────────────────────────────────────
          0   BIOS
          1   System
          2   Baseboard
          3   Chassis
          4   Processor
          5   Memory Controller
          6   Memory Module
          7   Cache
          8   Port Connector
          9   System Slots
         10   On Board Devices
         11   OEM Strings
         12   System Configuration Options
         13   BIOS Language
         14   Group Associations
         15   System Event Log
         16   Physical Memory Array
         17   Memory Device
         18   32-bit Memory Error
         19   Memory Array Mapped Address
         20   Memory Device Mapped Address
         21   Built-in Pointing Device
         22   Portable Battery
         23   System Reset
         24   Hardware Security
         25   System Power Controls
         26   Voltage Probe
         27   Cooling Device
         28   Temperature Probe
         29   Electrical Current Probe
         30   Out-of-band Remote Access
         31   Boot Integrity Services
         32   System Boot
         33   64-bit Memory Error
         34   Management Device

         35   Management Device Component
         36   Management Device Threshold Data
         37   Memory Channel
         38   IPMI Device
         39   Power Supply
         40   Additional Information
         41   Onboard Devices Extended Information
         42   Management Controller Host Interface
```

&nbsp;

#### 메모리 슬롯 정보 확인시 자주 사용하는 Type Number

| Type | Information           | Command to run    |
|------|-----------------------|-------------------|
| 16   | Physical Memory Array | `dmidecode -t 16` |
| 17   | Memory Device         | `dmidecode -t 17` |

&nbsp;

### 4. 메인보드 메모리 슬롯 확인 (자세히)

메인보드의 메모리 슬롯 정보를 자세하게 확인한다.

```bash
$ dmidecode -t 17
```

&nbsp;

명령어 실행 결과는 다음과 같다.

```bash
# dmidecode 3.1
Getting SMBIOS data from sysfs.
SMBIOS 3.2.1 present.
# SMBIOS implementations newer than version 3.1.1 are not
# fully supported by this version of dmidecode.

Handle 0x001B, DMI type 17, 84 bytes
Memory Device
        Array Handle: 0x000F
        Error Information Handle: Not Provided
        Total Width: 72 bits
        Data Width: 64 bits
        Size: No Module Installed
        Form Factor: DIMM
        Set: None
        Locator: PROC 1 DIMM 1
        Bank Locator: Not Specified
        Type: Other
        Type Detail: Synchronous
        Speed: Unknown
        Manufacturer: UNKNOWN
        Serial Number: Not Specified
        Asset Tag: Not Specified
        Part Number: NOT AVAILABLE
        Rank: Unknown
        Configured Clock Speed: Unknown
        Minimum Voltage: Unknown
        Maximum Voltage: Unknown
        Configured Voltage: Unknown

...

Handle 0x0022, DMI type 17, 84 bytes
Memory Device
        Array Handle: 0x000F
        Error Information Handle: Not Provided
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 16384 MB
        Form Factor: DIMM
        Set: 7
        Locator: PROC 1 DIMM 8
        Bank Locator: Not Specified
        Type: DDR4
        Type Detail: Synchronous Registered (Buffered)
        Speed: 2933 MT/s
        Manufacturer: HPE
        Serial Number: Not Specified
        Asset Tag: Not Specified
        Part Number: P03050-091
        Rank: 2
        Configured Clock Speed: 2400 MT/s
        Minimum Voltage: 1.2 V
        Maximum Voltage: 1.2 V
        Configured Voltage: 1.2 V

...

Handle 0x0024, DMI type 17, 84 bytes
Memory Device
        Array Handle: 0x000F
        Error Information Handle: Not Provided
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 16384 MB
        Form Factor: DIMM
        Set: 9
        Locator: PROC 1 DIMM 10
        Bank Locator: Not Specified
        Type: DDR4
        Type Detail: Synchronous Registered (Buffered)
        Speed: 2933 MT/s
        Manufacturer: HPE
        Serial Number: Not Specified
        Asset Tag: Not Specified
        Part Number: P03051-091
        Rank: 1
        Configured Clock Speed: 2400 MT/s
        Minimum Voltage: 1.2 V
        Maximum Voltage: 1.2 V
        Configured Voltage: 1.2 V

...
```

메모리의 Part Number, 용량(Size), 폼팩터, 규격, 설정된 Clock 등의 유용한 정보를 얻을 수 있다.

&nbsp;

### 5. 메인보드가 최대 지원하는 메모리 용량 확인

```bash
$ dmidecode -t 16
# dmidecode 3.1
Getting SMBIOS data from sysfs.
SMBIOS 3.2.1 present.
# SMBIOS implementations newer than version 3.1.1 are not
# fully supported by this version of dmidecode.

Handle 0x000F, DMI type 16, 23 bytes
Physical Memory Array
        Location: System Board Or Motherboard
        Use: System Memory
        Error Correction Type: Multi-bit ECC
        Maximum Capacity: 3 TB
        Error Information Handle: Not Provided
        Number Of Devices: 12

Handle 0x0010, DMI type 16, 23 bytes
Physical Memory Array
        Location: System Board Or Motherboard
        Use: System Memory
        Error Correction Type: Multi-bit ECC
        Maximum Capacity: 3 TB
        Error Information Handle: Not Provided
        Number Of Devices: 12
```

해당 서버는 총 2개의 Memory Array로 구성되어 있다.  

각 Memory Array 당 지원하는 최대 메모리 용량(`Maximum Capacity`)은 3TB이다.  
각 Memory Array 당 전체 메모리 슬롯(`Number of Devices`)은 12개이다.

Memory Array가 총 2개이므로, 서버 전체에 꽂을 수 있는 최대 메모리 용량은 6TB, 메모리 슬롯은 총 24개이다.

&nbsp;

이상으로 메모리 구성정보 확인 절차를 마친다.

&nbsp;

## 결론

서버 관리자에게 가장 중요한 업무는 서버의 네트워크 구성과 서비스 흐름 정보, 제원<sup>Spec</sup>을 제대로 파악하는 일이다.  

`dmidecode`는 다양한 하드웨어 정보를 수집할 수 있는 유용한 명령어이다.  
실무에서 잘 활용만 한다면 보다 더 많은 하드웨어 정보를 수집할 수 있다는 사실을 명심하도록 하자.
