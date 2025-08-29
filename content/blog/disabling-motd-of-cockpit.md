---
title: "Cockpit 로그인 메세지 비활성화"
date: 2021-08-23T22:22:15+09:00
lastmod: 2022-08-25T18:57:20+09:00
slug: ""
description: "CentOS 8에서 로그인 시 발생하는 Cockpit의 불필요한 motd(message of the day) 메세지를 비활성화하는 방법"
keywords: []
tags: ["os", "linux"]
---

## 환경

- **OS** : CentOS Linux release 8.3.2011
- **Shell** : Bash
- **Package** : cockpit

&nbsp;

## 증상

서버에 로그인할 때마다 세션에 불필요한 Welcome Message 출력됩니다.

```bash
Activate the web console with: systemctl enable --now cockpit.socket
[testserver ~]#
```

&nbsp;

## 조치방법

이 Welcome 메세지는 리눅스에 기본적으로 설치되는 `cockpit`이라는 서버 관리 서비스에서 출력하는 메세지입니다.

만약 `cockpit` 서비스를 사용하지 않는 환경이라면 불필요한 메세지가 표출되지 않도록 cockpit의 weclome 메세지 파일을 영구 삭제하면 됩니다.

&nbsp;

## 배경지식

### Cockpit

Cockpit의 사전적 의미는 비행기 조종석을 의미합니다.  
리눅스 환경에서 [Cockpit](https://cockpit-project.org/)은 Fedora Project 에서 나온 웹 UI 기반의 모니터링 및 관리 툴입니다.

Cockpit을 이용하면 별도 프로그램 설치 없이도 웹 브라우저를 통해 리눅스 서버에 원격접속하고 관리할 수 있습니다.  
참고로 Cockpit Web Console의 기본포트는 TCP 9090을 사용합니다.

&nbsp;

**Linux 운영체제별 Cockpit 기본설치 여부**  
자세한 사항은 [Cockpit 공식문서](https://cockpit-project.org/running)를 참조하세요.

- **Red Hat Enterprise Linux** : Red Hat Enterprise Linux 7부터 기본 포함
- **CentOS** : 7.x 부터 기본 포함
- **Debian** : version 10 (Buster)부터 기본 포함
- **Ubuntu** : 17.04부터 기본 포함

&nbsp;

### 서비스 최소화의 원칙

모든 서버는 최소한의 서비스로만 운영되어야 합니다.  
앞으로 서버에서 계속 사용하지 않을 불필요한 서비스라 판단되면, 반드시 비활성화(Disable) 조치를 해서 운영체제의 취약점이 될만한 면적을 최소화합니다.

서비스 최소화의 목적에는 크게 2가지가 있습니다.

- 운영체제 레이어의 보안 향상
- 불필요한 리소스 낭비를 방지

제가 근무하는 데이터센터의 경우, 서비스 최소화의 원칙을 지키기 위해 모든 Linux 서버에서 Cockpit 서비스를 사용하지 않으며, 기본적으로 비활성화 처리합니다.

&nbsp;

## 해결방법

### 1. motd 디렉토리 이동

motd란 message of the day의 줄임말로 모든 유저가 로그인하는 상황에서 터미널에 나타나는 Welcome 메세지를 의미합니다.  
Red Hat 계열 Linux인 CentOS에서는 `/etc/motd` 파일에 전달할 메시지를 적어 놓습니다.

`motd.d` 는 어플리케이션 개별로 motd 메세지를 모아놓은 디렉토리입니다.

```bash
$ cd /etc/motd.d
```

&nbsp;

### 2. motd 파일 확인

`motd.d` 디렉토리 안에 `cockpit` 링크 파일이 들어있는 걸 확인할 수 있다.

```bash
$ ls
lrwxrwxrwx. 1 root root 17. 8월 25일  2020  cockpit -> /run/cockpit/motd
```

&nbsp;

### 3. motd 파일 삭제

`/etc/motd.d/cockpit` 파일을 삭제합니다.

```bash
$ rm -f cockpit
```

`rm -f` : 삭제 여부를 묻지 않고 강제<sup>force</sup>로 파일을 삭제합니다.

&nbsp;

### 4. 로그인 테스트

다시 서버에 로그인해보면 Cockpit 관련 motd 메세지가 출력되지 않습니다.

```bash
Last login: Tue May 11 20:09:04 2021 from 10.10.10.10
$
```

&nbsp;

## 참고자료

[How to cancel Activate the web console with](https://www.programmersought.com/article/14417225140/)  
현재 보고 있는 이 글은 위 링크의 해결방안을 토대로 작성했습니다.

[Cockpit Project](https://cockpit-project.org/)  
Cockpit 공식 홈페이지

[Running Cockpit](https://cockpit-project.org/running)  
리눅스 배포판마다 어느 버전 이후부터 Cockpit을 기본적으로 포함하는지, 실행방법 등 안내.
