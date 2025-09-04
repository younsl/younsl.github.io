---
title: "Amazon Linux 2 로케일과 타임존 변경"
date: 2023-01-17T19:52:10+09:00
lastmod: 2023-01-17T23:49:15+09:00
slug: ""
description: "Amazon Linux 2 EC2의 타임존을 한국 표준시(KST)로 바꾸는 방법을 소개합니다."
keywords: []
tags: ["os", "linux", "aws"]
---

이 가이드에서는 Amazon Linux 2 인스턴스의 로케일 & 문자셋과 타임존을 변경하는 방법을 소개합니다.

&nbsp;

## 개요 - 1. timezone 설정

EC2 인스턴스의 표준시를 변경하는 방법을 소개합니다.

종종 EC2 인스턴스의 시간을 한국 표준시로 변경해야하는 경우가 있습니다.

제 최근 사례로는 EC2 인스턴스 로컬에서 돌리는 테스트 코드로 인해 생성되는 로그 시간이 협정 세계시<sup>UTC, Universal Time Coordinated</sup>가 아닌 한국 표준시<sup>KST, Korea Standard Time</sup>로 찍히도록 해야하는 상황 등이 있었습니다.

&nbsp;

## 환경

- **OS** : Amazon Linux 2
- **Shell** : bash

&nbsp;

## 배경지식

- Amazon Linux 2 인스턴스는 기본적으로 UTC<sup>협정 세계시</sup> 표준 시간대로 설정됩니다.
- 타임존을 변경하게 되면 인스턴스를 리부팅 해도 타임존 설정은 그대로 유지됩니다.

&nbsp;

## EC2 타임존 설정

### 인스턴스 접속

타임존을 설정하기 위해 SSH 또는 SSM Session Manager를 이용해 인스턴스에 원격 접속합니다.

현재 `ec2-user` 계정으로 EC2 인스턴스에 로그인했습니다.

```bash
$ id
uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),4(adm),10(wheel),190(systemd-journal)
```

&nbsp;

### OS 버전 확인

현재 접속한 인스턴스의 운영체제가 Amazon Linux 2 임을 확인합니다.

```bash
$ cat /etc/os-release
NAME="Amazon Linux"
VERSION="2"
ID="amzn"
ID_LIKE="centos rhel fedora"
VERSION_ID="2"
PRETTY_NAME="Amazon Linux 2"
...
```

인스턴스의 OS 버전이 `Amazon Linux 2`입니다.

&nbsp;

### 현재 타임존 확인

```bash
$ timedatectl
      Local time: Tue 2022-05-31 08:58:34 UTC
  Universal time: Tue 2022-05-31 08:58:34 UTC
        RTC time: Tue 2022-05-31 08:58:35
       Time zone: n/a (UTC, +0000)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

현재 설정된 `Time zone` 값이 `n/a`이면 협정 세계시<sup>UTC</sup>를 의미합니다.

&nbsp;

### 타임존 목록 확인

전체 타임존 목록 중 Seoul로 검색합니다.

```bash
$ timedatectl list-timezones | grep -i seoul
Asia/Seoul
```

이제 인스턴스의 타임존을 서울 `Asia/Seoul`로 설정하겠습니다.

&nbsp;

### 타임존 변경

타임존을 `Asia/Seoul`로 변경합니다.

```bash
$ sudo timedatectl set-timezone Asia/Seoul
```

&nbsp;

### 타임존 설정 재확인

`Time zone` 값이 `n/a (UTC, +0000)`에서 `Asia/Seoul (KST, +0900)`으로 변경되었습니다.

```bash
$ timedatectl
      Local time: Tue 2022-05-31 17:58:59 KST
  Universal time: Tue 2022-05-31 08:58:59 UTC
        RTC time: Tue 2022-05-31 08:59:00
       Time zone: Asia/Seoul (KST, +0900)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

&nbsp;

`date` 명령어로 현재 시간을 확인합니다.

```bash
$ date
Tue May 31 17:59:01 KST 2022
```

`date` 결과도 한국 표준시<sup>KST</sup>로 출력되는 걸 확인할 수 있습니다.

&nbsp;

### 타임존 설정의 유지

위 과정에서 조치한 EC2 타임존 설정은 영구적용이기 때문에 EC2 인스턴스가 리부팅된 후에도 계속 유지됩니다.

```bash
$ uptime
 19:49:56 up 0 min,  0 users,  load average: 0.13, 0.03, 0.01
```

현재 EC2 인스턴스의 업타임을 보면 방금 전 리부팅된 상태입니다.

&nbsp;

리부팅이 완료된 후 타임존을 확인합니다.

```bash
$ timedatectl
      Local time: Tue 2022-05-31 19:49:58 KST
  Universal time: Tue 2022-05-31 10:49:58 UTC
        RTC time: Tue 2022-05-31 10:49:59
       Time zone: Asia/Seoul (KST, +0900)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

EC2 인스턴스를 리부팅한 뒤에도 `Time zone` 값이 그대로 `Asia/Seoul (KST, +0900)`로 유지되는 걸 확인할 수 있습니다.

&nbsp;

## 참고자료

**AWS 공식문서**  
[Amazon Linux의 표준 시간대 변경](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/set-time.html#change_time_zone)

&nbsp;

---

&nbsp;

## 개요 - 2. locale과 charset 설정

이제 Amazon Linux 2 인스턴스에서 locale과 문자셋을 변경하는 방법을 소개합니다.  
개발자로부터 외부 연동하는 서버와 한글이 euc-kr로 연동되어야 하는데, ksc5601로 encoding하여 페이로드를 보내도 한글이 깨져서 들어오는 문제가 제보되었습니다.

과거에도 EC2 인스턴스의 charset이 euc-kr로 설정되어 있으면, 한글 연동 시 서버의 문자셋 영향을 받았던 경험이 있었습니다.

&nbsp;

## 인스턴스 환경

- **OS** : Amazon Linux 2
- **CPU 아키텍처** : aarch64 (`t4g.small`)
- **AMI ID** : ami-0ae9ae3937eac86b9
- **AMI Name** : amzn2-ami-ecs-hvm-2.0.20221213-arm64-ebs
- **Shell** : bash

&nbsp;

## 해결방안

Amazon Linux 2가 설치된 EC2 인스턴스에서 문자셋을 `ko_KR.euckr`로 변경하면 됩니다.  
Amazon Linux 2의 문자셋 기본값은 `en_US.UTF-8`입니다.

&nbsp;

## 상세 해결방법

### 조치 전 설정 확인

```bash
$ grep PRETTY_NAME /etc/os-release
PRETTY_NAME="Amazon Linux 2"
```

현재 locale과 charset을 변경할 EC2 인스턴스의 OS는 Amazon Linux 2입니다.

&nbsp;

현재 Locale 설정을 확인합니다.

```bash
$ locale
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=
```

&nbsp;

환경변수도 같이 확인합니다.

```bash
$ echo $LANG
en_US.UTF-8
```

`LANG` 환경변수<sup>environment variable</sup>를 출력해보면 로케일<sup>locale</sup>과 문자셋<sup>character set</sup> 방식을 알 수 있습니다.

&nbsp;

```bash
$ cat /etc/locale.conf
# Created by cloud-init v. 19.3-46.amzn2 on Thu, 15 Dec 2022 05:18:25 +0000
LANG=en_US.UTF-8
```

&nbsp;

### locale 설정변경

locale 환경변수인 LANG을 `ko_KR.euckr`로 설정합니다.

```bash
$ export LANG=ko_KR.euckr
```

&nbsp;

EC2에서 사용 가능한 locale 전체 리스트를 확인합니다.

```bash
$ locale -a | grep kr
ko_KR.euckr
```

&nbsp;

`/etc/locale.conf` 설정파일에서 `LANG` 값을 `ko_KR.euckr`로 변경합니다.

```bash
$ cat /etc/locale.conf
# Created by cloud-init v. 19.3-46.amzn2 on Thu, 15 Dec 2022 05:18:25 +0000
# LANG=en_US.UTF-8
LANG=ko_KR.euckr
```

&nbsp;

`/etc/sysconfig/i18n` 설정파일에서도 `LANG` 값을 `ko_KR.euckr`로 변경합니다.

```bash
$ cat /etc/sysconfig/i18n
LANG="ko_KR.euckr"
```

&nbsp;

### 설정결과 확인

`locale` 명령어로 현재 인스턴스에 설정된 언어값을 확인합니다.

```bash
$ locale
LANG=ko_KR.euckr
LC_CTYPE="ko_KR.euckr"
LC_NUMERIC="ko_KR.euckr"
LC_TIME="ko_KR.euckr"
LC_COLLATE="ko_KR.euckr"
LC_MONETARY="ko_KR.euckr"
LC_MESSAGES="ko_KR.euckr"
LC_PAPER="ko_KR.euckr"
LC_NAME="ko_KR.euckr"
LC_ADDRESS="ko_KR.euckr"
LC_TELEPHONE="ko_KR.euckr"
LC_MEASUREMENT="ko_KR.euckr"
LC_IDENTIFICATION="ko_KR.euckr"
LC_ALL=
```

LANG 값이 모두 `en_US.UTF-8`에서 `ko_KR.euckr`로 변경된 것을 확인할 수 있습니다.

&nbsp;

```bash
$ env | grep LANG
LANG=ko_KR.euckr
```

&nbsp;

인스턴스가 리부팅 가능한 상황인 경우, OS 리부팅 후에도 동일한 locale & charset 설정을 그대로 유지하고 있는 지까지 체크하도록 합니다.

```bash
# EC2 리부팅 후 아래 명령어로 확인
$ echo $LANG
$ locale
$ cat /etc/sysconfig/i18n
```

&nbsp;

## 참고자료

[AWS EC2 Timezone, Locale 변경하기](https://youngjinmo.github.io/2021/04/aws-ec2-setlocale/)

[타임존 변경](/blog/change-ec2-timezone/)  
Amazon Linux 2 인스턴스에서 locale 값이 아닌 timezone 변경이 필요한 경우 위 글을 참조합니다.
