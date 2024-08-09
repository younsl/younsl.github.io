---
title: "ESXi 호스트 서버 끄기"
date: 2021-10-25T19:57:09+09:00
lastmod: 2021-10-25T20:19:35+09:00
slug: ""
description: "VMware ESXi 호스트 서버를 CLI 환경에서 종료(Shutdown)하는 방법을 소개합니다."
keywords: []
tags: ["os", "vmware"]
---

## 개요

VMware ESXi 호스트 서버를 종료할 수 있습니다.

&nbsp;

## 배경지식

### ESXi 호스트의 Shutdown

VMware ESXi 호스트 서버의 경우 일반 x86 리눅스 서버처럼 `shutdown -h now` 명령어로 서버를 끌 수 없습니다.  

```shell
$ shutdown -h now
-sh: shutdown: not found
```

`shutdown` 명령어 자체가 존재하지 않기 때문입니다.  
(대신 `reboot` 명령어는 ESXi에서도 존재하고 잘 실행됩니다.)

또한 ESXi 호스트 서버를 종료하려면 반드시 유지보수 모드가 설정되어 있어야 합니다.

&nbsp;

## 환경

- **OS** : VMware ESXi 5.1.0
- **Shell** : sh (ESXi shell)
- **ID** : root

&nbsp;

## 해결방법

ESXi 호스트 서버를 종료하는 절차는 다음과 같습니다.

- 호스트 서버에서 운영중인 VM을 다른 호스트로 이사<sup>Migration</sup>합니다.
- 호스트 서버의 종료를 위해서 해당 호스트를 유지보수 모드<sup>Maintenance Mode</sup>로 전환합니다.
- `esxcli` 명령어를 사용해서 호스트 서버를 종료합니다.

&nbsp;

## 상세 조치방법

### 1. root 로그인

ESXi 호스트에 SSH로 접속합니다.  
유저 계정으로 로그인했을 경우 `login root` 명령어로 root 계정에 로그인할 수 있습니다.

```bash
$ login root
```

&nbsp;

root 패스워드를 입력한 후 로그인에 성공한 결과입니다.

```bash
Password: <root 패스워드 입력>
The time and date of this login have been sent to the system logs.

VMware offers supported, powerful system administration tools.  Please
see www.vmware.com/go/sysadmintools for details.

The ESXi Shell can be disabled by an administrative user. See the
vSphere Security documentation for more information.

$
```

**Alert**  
서버 종료<sup>shutdown</sup>와 서버 재시작<sup>reboot</sup>은 반드시 root 권한에서 진행되어야 합니다.

&nbsp;

### 2. 구동중인 VM 리스트 확인

현재 호스트에서 구동되고 있는 가상머신<sup>VM</sup> 리스트를 확인합니다.

```bash
$ esxcli vm process list
```

명령어를 실행했을 때 출력되는 결과가 없을 경우, 해당 호스트에서 구동중인 가상머신<sup>Virutal Machine</sup>이 없는 상태입니다.

해당 호스트 위에서 구동중인 가상머신이 존재할 경우, VM 관리 프로그램<sup>vSphere Client</sup>을 이용해 미리 다른 호스트로 마이그레이션해야 합니다.

&nbsp;

### 3. 유지보수 모드 확인

현재 호스트 서버의 유지보수 모드를 확인합니다.

```bash
$ esxcli system maintenanceMode get
Disabled
```

`Disabled`로 유지보수 모드가 비활성화되어 있습니다.

&nbsp;

### 4. 유지보수 모드 활성화

현재 호스트 서버를 유지보수 모드로 전환합니다.

```bash
# 유지보수 모드 켜기
$ esxcli system maintenanceMode set --enable true
```

유지보수 모드가 설정되면 vSphere Client에서도 호스트 아이콘이 바리게이트가 쳐진 호스트 아이콘으로 변경됩니다.

&nbsp;

다시 호스트 서버의 유지보수 모드를 확인합니다.

```bash
$ esxcli system maintenanceMode get
Enabled
```

유지보수 모드가 `Disabled`에서 `Enabled`로 변경되었습니다. 현재 유지보수 모드가 활성화된 상태입니다.

&nbsp;

**참고사항**  
반대로 유지보수 모드를 끄는 방법은 아래 명령어를 실행합니다.

```bash
# 유지보수 모드 끄기
$ esxcli system maintenanceMode set --enable false
```

&nbsp;

### 5. 서버 종료

#### 실행 명령어 예시

호스트 서버를 종료합니다.

```bash
$ esxcli system shutdown poweroff --reason="Memory replacement."
```

작업사유<sup>`--reason`</sup>에는 반드시 호스트 서버를 종료<sup>shutdown</sup>하는 이유를 상세히 적어야 합니다.

&nbsp;

명령어 실행 시 작업사유를 입력하지 않을 경우, 아래와 같이 `Error: Missing required parameter -r|--reason` 에러가 발생하면서 명령어가 실행되지 않습니다.

```bash
$ esxcli system shutdown poweroff
Error: Missing required parameter -r|--reason
...
```

&nbsp;

#### 명령어 사용법 확인

`esxcli system shutdown poweroff` 명령어에 대한 사용법을 확인합니다.

```bash
$ esxcli system shutdown poweroff
Error: Missing required parameter -r|--reason

Usage: esxcli system shutdown poweroff [cmd options]

Description: 
  poweroff              Power off the system. The host must be in maintenance mode.

Cmd options:
  -d|--delay=<long>     Delay interval in seconds
  -r|--reason=<str>     Reason for performing the operation (required)
```

&nbsp;

위 명령어 `help` 내용을 통해 우리는 2가지 정보를 얻을 수 있습니다.

- 호스트 서버를 끄려면 먼저 유지보수 모드<sup>maintenance mode</sup>로 설정되어 있어야 합니다.

  ```bash
  The host must be in maintenance mode.
  ```

- `-r|--reason`은 서버 종료를 진행하는 이유를 나타내며 필수<sup>required</sup> 옵션입니다.