---
title: "오라클 아카이브 로그 활성화 설정"
date: 2021-10-25T00:11:25+09:00
lastmod: 2022-03-22T20:15:10+09:00
slug: ""
description: "Oracle Database에서 Archive Log를 활성화하는 방법을 설명합니다."
keywords: []
tags: ["database", "oracle"]
---

## 개요

Oracle DB에서 아카이브 로그(Archive Log)를 사용하도록 모드를 변경한다.

<br>

## 환경

- **OS** : HP-UX B.11.31
- **Shell** : sh (POSIX shell)
- **DB** : Oracle Database 10g

<br>

## 해결법

### 1. DB 로그인

```bash
$ sqlplus / as sysdba
```

oracle 계정에서 sysdba 권한으로 Oracle Database에 로그인합니다.

&nbsp;

### 2. 아카이브 로그 설정 확인

```sql
SQL> archive log list
Database log mode            No Archive Mode
Automatic archival           Disabled
Archive destination          /oracle/arch
Oldest online log sequence   7989
Current log sequence         7991
```

현재 `Database log mode`는 `No Archive Mode`로 아카이브 로그를 사용하지 않는 상태를 의미한다.

`No Archive Mode`를 `Archive Mode`로 활성화 해주기 위해서는 SQL alter문으로 설정을 변경한 후 DB 인스턴스의 재기동이 필요하다.

&nbsp;

#### No Archive Mode vs Archive Mode

**No Archive Log Mode**는 Oracle Database 설치시 기본값이며, 몇 개의 redo 로그 파일을 돌려서 변경사항을 기록해두는 방식이다. 따라서, 일정 갯수의 redo 로그 파일 이전의 변경기록은 보관하지 않고 밀려나 사라지게 된다.

**Archive Mode**는 이와 달리 redo 파일에 변경사항을 다 쓴후 파일에 덮어쓰기 전에 이전 파일을 다른 곳에 복사해 보관해두는 방식이다. 따라서 용량만 여유가 있다면 모든 변경사항이 덮어쓰여지지 않고 보관된다.

&nbsp;

### 3. DB 종료 후 mount

```sql
SQL> shutdown immediate;
```

DB를 내려준다.

```sql
SQL> startup mount;
ORACLE instance started.
[...]
Database mounted.
```

`Database altered.` 메세지가 떨어지면 정상적으로 실행된 것이다.  

실제 운영 DB에서 `startup mount` 실행시 소요시간이 5~10분 걸릴 수 있다.

&nbsp;

### 4. 아카이브 로그 설정 변경

```sql
SQL> alter database archivelog;

Database altered.
```

아카이브 로그를 사용하도록 설정하는 alter문이다.  
`Database altered.` 메세지가 떨어지면 정상적으로 실행된 것이다.

&nbsp;

### 5. DB open

DB를 open 상태로 변경한다.

```sql
SQL> alter database open;

Database altered.
```

&nbsp;

### 6. 작업 결과확인

**Database log mode 확인**

```sql
SQL> archive log list
Database log mode              Archive Mode
[...]
```

`Database log mode` 값이 `No Archive Mode`에서 `Archive Mode` 로 변경되었다.

&nbsp;

**Instance 상태 확인**

```sql
SQL> SELECT instance_name, status FROM v$instance;

INSTANCE_NAME      STATUS
------------------ ------------
DEV                OPEN
```

DB 인스턴스의 상태값(`STATUS`)이 OPEN 일 경우 정상이다.

이것으로 작업 완료.
