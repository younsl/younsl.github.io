---
title: "Oracle processes 파라미터 변경"
date: 2021-10-06T23:48:09+09:00
lastmod: 2022-08-25T12:35:05+09:00
slug: ""
description: "ORA-12516 에러를 해결하기 위해 Oracle processes 값을 변경하고 적용하는 방법을 설명합니다."
keywords: []
tags: ["database", "oracle"]
---

## 개요

ORA-12516 에러를 해결하기 위해 Oracle DB 리소스 파라미터의 Processes 값을 변경하고 적용할 수 있습니다.

&nbsp;

## 환경

문제가 발생한 Oracle DB 서버의 정보는 다음과 같습니다.

- **OS** : Red Hat Enterprise Linux Server release 5.5 (Tikanga)
- **Shell** : bash
- **DB** : Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - Production

&nbsp;

## 증상

```sql
SQL> select count(*) from adm.share_table@link_datanet
                                     *
ERROR at line 1:
ORA-12516: TNS:listener could not find available handler with matching protocol
stack
```

다른 서버에서 문제가 발생한 서버에 DB Link 조회시 에러 메세지를 반환해 조회할 수 없는 문제입니다.

&nbsp;

## 원인

`ORA-12516: TNS:listener could not find available handler with matching protocol stack` 에러가 발생하는 가장 대표적인 원인은 오라클 DB에 붙을 수 있는 프로세스 혹은 세션의 개수가 최대치에 도달했기 때문입니다.  

이미 접속되어 있는 세션은 잘 동작하지만 새로운 프로그램이 DB에 접속할 때 DB는 이미 자신이 허용할 수 있는 연결의 최대치에 도달했기 때문에 에러를 반환하고 연결 실패가 발생합니다.

&nbsp;

## 조치방법

### 1. sqlplus 접속

`sysdba` 권한으로 Oracle DB에 로그인합니다.  
별도의 RDBMS 툴로 DB를 관리하는 환경이라면 1번 과정은 건너뛰어도 됩니다.

```sql
$ sqlplus / as sysdba

SQL*Plus: Release 10.2.0.4.0 - Production on Wed Oct 6 11:00:47 2021

Copyright (c) 1982, 2007, Oracle.  All Rights Reserved.

Connected to:
Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL>
```

&nbsp;

### 2. 리소스 파라미터 확인

```sql
SQL> SET LINESIZE 200;
SQL> SELECT * FROM V$RESOURCE_LIMIT;

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
processes                                      247             250        250                  250
sessions                                       250             255        280                  280
enqueue_locks                                   20              37       3840                 3840
enqueue_resources                               21              81       1452            UNLIMITED
ges_procs                                        0               0          0                    0
ges_ress                                         0               0          0            UNLIMITED
ges_locks                                        0               0          0            UNLIMITED
ges_cache_ress                                   0               0          0            UNLIMITED
ges_reg_msgs                                     0               0          0            UNLIMITED
ges_big_msgs                                     0               0          0            UNLIMITED
ges_rsv_msgs                                     0               0          0                    0

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
gcs_resources                                    0               0          0                    0
gcs_shadows                                      0               0          0                    0
dml_locks                                        0              79       1232            UNLIMITED
temporary_table_locks                            0               3  UNLIMITED            UNLIMITED
transactions                                     3              21        308            UNLIMITED
branches                                         2              18        308            UNLIMITED
cmtcallbk                                        0               2        308            UNLIMITED
sort_segment_locks                               0               5  UNLIMITED            UNLIMITED
max_rollback_segments                           12              15        308                65535
max_shared_servers                               1               1  UNLIMITED            UNLIMITED
parallel_max_servers                             0               0        160                 3600
```

`processes` 값이 최대 250개 중 현재 247을 사용중입니다.

&nbsp;

#### processes와 sessions 리소스

- `processes`는 동시에 Oracle에 연결할 수 있는 OS 사용자 프로세스의 최대 수를 지정하는 값입니다.
- `processes` 값에는 백그라운드 프로세스, Job 프로세스, 병렬 실행 프로세스 등의 수가 포함됩니다.
- `processes` 값을 변경하면 `sessions` 값도 (`processes` x 1.1) + 5 로 자동계산된 후 설정됩니다.

  ```bash
  # Example 1
  processes = 200
  sessions  = 200 x 1.1 + 5 = 225

  # Example 2
  processes = 400
  sessions  = 400 x 1.1 + 5 = 445
  ```

&nbsp;

### 3. spfile 존재유무 확인

```sql
SQL> SHOW PARAMETER SPFILE;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /oracle/10g/dbs/spfiledba.ora
```

#### spfile

- spfile은 Server Parameter File의 약자로 데이터베이스 관련 파라미터 설정 파일입니다.
- spfile은 Oracle 9i 버전부터 지원되는 기능이므로 존재하지 않는다면 DB 버전을 확인합니다.
- spfile은 `ALTER SYSTEM` 명령어를 통해 운영중에 파라미터를 수정 할 수 있습니다. spfile의 장점은 서버를 재시작하지 않고 운영중에 변경사항을 반영 가능하다는 점입니다.
- spfile은 기본적으로 binary 파일이기 때문에 텍스트 편집기(vi editor, nano 등)를 이용해 수정하면 다시 사용할 수 없습니다.

&nbsp;

### 4. spfile 설정 확인

spfile은 binary 형식의 파일이므로 `cat` 명령어가 아닌 `strings` 명령어를 사용해 내용을 확인합니다.

```bash
$ strings /oracle/10g/dbs/spfiledba.ora
```

&nbsp;

실행한 결과입니다.

```bash
...
*.open_cursors=300
*.pga_aggregate_target=241172480
*.processes=250
*.remote_login_passwordfile='EXCLUSIVE'
*.resource_limit=TRUE
*.resource_manager_plan=''
*.service_names='dba','DBA.REGRESS.RDBMS.DEV.US.ORACLE.COM'
*.sga_target=608174080
*.undo_management='AUTO'
*.undo_retention=900
*.undo_tablespace='UNDOTBS1'
*.user_dump_dest='/oracle/admin/dba/udump'
*.utl_file_dir='/BACKUP/logminer'
```

spfile 내용을 확인해본 결과, 현재 설정된 `*.processes` 값이 `250`입니다.

&nbsp;

### 5. 리소스 파라미터 수정

#### 명령어 형식

```bash
SQL> alter system set processes=<INT> scope=spfile;
```

&nbsp;

#### 실제 명령어

`processes` 값을 250에서 400으로 변경합니다.

```bash
SQL> alter system set processes=400 scope=spfile;

System altered.
```

`System altered` 메세지가 출력되면 정상 적용된 것입니다.

&nbsp;

### 6. spfile 변경 확인

```bash
$ strings /oracle/10g/dbs/spfiledba.ora
...
*.open_cursors=300
*.pga_aggregate_target=241172480
*.processes=400
*.remote_login_passwordfile='EXCLUSIVE'
*.resource_limit=TRUE
*.resource_manager_plan=''
*.service_names='dba','DBA.REGRESS.RDBMS.DEV.US.ORACLE.COM'
*.sga_target=608174080
*.undo_management='AUTO'
*.undo_retention=900
*.undo_tablespace='UNDOTBS1'
*.user_dump_dest='/oracle/admin/dba/udump'
*.utl_file_dir='/BACKUP/logminer'
```

`processes` 값이 400으로 변경되었습니다.

&nbsp;

### 7. DB 재기동

#### 중지 명령어

```sql
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
```

`ORACLE instance shut down.` 메시지가 출력되면 정상적으로 Oracle DB 인스턴스가 종료된 것입니다.

&nbsp;

#### 기동 명령어

```sql
SQL> startup;
ORACLE instance started.

Total System Global Area  608174080 bytes
Fixed Size                  1268896 bytes
Variable Size             373293920 bytes
Database Buffers          226492416 bytes
Redo Buffers                7118848 bytes
Database mounted.
Database opened.
```

&nbsp;

### 8. 리소스 파라미터 변경 확인

```sql
SQL> SET LINESIZE 200;
SQL> SELECT * FROM V$RESOURCE_LIMIT;

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
processes                                       77              86        400                  400
sessions                                        80              89        445                  445
enqueue_locks                                   19              30       5790                 5790
enqueue_resources                               19              48       2176            UNLIMITED
ges_procs                                        0               0          0                    0
ges_ress                                         0               0          0            UNLIMITED
ges_locks                                        0               0          0            UNLIMITED
ges_cache_ress                                   0               0          0            UNLIMITED
ges_reg_msgs                                     0               0          0            UNLIMITED
ges_big_msgs                                     0               0          0            UNLIMITED
ges_rsv_msgs                                     0               0          0                    0

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
gcs_resources                                    0               0          0                    0
gcs_shadows                                      0               0          0                    0
dml_locks                                        0              51       1956            UNLIMITED
temporary_table_locks                            0               3  UNLIMITED            UNLIMITED
transactions                                     0              11        489            UNLIMITED
branches                                         0               8        489            UNLIMITED
cmtcallbk                                        0               1        489            UNLIMITED
sort_segment_locks                               0               3  UNLIMITED            UNLIMITED
max_rollback_segments                           13              13        489                65535
max_shared_servers                               1               1  UNLIMITED            UNLIMITED
parallel_max_servers                             0               0        160                 3600

22 rows selected.
```

`processes` 리소스의 `LIMIT_VALUE` 값이 250에서 400으로 변경되었습니다.  
`processes` 파라미터의 영향을 받는 `sessions` LIMIT_VALUE 값도 (`processes` x 1.1) + 5 의 결과인 445로 변경되었습니다.

&nbsp;

## 참고자료

[ORA-12516 tips](http://www.dba-oracle.com/t_ora_12516-tns_ould_not_find_available_handler.htm)  
2015년 2월 자료이나 ORA-12516 에러에 대한 원인, 해결방법을 얻을 수 있습니다.
