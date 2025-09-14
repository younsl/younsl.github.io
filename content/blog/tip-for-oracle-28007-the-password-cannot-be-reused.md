---
title: "ORA-28007 조치방법"
date: 2021-09-04T17:38:12+09:00
lastmod: 2022-05-15T22:03:40+09:00
slug: ""
description: "ORA-28007: the password cannot be reused 에러 메세지에 대한 조치방법"
keywords: []
tags: ["database", "oracle", "security"]
---

## 증상

DB 계정의 패스워드를 갱신하는 상황에서 `ORA-28007: the password cannot be reused` 에러 메세지가 출력되면서 패스워드를 갱신할 수 없는 문제를 해결한다.

**에러 메세지**

```sql
SQL> ALTER USER MAXGAUGE IDENTIFIED BY "...";
ALTER USER MAXGAUGE IDENTIFIED BY "...";
*
ERROR at line 1:
ORA-28007: the password cannot be reused
```

&nbsp;

## 원인

`ORA-28007: the password cannot be reused`는 동일한 패스워드를 Limit 개수만큼 변경했을 때 발생하는 오류이다.

&nbsp;

## 환경

- **OS** : Red Hat Enterprise Linux Server release 5.10 (Tikanga)
- **ID** : oracle
- **Shell** : bash
- **Database** : Oracle Database 11g Release 11.2.0.3.0 - Production

&nbsp;

## 해결법

### 1. Oracle 접속

oracle 계정으로 접속한다.

```bash
$ id
uid=501(oracle) gid=501(dba) groups=501(dba)
```

&nbsp;

sysdba 권한을 얻어 sys 계정 접속한다.

```bash
$ sqlplus sys as sysdba

SQL*Plus: Release 11.2.0.3.0 Production on Thu Sep 2 13:28:01 2021

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Enter password: <Password 입력>

Connected to:
Oracle Database 11g Release 11.2.0.3.0 - Production

SQL> 
```

`Connected to:` 메세지와 함께 Oracle DB에 정상 접속된 걸 확인할 수 있다.

&nbsp;

### 2. 계정의 프로필 확인

```sql
SQL> set linesize 200;
SQL> SELECT USERNAME, ACCOUNT_STATUS, PROFILE FROM DBA_USERS WHERE USERNAME='MAXGAUGE';

USERNAME                       ACCOUNT_STATUS                   PROFILE
------------------------------ -------------------------------- ------------------------------
MAXGAUGE                       EXPIRED                          DEFAULT
```
MAXGAUGE 계정이 만료된(`EXPIRED`) 상태이며, `Default` Profile 을 사용하는 걸 확인할 수 있다.

&nbsp;

### 3. 프로필 설정확인

```sql
SQL> SELECT * FROM DBA_PROFILES WHERE PROFILE='DEFAULT';
PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT
------------------------------ -------------------------------- -------- ----------------------------------------
DEFAULT                        COMPOSITE_LIMIT                  KERNEL   UNLIMITED
DEFAULT                        SESSIONS_PER_USER                KERNEL   UNLIMITED
DEFAULT                        CPU_PER_SESSION                  KERNEL   UNLIMITED
DEFAULT                        CPU_PER_CALL                     KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_SESSION        KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_CALL           KERNEL   UNLIMITED
DEFAULT                        IDLE_TIME                        KERNEL   UNLIMITED
DEFAULT                        CONNECT_TIME                     KERNEL   UNLIMITED
DEFAULT                        PRIVATE_SGA                      KERNEL   UNLIMITED
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 3
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 90
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD 356
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD 10
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD VERIFY_FUNCTION
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD 3
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 5
```

**암호 재사용 방지와 관련된 설정값**  
[Database SQL Reference - CREATE PROFILE](https://docs.oracle.com/cd/B19306_01/server.102/b14200/statements_6010.htm)

| Parameter 이름 | 설명 |
|-----------------------|--------|
| `PASSWORD_REUSE_TIME` | 주어진 날 수 동안 암호를 재사용할 수 없도록 지정. (PASSWORD_REUSE_TIME 값이 5일 경우, 5일 안에는 똑같은 암호를 사용할 수 없다.) |
| `PASSWORD_REUSE_MAX`  | 사용했던 암호를 기억하는 횟수. 사용했던 암호를 재사용하는 걸 방지하는 목적의 설정값. |

- 위 두 설정값은 사용자가 지정된 기간 동안 암호를 재사용하지 못하게 한다.
- 이 두 파라미터는 반드시 같이 설정해야 동작한다.

&nbsp;

### 4. 보안설정 해제

불가피하게 패스워드 재사용이 필요할 경우, 암호 재사용 방지와 관련된 설정값을 해제한다.  

- `PASSWORD_REUSE_TIME`과 `PASSWORD_REUSE_MAX` 파라미터를 모두 `UNLIMITED`로 설정하면 데이터베이스가 두 파라미터를 모두 무시한다.

&nbsp;

```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME UNLIMITED;

Profile altered.
```

`PASSWORD_REUSE_TIME` 파라미터를 비활성화한다.

&nbsp;

```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX UNLIMITED;

Profile altered.
```

`PASSWORD_REUSE_MAX` 파라미터를 비활성화한다.

&nbsp;

### 5. 패스워드 갱신

**명령어 형식**

```sql
SQL> ALTER USER <계정 이름> IDENTIFIED BY "<갱신할 패스워드>";
```

&nbsp;

**명령어 예시**

```sql
SQL> ALTER USER MAXGAUGE IDENTIFIED BY "change!me!please";

User altered.
```

새 패스워드로 갱신 완료되었다.

&nbsp;

### 6. 계정 상태 확인

```sql
SQL> SELECT USERNAME, ACCOUNT_STATUS, PROFILE FROM DBA_USERS WHERE USERNAME='MAXGAUGE';

USERNAME                       ACCOUNT_STATUS                   PROFILE
------------------------------ -------------------------------- ------------------------------
MAXGAUGE                       OPEN                             DEFAULT
```

`MAXGAUGE` 계정이 잠금해제<sup>`OPEN`</sup> 상태로 변경되었다.

&nbsp;

### 7. 보안설정 원복하기

패스워드 갱신을 완료했으면 해제했던 암호 재사용 방지 관련 설정값을 다시 돌려놓는다.

```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME 356;

Profile altered.
```

&nbsp;

```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX 10;

Profile altered.
```

&nbsp;

## 결론

불가피하게 패스워드 재사용이 필요할 경우 위 방법을 사용한다.  
그러나 무분별한 패스워드 재사용은 보안 취약점이다.  
번거롭더라도 완전히 새로운 패스워드로 갱신하는 것이 안전하며 정상적인 조치 방법이다.
