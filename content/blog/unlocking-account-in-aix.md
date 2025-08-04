---
title: "AIX 계정잠금 해제"
date: 2021-10-20T21:04:15+09:00
lastmod: 2023-04-13T20:13:30+09:00
slug: ""
description: "IBM AIX에서 잠긴 계정을 확인하고 잠금 해제하는 방법을 설명합니다."
keywords: []
tags: ["os", "unix", "aix"]
---

## 개요

IBM AIX에서 계정이 잠긴 여부를 확인하고 잠긴 계정을 해제할 수 있습니다.

&nbsp;

## 증상

OS 계정이 잠겨서 원격 로그인(SSH)이 불가능한 상황입니다.

&nbsp;

## 환경

- **OS** : IBM AIX 7.2.0.0
- **Shell** : ksh

&nbsp;

## 해결방법

쉘에서 [chsec](https://www.ibm.com/docs/ko/aix/7.2?topic=c-chsec-command) 명령어를 실행해 계정의 잠금상태를 확인하고 잠금을 해제하면 됩니다.  
계정 패스워드 제어와 관련된 작업이기 때문에 반드시 root 권한을 얻어 실행해야만 합니다.  

&nbsp;

## 상세 조치방법

### 1. 로그인 실패회수 확인

**명령어 형식**  
`lsuser` 명령어는 사용자 계정 속성을 표시합니다.

```bash
$ lsuser -a <속성명> <계정명>
```

&nbsp;

**명령어 예시**  
`devuser1` 계정의 로그인 실패 횟수를 확인합니다.

```bash
$ lsuser -a unsuccessful_login_count devuser1
devuser1 unsuccessful_login_count=6
```

`devuser1` 계정에서 로그인을 6번 실패한 이력이 있습니다.

&nbsp;

### 2. 계정 잠금상태 확인

**명령어 형식**

```bash
$ lsuser -a <속성명> <계정명>
```

&nbsp;

**명령어 예시**

```bash
$ lsuser -a account_locked devuser1
devuser1 account_locked=true
```

devuser1 계정의 `account_locked` 값이 `true`이므로 계정이 잠긴 상태입니다.

&nbsp;

### 3. 로그인 실패회수 초기화

`devuser1` 계정의 로그인 실패회수(`unsuccessful_login_count`) 값을 0으로 설정하여 초기화합니다.

```bash
$ chsec -f /etc/security/lastlog \
    -a unsuccessful_login_count=0 \
    -s devuser1
```

**명령어 옵션**  
`-f` : file. 설정파일의 이름  
`-a` : attribute. 사용자의 속성  
`-s` : stanza. 사용자 계정 이름

&nbsp;

### 4. 계정잠금 해제

#### 명령어 형식

```bash
$ chuser <속성명>=<값> <계정명>
```

&nbsp;

#### 명령어 예시

```bash
$ chuser account_locked=false devuser1
devuser1 account_locked=false
```

`account_locked` 속성값을 `true`에서 `false`로 변경해서 devuser1 계정 잠금을 해제합니다.

&nbsp;

## 더 나아가서

이 부분부터는 본문인 '잠긴 OS 계정 풀기' 메뉴얼과는 무관하나 알고 있으면 유용한 명령어입니다.

- 특정 사용자 계정 잠그기
- 로그인 실패 시 잠금 정책 설정하기

&nbsp;

### 특정 계정 잠금

종종 서버의 보안강화를 목적으로 시스템 관리자가 장기간 사용하지 않는 운휴 계정을 잠금처리할 때 사용합니다.

&nbsp;

#### 1. 계정 잠금 실행

`devuser1` 계정을 강제로 잠급니다.

```bash
$ chuser account_locked=true devuser1
```

&nbsp;

#### 2. 계정상태 확인

`devuser1` 계정의 잠김 여부를 확인합니다.

```bash
$ lsuser -a account_locked devuser1
devuser1 account_locked=true
```

`devuser1` 계정의 `account_locked` 값이 true이므로 현재 계정이 잠긴 상태입니다.

&nbsp;

특정 사용자 계정을 lock 처리 완료했습니다.

&nbsp;

### 무차별 대입 공격 방지

무차별 대입 공격(brute-force attack)은 특정 암호를 풀기 위해 가능한 모든 값을 대입해 암호를 뚫는 공격 기법입니다.  
무차별 대입 공격을 방어하는 대표적인 방법에는 서버 보안설정에서 **로그인 재시도 횟수의 제한 설정**이 있습니다.

아래는 AIX 서버에서 여러번 로그인 실패시 계정이 잠기는 설정방법입니다.

&nbsp;

#### 1. user 설정파일 확인

IBM-AIX의 `/etc/security/user` 설정파일에는 확장된 사용자 계정에 대한 보안 설정이 포함되어 있습니다.

```bash
$ cat /etc/security/user
...
default:
        loginretries = 0
```

`loginretries` : 계정 잠금 임계값 (계정 잠그기 전 로그인 시도 횟수)  
`loginretries = 0`은 로그인 시도 가능 횟수가 무제한입니다. 이는 계정 잠금 임계값이 설정되지 않은 상태를 의미합니다.

&nbsp;

#### 2. 계정 잠금 임계값 수정

```bash
$ vi /etc/security/user
...
default:
        loginretries = 5
```

vi 편집기를 사용해서 `loginretries` 값을 0에서 5로 수정합니다.  
기본적<sup>default</sup>으로 모든 계정은 5번 로그인이 실패하면, 계정이 잠기게 됩니다.

&nbsp;

로그인 실패 시 잠금 정책 설정이 완료됐습니다.

&nbsp;

## 참고자료

[IBM Support - Methods of Locking User Accounts](https://www.ibm.com/support/pages/methods-locking-user-accounts)  
OS 계정 잠금정책 설정, 잠금해제 방법 등에 대한 IBM 공식문서
