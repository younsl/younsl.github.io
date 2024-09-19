---
title: "ipmitool 명령어로 HP iLO IP 확인"
date: 2021-10-13T23:34:15+09:00
lastmod: 2022-08-30T14:43:15+09:00
slug: ""
description: "CLI 환경에서 iLO IP를 확인하는 방법"
keywords: []
tags: ["os", "linux", "hardware"]
---

## 개요

CLI 환경에서 `ipmitool` 명령어를 사용하면 HP iLO IP 주소를 원격으로 확인할 수 있습니다.

서버에 `ipmitool`만 설치되어 있다면 HP iLO IP를 조사하기 위해 데이터센터까지 들어갈 필요가 없습니다.

&nbsp;

## 환경

- **Vendor** : HP
- **Model** : ProLiant DL380 Gen9
- **OS** : Red Hat Enterprise Linux Server release 6.5 (Santiago)
- **Architecture** : x86_64
- **Shell** : bash
- **Package** : ipmitool-1.8.11

&nbsp;

## 배경지식

### IPMI

IPMI<sup>Intelligent Platform Management Interface</sup>는 서버 관리를 위한 관리 인터페이스로 원격지나 로컬 서버의 상태를 파악하고 제어할 수 있는 기능을 제공합니다.  
따라서 많은 수의 서버를 관리하는 환경에서는 IPMI를 유용하게 활용될 수 있습니다.  
요즘 나오는 대부분의 서버용 메인보드는 IPMI를 기본적으로 지원합니다.

[IBM | IPMI 개요](https://www.ibm.com/docs/ko/power9?topic=ipmi-overview)

&nbsp;

## 전제조건

`ipmitool` 패키지가 설치된 시스템

> **참고사항**  
> `ipmitool`은 IPMI(Intelligent Platform Management Interface)를 지원하는 장치를 모니터링, 구성 및 관리하는 CLI 유틸리티입니다.

`ipmitool` 패키지 설치 방법은 이 글의 주제를 벗어나는 내용이기 떄문에 생략하겠습니다.

&nbsp;

## 설정방법

### 1. ipmi 패키지 확인

```bash
$ rpm -qa | grep ipmitool
ipmitool-1.8.11-16.el6.x86_64
```

ipmitool `1.8.11` 버전의 패키지가 설치되어 있습니다.

&nbsp;

### 2. ipmi 서비스 시작

```bash
$ service ipmi start
Starting ipmi drivers: [  OK  ]
```

ipmi 서비스를 시작합니다.

&nbsp;

### 3. iLO IP 확인

현재 서버에 설정된 iLO IP 정보를 확인합니다.

```bash
$ ipmitool lan print
```

&nbsp;

명령어 실행 결과는 다음과 같습니다.

```bash
Set in Progress         : Set Complete
Auth Type Support       : 
Auth Type Enable        : Callback : 
                        : User     : 
                        : Operator : 
                        : Admin    : 
                        : OEM      : 
IP Address Source       : Static Address
IP Address              : 192.168.0.120
Subnet Mask             : 255.255.255.0
MAC Address             : 98:f2:b3:3b:fa:3e
SNMP Community String   : 
BMC ARP Control         : ARP Responses Enabled, Gratuitous ARP Disabled
Default Gateway IP      : 0.0.0.0
802.1q VLAN ID          : Disabled
802.1q VLAN Priority    : 0
RMCP+ Cipher Suites     : 0,1,2,3
Cipher Suite Priv Max   : XuuaXXXXXXXXXXX
                        :     X=Cipher Suite Unused
                        :     c=CALLBACK
                        :     u=USER
                        :     o=OPERATOR
                        :     a=ADMIN
                        :     O=OEM
```

서버 하드웨어 제조사가 HP일 경우, `ipmitool lan print` 명령어 결과에 나오는 `IP Address` 는 iLO IP와 동일한 의미입니다.  

ipmi 서비스가 실행되어 있지 않을 경우, 제대로 결과를 반환하지 않습니다.  
`ipmitool lan print` 명령어 실행시 응답이 없을 경우, ipmi 서비스가 잘 동작하고 있는 상태인지 확인해야 합니다.

&nbsp;

### 4. iLO IP 설정

```bash
## (1) 고정(Static) IP 설정
$ ipmitool lan set 1 ipsrc static

## (2) IP 설정
$ ipmitool lan set 1 ipaddr 10.10.10.10

## (3) Subnet Mask 설정
$ ipmitool lan set 1 netmask 255.255.255.0

## (4) Default Gateway IP 설정
$ ipmitool lan set 1 defgw ipaddr 10.10.10.1
```

서버 하드웨어 환경에 따라 channel 번호는 반드시 `1`이 아닌 다른 수일수도 있으므로 주의합니다.

&nbsp;

#### ipmitool lan set 명령어 형식

`ipmitool lan set` 명령어만 치면 설정 관련 명령어 사용법이 나오므로 참고할 수 있습니다.

```bash
$ ipmitool lan set

usage: lan set <channel> <command> <parameter>

LAN set command/parameter options:
  ipaddr <x.x.x.x>               Set channel IP address
  netmask <x.x.x.x>              Set channel IP netmask
  macaddr <x:x:x:x:x:x>          Set channel MAC address
  defgw ipaddr <x.x.x.x>         Set default gateway IP address
  defgw macaddr <x:x:x:x:x:x>    Set default gateway MAC address
  bakgw ipaddr <x.x.x.x>         Set backup gateway IP address
  bakgw macaddr <x:x:x:x:x:x>    Set backup gateway MAC address
  password <password>            Set session password for this channel
  snmp <community string>        Set SNMP public community string
  user                           Enable default user for this channel
  access <on|off>                Enable or disable access to this channel
  alert <on|off>                 Enable or disable PEF alerting for this channel
  arp respond <on|off>           Enable or disable BMC ARP responding
  arp generate <on|off>          Enable or disable BMC gratuitous ARP generation
  arp interval <seconds>         Set gratuitous ARP generation interval
  vlan id <off|<id>>             Disable or enable VLAN and set ID (1-4094)
  vlan priority <priority>       Set vlan priority (0-7)
  auth <level> <type,..>         Set channel authentication types
    level  = CALLBACK, USER, OPERATOR, ADMIN
    type   = NONE, MD2, MD5, PASSWORD, OEM
  ipsrc <source>                 Set IP Address source
    none   = unspecified source
    static = address manually configured to be static
    dhcp   = address obtained by BMC running DHCP
    bios   = address loaded by BIOS or system software
  cipher_privs XXXXXXXXXXXXXXX   Set RMCP+ cipher suite privilege levels
    X = Cipher Suite Unused
    c = CALLBACK
    u = USER
    o = OPERATOR
    a = ADMIN
    O = OEM
```

&nbsp;

### 5. iLO 설정 변경사항 적용

IP 설정 적용을 위해 BMC<sup>Baseboard Management Controller</sup>를 리부팅합니다.

```bash
$ ipmitool mc reset cold
```

&nbsp;

#### BMC

**개념**  
IPMI<sup>Intelligent Platform Management Interface</sup> 유틸리티의 핵심 하드웨어 칩으로, 관리자들이 서버와 데스크톱에 대한 원격으로 긴급 모니터링하는데 활용합니다.

**핵심 기능과 역할**  
BMC 칩의 핵심기능은 CPU, Fan, 전원부(Power Supply), VGA<sup>Video Graphic Array</sup> 카드 등 각 하드웨어 부품(Component)에 설치된 센서들과 통신을 통해 상태를 모니터링하고, 발생하는 이벤트를 기록합니다. 원격으로 복구, 제어 등의 기능을 수행할 수도 있습니다.

&nbsp;

이것으로 iLO IP를 확인, 설정하는 작업이 완료되었습니다.
