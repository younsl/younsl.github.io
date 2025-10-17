---
title: AIX 계정잠금 해제
date: 2021-10-20T21:04:15+09:00
lastmod: 2025-10-10T09:19:30+09:00
description: "IBM AIX에서 잠긴 계정을 확인하고 잠금 해제하는 방법을 설명합니다."
keywords: []
tags: ["os", "unix", "aix"]
---

## 개요

IBM AIX에서 잠긴 계정을 확인하고 해제하는 방법입니다.

## TL;DR

- **대상 독자**: IBM AIX 서버 관리자
- **핵심 내용**: 로그인 실패로 잠긴 AIX 계정 확인 및 해제
- **얻을 수 있는 것**:
  - 계정 잠금 상태 확인 방법
  - 로그인 실패 횟수 초기화 및 잠금 해제 절차
  - 무차별 대입 공격(Brute-force attack) 방지를 위한 계정 잠금 정책 설정

## 환경

- **OS** : IBM AIX 7.2.0.0
- **Shell** : ksh (Korn Shell, AIX 기본 쉘)

## 해결방법

`lsuser`와 `chuser` 명령어로 계정 잠금 상태를 확인하고 해제합니다. root 권한이 필요합니다.

### 1. 로그인 실패회수 확인

로그인 실패 횟수를 확인합니다.

```bash
$ lsuser -a unsuccessful_login_count devuser1
devuser1 unsuccessful_login_count=6
```

### 2. 계정 잠금상태 확인

계정 잠금 여부를 확인합니다.

```bash
$ lsuser -a account_locked devuser1
devuser1 account_locked=true
```

`account_locked=true`이면 계정이 잠긴 상태입니다.

### 3. 로그인 실패회수 초기화

로그인 실패 횟수를 0으로 초기화합니다.

```bash
chsec -f /etc/security/lastlog \
  -a unsuccessful_login_count=0 \
  -s devuser1
```

### 4. 계정잠금 해제

계정 잠금을 해제합니다.

```bash
chuser account_locked=false devuser1
```

## 더 나아가서

### 특정 계정 잠금

장기간 미사용 계정을 보안을 위해 잠글 수 있습니다.

```bash
chuser account_locked=true devuser1
```

### 무차별 대입 공격 방지 (권장)

로그인 실패 횟수 제한 설정을 적극 권장합니다. 무차별 대입 공격(Brute-force attack)으로부터 시스템을 보호하고, 비인가 접근 시도를 자동으로 차단할 수 있습니다.

> ⚠️ **경고**: 설정 후 로그인을 여러 번 실패하면 계정이 잠겨 SSH 등 원격 로그인이 불가능해질 수 있습니다. 계정 잠금 해제를 위해서는 root 권한으로 서버에 직접 접근해야 합니다.

`/etc/security/user` 파일에서 `loginretries` 값을 설정합니다.

```bash
$ vi /etc/security/user
...
default:
        loginretries = 5
```

- `default:` 섹션에 설정하면 모든 사용자 계정에 글로벌 적용됩니다.
- `loginretries = 5`: 5번 로그인 실패 시 계정 자동 잠금
- `loginretries = 0`: 무제한 (기본값)
- 특정 사용자만 적용하려면 해당 사용자 섹션에 개별 설정합니다.

## 관련자료

- [IBM Support - Methods of Locking User Accounts](https://www.ibm.com/support/pages/methods-locking-user-accounts): OS 계정 잠금정책 설정, 잠금해제 방법 등에 대한 IBM 공식문서
