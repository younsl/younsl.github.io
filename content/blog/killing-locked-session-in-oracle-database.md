---
title: "오라클 세션 확인하고 Kill"
date: 2021-09-08T20:48:20+09:00
lastmod: 2022-12-25T00:47:22+09:00
slug: ""
description: "락 걸린 오라클 세션을 확인한 후 강제종료(Kill) 조치하는 방법"
keywords: []
tags: ["database", "oracle"]
---

## 개요

오라클 DB에서 세션 상태를 확인하고 Lock이 발생한 비정상적인 DB 세션을 강제종료(Kill)할 수 있다.

&nbsp;

## 작성배경

가끔씩 운영중인 DB서버에서 Application 에러로 Query가 비정상적으로 반복실행되면서 시스템 부하가 급증하는 상황이 발생한다.  
어느날 개발자로부터 세션 강제종료(Kill) 조치 요청이 들어와 조치한 기록이다.

&nbsp;

## 환경

- **OS** : HP-UX B.11.31
- **ID** : oracle
- **Shell** : sh
- **Database** : Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production

&nbsp;

## 작업절차

### 1. oracle 계정 접속

oracle 계정으로 먼저 로그인해야 한다.

```sh
$ su - oracle
```

&nbsp;

### 2. DB 접속

sysdba 권한으로 Oracle DB에 접속한다.

```sh
$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Wed Sep 8 15:46:26 2021

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production

SQL>
```

&nbsp;

### 3. DB 세션 상태확인

**Oracle Session**

```
Client Device                     Database Server
┌───────────────────┐             ┌────────────────────────────────────────┐
│                   │   Acess     │                                        │
│ ┌───────────────┐ │   Request   │  ┌───────────────┐  ┌───────────────┐  │
│ │ Client        ├─┼───(1)───────┼──► Oracle        │  │ Client        │  │
│ │ Application   │ │             │  │ Listener      │  │ Application   │  │
│ └─────────────▲─┘ │             │  └───────┬───────┘  └───────▲───────┘  │
│               │   │             │          │                  │  Session │
└───────────────┼───┘             │         (2) Create         (1) established
                │     Session     │          │  Process         │  Local Connection
                │     established │  ┌───────▼───────┐  ┌───────▼───────┐  │
                └───────(3)───────┼──► Server        │  │ Server        │  │
                      Remote      │  │ Process       │..│ Process       │  │
                      Connection  │  └───────────────┘  └───────────────┘  │
                                  │                                        │
                                  └────────────────────────────────────────┘
```

- Oracle 데이터베이스는 사용자와 데이터베이스 접속이 이루어지면 세션을 생성한다.
- 세션은 사용자가 데이터베이스에 연결되어 있는 동안 계속 유지되고, 각 세션에는 Session ID(`SID`)와 Serial 번호(`Serial#`)가 부여된다.
- Session ID(`SID`)와 Serial 번호(`Serial#`)가 같이 부여되는 이유는 Session이 종료되었으나, 다른 세션이 동일한 SID를 갖고 시작되었을 때 세션 명령들이 정확한 세션에 적용될 수 있도록 하기 위해서이다.
- 세션이 사용자에 의해 작업중이라면 `ACTIVE` 상태로 작업을 하게된다.  
  `INACTIVE` 상태는 세션은 연결되어있지만 작업을 하고있지 않는 상태를 의미한다.

&nbsp;

**명령어 형식**

```sql
SELECT SID, SERIAL#, USERNAME, PROGRAM, STATUS
FROM V$SESSION
WHERE SID='<SID>';
```

&nbsp;

**실행 명령어**

```sql
SQL> SELECT SID, SERIAL#, USERNAME, PROGRAM, STATUS
  2  FROM V$SESSION
  3  WHERE SID='657';

       SID    SERIAL# USERNAME                       PROGRAM                                          STATUS
---------- ---------- ------------------------------ ------------------------------------------------ --------
       657      13469 DEV                            SQL Developer                                    ACTIVE

Elapsed: 00:00:00.01
```

&nbsp;

### 4. DB 세션 강제종료(Kill)

세션을 강제로 끊어버리기 위해서는 Session ID(`SID`)와 Serial 번호(`SERIAL#`) 정보가 필요하다.

&nbsp;

**명령어 형식**

```sql
ALTER SYSTEM KILL SESSION '<SID>, <SERIAL#>';
```

&nbsp;

**실행 명령어**

```sql
SQL> ALTER SYSTEM KILL SESSION '657, 13469';

System altered.

Elapsed: 00:00:01.01
```

세션 강제종료(Kill)가 정상적으로 실행되었다.

&nbsp;

### 5. DB 세션 재확인

13469번 Serial Number(`SERIAL#`)를 가진 세션이 사라진 걸 확인할 수 있다.

```sql
SQL> SELECT SID, SERIAL#, USERNAME, PROGRAM, STATUS
  2  FROM V$SESSION
  3  WHERE SID='657';

       SID    SERIAL# USERNAME                       PROGRAM                                          STATUS
---------- ---------- ------------------------------ ------------------------------------------------ --------
       657      13478 DEV                            oracle@devdb1 (TNS V1-V3)                        INACTIVE

Elapsed: 00:00:00.00
```

조치 완료.
