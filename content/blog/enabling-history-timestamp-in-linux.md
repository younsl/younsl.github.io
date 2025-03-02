---
title: "리눅스 history에 시간 표시"
date: 2021-07-31T02:27:10+09:00
lastmod: 2022-08-11T21:09:10+09:00
slug: ""
description: "history 명령어에 시간을 표시하는 방법"
keywords: []
tags: ["os", "linux"]
---

## 개요

`history` 명령어 실행시 날짜와 시간을 표시해주도록 설정한다.  

&nbsp;

### history 명령어에 시간이 표시될 때 장점

- 특정 서버를 유지 관리하는 사람이 1명이 아닌 여러 명인 경우 각 계정마다 명령어가 언제 수행되엇는지 볼 수 있다.

- 서버를 혼자 관리하더라도 시스템 관리자 스스로가 언제 무엇을 하거나 변경했는지 정확히 기억할 수 없는 경우에 특히 유용하다.  

&nbsp;

## 환경

- **OS** : Red Hat Enterprise Linux Server release 6.2 (Santiago)
- **Architecture** : x86_64
- **Shell** : bash

&nbsp;

## 설정방법

### 1. 설정파일 수정

```bash
$ vi /etc/profile
...
HISTTIMEFORMAT="[%F %T] "
export HISTTIMEFORMAT
```

#### 설정값 해석

- `HISTTIMEFORMAT` : history 명령어의 시간값에 대한 미리 지정된 환경변수 이름
- `%F` : 날짜 (년-월-일)  
- `%T` : 시간 (시:분:초)  

&nbsp;

#### /etc/profile

시스템 사용자 전체에 적용할 Shell 환경 변수를 담고 있는 설정파일.  
`/etc/profile`의 적용 대상은 모든 사용자이며 시스템에 로그인할 때마다 `/etc/profile`을 읽어들이며 수행하게 된다.  

&nbsp;

### 2. 설정파일 적용

`HISTTIMEFORMAT` 변수를 추가한 내용을 `/etc/profile`에 바로 적용시킨다.

```bash
$ source /etc/profile
```

&nbsp;

### 3. 로그아웃

변경된 설정을 적용하기 위해서 사용 중인 계정을 로그아웃한다.  

```bash
$ logout
```

&nbsp;

### 4. 테스트

```bash
$ history
...
  504  [2015-01-07 15:17:58]  ls
  505  [2015-01-07 15:18:07]  source /etc/profile
  506  [2015-01-07 15:18:10]  history
```

`history` 명령어 실행시 왼쪽에 명령어가 실행된 날짜와 시간이 표시되는 것을 확인할 수 있다.  

&nbsp;

## 참고자료

[리눅스 history 명령 날짜 및 시간 표시하기](https://www.hahwul.com/2015/01/07/history-view-date-and-time-in-history/)

[HISTTIMEFORMAT variable in Linux with Example](https://www.geeksforgeeks.org/histtimeformat-variable-in-linux-with-example/)
