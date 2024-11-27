---
title: "리눅스 부팅순서"
date: 2021-11-02T23:59:40+09:00
lastmod: 2022-09-01T12:29:09+09:00
slug: ""
description: "리눅스 부팅 순서를 상세하게 설명합니다."
keywords: []
tags: ["os", "linux", "hardware"]
---

## 개요

리눅스의 부팅순서를 설명한다.

서버의 전원 버튼을 누르고 몇 분이 지나면 로그인 프롬프트가 뜬다는 사실은 모두가 알고 있다. 우리가 전원 버튼을 누르고 로그인 프롬프트가 뜨기 전 까지의 과정을 처음부터 따라가보자.  

### 참고사항

리눅스의 부팅순서, RAID의 각 레벨별 설명은 시스템 엔지니어 면접시 단골 질문이기도 하고 OS 트러블슈팅 시 실제로 많은 도움이 되기 때문에 반드시 알아두는 게 좋다.

### 여담

내 경험으로는 AWS의 Data Center Technician 포지션 면접 때 받은 질문이 "각 RAID 레벨별 동작방식을 설명하시오."였다.  
물론 이걸 영어로 답변해야한다. ~~그래서 광탈해버렸다.~~

&nbsp;

## 요약

리눅스 부팅순서는 크게 6단계로 구분할 수 있다.

| # | Name     | Description                                                 |
|---|----------|-------------------------------------------------------------|
| 1 | BIOS     | BIOS가 MBR을 실행한다.                                          |
| 2 | MBR      | MBR<sup>Master Boot Record</sup>가 GRUB을 실행한다.             |
| 3 | GRUB     | GRUB<sup>Grand Unified Bootloader</sup>가 Kernel을 실행한다.    |
| 4 | Kernel   | Kernel이 `/sbin/init`을 실행한다.                               |
| 5 | Init     | Init 프로세스가 런레벨 프로그램들을 실행한다.                          |
| 6 | Runlevel | 런레벨 프로그램들이 `/etc/rc.d/rc*.d`를 실행한다.                   |

&nbsp;

## 각 단계별 상세설명

### 1. BIOS

- BIOS는 Basic Input/Output System<sup>기본 입출력 시스템</sup>의 약자이다.
- 일부 시스템 무결성 검사를 수행한다.
- 부트로더 프로그램을 검색, 로드 및 실행한다.
- BIOS는 플로피, CD-ROM 또는 하드 드라이브에서 부트 로더를 찾는다.  
  BIOS 시작 중에 키(일반적으로 <kbd>F2</kbd> 또는 <kbd>F12</kbd>이며 시스템마다 다르다)를 눌러 부팅 순서를 변경할 수 있다.
- 부트 로더 프로그램이 감지되어 메모리에 로드되면 BIOS가 이를 제어한다.
- **요약** : BIOS는 MBR 부트 로더를 불러오고 실행하는 역할을 한다.

&nbsp;

### 2. MBR

- MBR은 마스터 부트 레코드(Master Boot Record)의 약자이다.
- MBR은 부팅 디스크의 첫 번째 섹터에 위치해있다. 일반적으로 첫번째 디스크 장치명을 의미하는 `/dev/hda` 또는 `/dev/sda`이다.
- MBR은 크기가 512바이트이다. 여기에는 세 가지 구성 요소가 있다.
  1. **Bootstrap code** : 446bytes 크기의 첫번째 부트 로더 정보
  2. **Partition table** : 64bytes 크기의 파티션 테이블 정보
  3. **Signature** : 마지막 2바이트는 MBR 유효성 체크 영역으로 항상 0x55AA 값이 들어간다. (Signature 값이 0x55AA가 아닌 다른 값일 경우 부팅시 `Operating System not found` 에러와 함께 부팅이 불가능하다.)
- MBR에는 GRUB(구 시스템의 경우 LILO)에 대한 정보가 들어 있다.
- **요약** : MBR은 GRUB 부트 로더를 로드하고 실행한다.

&nbsp;

### 3. GRUB

- GRUB은 Grand Unified Bootloader의 약자이다.
- 시스템에 여러 개의 커널 이미지가 설치된 경우 실행할 이미지를 선택할 수 있다.
- GRUB는 부팅시 시작 화면을 표시하고 사용자가 리눅스 커널 선택을 할 때까지 몇 초 동안 기다린다. 아무 선택도 하지 않으면 grub 설정파일에 지정된 대로 기본 커널 이미지를 로드한다.
- GRUB은 파일 시스템에 대한 정보를 갖고 있다. 구버전의 리눅스 부트로더인 LILO(Linux Loader)는 파일 시스템을 이해하지 못했다.
- GRUB의 설정 파일은 `/boot/grub/grub.conf`이다. (`/etc/grub.conf`는 이 파일에 대한 링크파일). 다음은 CentOS의 `grub.conf` 샘플이다.
  
  ```bash
  #boot=/dev/sda
  default=0
  timeout=5
  splashimage=(hd0,0)/boot/grub/splash.xpm.gz
  hiddenmenu
  title CentOS (2.6.18-194.el5PAE)
            root (hd0,0)
            kernel /boot/vmlinuz-2.6.18-194.el5PAE ro root=LABEL=/
            initrd /boot/initrd-2.6.18-194.el5PAE.img
  ```

- 위의 정보에서 알 수 있듯이 GRUB 설정파일에는 커널과 initrd 이미지가 포함되어 있다.
- **요약** : GRUB은 커널 및 initrd 이미지를 불러오고 실행한다.

&nbsp;

### 4. Kernel

- GRUB 설정파일(`grub.conf`)의 `root=`에 지정된 대로 루트 파일 시스템을 디스크 장치에 마운트한다.
- 리눅스 커널은 `/sbin/init` 프로세스를 실행한다.
- `init`는 리눅스 커널에서 실행되는 첫 번째 프로그램이기 때문에 프로세스 ID(PID)가 1이다.  
  시간날 때 쉘에서 `ps -ef | grep init` 명령어를 입력해서 init 프로세스의 pid를 직접 확인해보자.
- initrd는 초기 RAM 디스크<sup>initial ram disk</sup>의 약자로 메모리 상의 가상 디스크이다.  
  initrd는 리눅스 커널이 부팅되고 실제 루트 파일 시스템이 마운트될 때까지 커널에 의해 임시 루트 파일 시스템으로 사용된다.
- initrd는 initramfs이라는 파일시스템을 갖고 있다. initramfs은 리눅스 커널이 초기에 동작할때 필요한 드라이버나 프로그램, 바이너리 파일 등을 가지고 있어 하드 드라이브 파티션 및 기타 하드웨어에 액세스하는 데 도움을 준다.

&nbsp;

### 5. Init

- `/etc/inittab` 설정파일을 참조해 Linux 운영체제의 실행 수준(Runlevel)을 결정한다.
- 다음은 리눅스 서버에서 사용 가능한 [Runlevel](https://en.wikipedia.org/wiki/Runlevel#Linux_Standard_Base_specification) 목록이다.
  
  | Runlevel | 설명                                        |
  |----------|--------------------------------------------|
  | 0        | 종료 (Halt)                                 |
  | 1        | 단일 사용자 모드 (Single user mode)            |
  | 2        | NFS가 없는 다중 사용자 (Multiuser, without NFS) |
  | 3        | 전체 다중 사용자 모드 (Full multiuser mode)      |
  | 4        | 미사용 (unused)                               |
  | 5        | X11 (GUI)                                   |
  | 6        | 재부팅 (Reboot)                               |

- 대부분의 리눅스 서버는 Runlevel을 3 또는 5로 설정해서 운영한다.
- Init 프로세스는 `/etc/inittab` 설정파일에서 기본 Runlevel을 확인한 후 각 레벨에 맞게 프로그램들을 로드한다.
- 시스템에서 `grep initdefault /etc/inittab` 명령어를 실행하면 Runlevel 기본 설정을 확인할 수 있다.

  ```bash
  # In terminal
  $ grep initdefault /etc/inittab
  id:3:initdefault:
  ```

- 스스로 시스템 장애를 만들고 싶다면 `/etc/inittab` 설정파일을 열어 Default Runlevel을 0 또는 6 으로 설정하면 된다.  
  이제 우리는 Runlevel 0과 6이 무엇을 의미하는지 알기 때문에 아마도 그렇게 하지는 않겠지만.

&nbsp;

### 6. Runlevel programs

- Linux 시스템이 부팅될 때 다양한 서비스가 자동 시작되는 걸 확인할 수 있다.  
  예를 들어 `starting sendmail … OK`와 같은 메세지가 이에 해당한다. 이러한 프로그램들은 Runlevel 디렉토리(`/etc/rc.d/rc*.d/`)에 의해 자동실행되는 프로세스들이다.
- 기본 초기화 레벨<sup>Runlevel</sup> 설정에 따라 시스템은 다음 디렉토리 중 하나를 골라 그 안에 나열된 프로그램들을 순차적으로 실행한다.
  - 실행 레벨 0 – `/etc/rc.d/rc0.d/`
  - 실행 레벨 1 – `/etc/rc.d/rc1.d/`
  - 실행 레벨 2 – `/etc/rc.d/rc2.d/`
  - 실행 레벨 3 – `/etc/rc.d/rc3.d/`
  - 실행 레벨 4 – `/etc/rc.d/rc4.d/`
  - 실행 레벨 5 – `/etc/rc.d/rc5.d/`
  - 실행 레벨 6 – `/etc/rc.d/rc6.d/`
- `/etc` 하위에 직접 이 디렉토리에 사용할 수 있는 심볼릭 링크도 있다. 따라서 `/etc/rc0.d`는 `/etc/rc.d/rc0.d`에 연결되어 있다.
- `/etc/rc.d/rc*.d/` 디렉토리에서 첫글자가 S와 K로 시작하는 프로그램들을 볼 수 있다.

  ```bash
  # === 예시 ===
  S12syslog
  S80sendmail
  K02NetworkManager

  # === 해석방법 ===
  S 12 syslog
  - -- ------
  |  |   +---> 실행할 프로그램 이름
  |  +-------> 시퀀스 번호 (숫자가 낮을수록 먼저 실행)
  +----------> 시작 S=Startup or 종료 K=Kill
  ```

  - 첫글자가 `S`로 시작하는 프로그램은 자동적으로 시작<sup>Startup</sup> 된다.
  - 첫글자가 `K`로 시작하는 프로그램은 자동적으로 종료<sup>Kill</sup> 된다.
  - 프로그램 이름에서 S와 K 바로 옆에 숫자가 있다. 프로그램이 시작되거나 종료되어야 하는 시퀀스 번호이다.
- 예를 들어, `S12syslog`는 시퀀스 번호가 12인 syslog 데몬을 시작한다.  
  `S80sendmail`은 시퀀스 번호가 80인 sendmail 데몬을 시작한다.  
  시스템이 부팅될 때 syslog 프로그램은 sendmail의 시퀀스 번호 `80`보다 더 낮은 `12`이기 때문에 sendmail 프로그램보다 먼저 시작된다.

&nbsp;

이상으로 리눅스 부팅순서에 대해 알아보았다.
