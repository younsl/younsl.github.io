---
title: "zagent 모니터링 에이전트 설치"
date: 2021-11-05T22:11:05+09:00
lastmod: 2021-11-07T22:55:20+09:00
slug: ""
description: "브레인즈컴퍼니에서 개발한 모니터링 솔루션인 ITSM(IT Service Management)의 모니터링 에이전트를 모니터링 대상 서버에 설치하는 방법을 설명합니다."
keywords: []
tags: ["os", "linux"]
---

# 개요

모니터링 대상인 리눅스 서버에 ITSM(IT Service Management) 모니터링 에이전트를 설치할 수 있다.

<br>

# 환경

- **OS** : Red Hat Enterprise Linux server release 7.x
- **Architecture** : x86_64
- **에이전트 SW** : ITSM 모니터링 에이전트 (`zagent-rhes3-x64_254`)

<br>

# 해결법

## **A) 에이전트 설치**

> 반드시 root 계정으로 ITSM 에이전트 설치를 진행한다.

### **1. zagent 설치파일 준비**

```bash
 $ arch
 x86_64
```

해당 서버는 64bit 기반 아키텍쳐(`x86_64`)이다.  


모니터링 대상서버의 아키텍쳐와 동일한 버전의 에이전트 설치파일을 모니터링 대상 서버의 파일시스템에 업로드한다.

```bash
 $ chmod 700 zagent-rhes3-x64_254
 $ chown root:root zagent-rhes3-x64_254
```

설치파일의 권한을 700(`rwx --- ---`), 소유자 `root`, 그룹 `root`로 설정한다.  

<br>



```bash
 $ ls -lh
 [...]
 -rwx------  1 root root 1.1M  813  2010 zagent-rhes3-x64_254
 $ mv zagent-rh78-i386_254 /usr/sbin/zagent
```

ITSM 에이전트 설치파일의 이름을 zagent로 변경한다. 설치파일을 이동시킬 경로는 반드시 `/usr/sbin/` 이어야 한다.

<br>



### **2. zagent 설치**

```bash
 $ zagent -install
 Excute user <default: root> ?: [ENTER]
 INSTALL: 'zagent', Path : '/sbin', User : 'root'
 Link /etc/rc.d/init.d/zagent /etc/rc.d/rc2.d/S99zagent
 Link /etc/rc.d/init.d/zagent /etc/rc.d/rc3.d/S99zagent
 Link /etc/rc.d/init.d/zagent /etc/rc.d/rc4.d/S99zagent
 Link /etc/rc.d/init.d/zagent /etc/rc.d/rc5.d/S99zagent
 Install completed
```

엔터를 입력해 default 계정(root)으로 설치를 실행한다.

<br>



**문제해결**

- **증상** : `zagent -install` 명령어로 설치 시도시 `/lib/ld-linux.so.2: bad ELF interpreter: No such file or directory` 에러가 발생하며 설치가 불가능함
- **원인** : 설치파일과 서버간 아키텍쳐 호환성 불일치 (64비트 기반 아키텍쳐 서버에 32비트 기반 아키텍쳐용 설치파일 시도)
- **조치방법** : 64비트 기반 아키텍쳐(x86_64)용 설치파일로 설치를 진행한다.

<br>



### **3. manager 서버 등록**

**명령어 형식**

```bash
 $ zagent -a admin <ITSM_MANAGER_SERVER1_IP> <ITSM_MANAGER_SERVER2_IP>
```

<br>



**실행 명령어**

```bash
 $ zagent -a admin 50.50.50.101 50.50.50.102
 user 0, /var/zagent: created
 ZENIUS_PROGRAM_PATH=
 File Path: '/sbin'
 Current Path: '/var/zagent'
```

<br>



### **4. manager 서버 연결 테스트**

```bash
 $ zagent -c
 ZENIUS_PROGRAM_PATH=
 File Path: '/sbin'
 Current Path: '/var/zagent'
 Try connect to Primary Manager[50.50.50.101:5052] : Success
 Try connect to Secondary Manager[50.50.50.102:5052] : Success
```

모니터링 대상서버가 ITSM Manager 서버의 TCP 5052 포트와 통신이 되어야 한다.

<br>

```bash
  +---------------+     5052 +---------------+       
  | target server |--------->| ITSM Manager1 |       
  +---------------+          +---------------+       
          |                                          
          |             5052 +---------------+       
          +----------------->| ITSM Manager2 |       
                             +---------------+        
```

접속 테스트 결과가 `Success` 가 아닐 경우, 방화벽과 같은 보안장비나 모니터링 대상 서버의 자체 방화벽(iptables) 정책을 확인한다.

<br>



### **5. zagent 프로세스 시작**

```bash
 $ zagent -start
 ZENIUS_PROGRAM_PATH=
 File Path: '/sbin'
 Current Path: '/var/zagent'
 zagent: started (153799)
 SetMemLimit: 200 MB (OK)
 SetFDLimit: 1024 (OK)
 SetCoreLimit: 0 MB (OK)
 Current Stack Size: 8388608 bytes
 Hostname: devserver1
 IP: 192.168.0.15
 MAC Address: xx:xx:xx:46:15:01
 OS: Red Hat Enterprise Linux Server release 7.x
```

<br>



### **6. 프로세스 상태 확인**

```bash
 $ ps -ef | grep zagent
 root     153799      1  0 08:48 ?        00:00:00 zagent -start
 root     153800 153799  2 08:48 ?        00:00:00 zagent -start
 root     154157 140259  0 08:48 pts/1    00:00:00 grep --color=auto zagent
```

zagent 프로세스가 정상 동작중이다.

<br>



## **B) 모니터링 대상의 수집되는 IP 수정**  

> ITSM 웹페이지에서 모니터링 대상 서버의 IP가 실제 IP와 다르게 수집되는 경우가 있다. 이 경우에만 아래 과정을 수행한다. 수집되는 IP가 실제 IP와 동일하다면 해당 과정을 넘겨도 된다.

<br>



### **1. 에이전트 중지**

zagent 프로세스가 이미 실행중인 상태라면 설정파일을 수정하기 전에 먼저 `zagent -stop` 명령어로 ITSM 에이전트 프로세스를 종료한다.

```bash
 $ zagent -stop
 ZENIUS_PROGRAM_PATH=
 File Path: '/sbin'
 Current Path: '/var/zagent'
 Sending signal pid[0][153799], signum[15]
 Sending signal pid[1][153800], signum[15]
 zagent is stopped
```

<br>



### **2. zagent 설정파일 확인**

zagent 설정파일의 기본 경로는 `/var/zagent/zagent.ini`이다.  

`LOCAL_IP` 값에 실제 서버 IP를 입력한다.

```bash
 $ vi /var/zagent/zagent.ini
 USE_WATCHDOG = 1
 RESTART_LIMIT = 0
 USERID = admin
 MANAGERIP1 = 50.50.50.101
 MANAGERPORT1 = 5052
 MANAGERIP2 = 50.50.50.102
 MANAGERPORT2 = 5052
 ZAGENT_CPU_LIMIT = 50
 ZAGENT_MEM_LIMIT = 200
 ZAGENT_MAX_CPUTIME = 5
 ZAGENT_DISK_LIMIT = 100
 ZAGENT_GET_CDROM = 0
 SMS_GET_THERM = 1
 ZAGENT_CORE_LIMIT = 0
 ZAGENT_FD_LIMIT = 1024
 LOCALIP =
 PRO_DISKIO = 0
 SMS_GET_DISKINV = 1
 NETSTAT_SLEEPCOUNT = 500
 NETSTAT_SLEEPTIME = 100
 AIXMEM_USEDASCOMP = 0
 MAX_WORK_THREADS = 5
 MAX_CONNECTION = 6
 PROACTIVE_SUPPORT = off
 HOSTID = 46500
 SAVEONOFF = 0
 SAVEPERIOD = 0
 MANAGERTYPE = 1
 USER_HOSTNAME = devserver1
```

<br>



### **3. zagent 설정파일 수정**

`LOCAL_IP` 값을 실제 서버의 IP로 입력했다.

```bash
 $ vi /var/zagent/zagent.ini
 USE_WATCHDOG = 1
 RESTART_LIMIT = 0
 USERID = admin
 MANAGERIP1 = 50.50.50.101
 MANAGERPORT1 = 5052
 MANAGERIP2 = 50.50.50.102
 MANAGERPORT2 = 5052
 ZAGENT_CPU_LIMIT = 50
 ZAGENT_MEM_LIMIT = 200
 ZAGENT_MAX_CPUTIME = 5
 ZAGENT_DISK_LIMIT = 100
 ZAGENT_GET_CDROM = 0
 SMS_GET_THERM = 1
 ZAGENT_CORE_LIMIT = 0
 ZAGENT_FD_LIMIT = 1024
 LOCALIP = 50.50.50.199
 PRO_DISKIO = 0
 SMS_GET_DISKINV = 1
 NETSTAT_SLEEPCOUNT = 500
 NETSTAT_SLEEPTIME = 100
 AIXMEM_USEDASCOMP = 0
 MAX_WORK_THREADS = 5
 MAX_CONNECTION = 6
 PROACTIVE_SUPPORT = off
 HOSTID = 46500
 SAVEONOFF = 0
 SAVEPERIOD = 0
 MANAGERTYPE = 1
 USER_HOSTNAME = devserver1
```

<br>



### **4. zagent 프로세스 시작**

```bash
 $ zagent -start
 ZENIUS_PROGRAM_PATH=
 File Path: '/sbin'
 Current Path: '/var/zagent'
 zagent: started (158846)
 SetMemLimit: 200 MB (OK)
 SetFDLimit: 1024 (OK)
 SetCoreLimit: 0 MB (OK)
 Current Stack Size: 8388608 bytes
 Hostname: devserver1
 IP: 50.50.50.199
 MAC Address: xx:xx:xx:46:15:01
 OS: Red Hat Enterprise Linux Server release 7.x
```

모니터링 대상으로부터 수집된 IP 정보가 실제 서버의 IP와 동일하게 변경된 상태를 확인했다.

```bash
 IP: 50.50.50.199
```

