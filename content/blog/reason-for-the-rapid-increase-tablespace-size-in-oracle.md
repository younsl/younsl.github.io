---
title: "Oracle 테이블스페이스 용량 급증의 원인"
date: 2021-12-29T22:22:10+09:00
lastmod: 2021-12-29T22:22:15+09:00
slug: ""
description: "Oracle 테이블스페이스의 용량이 급증한 원인을 찾아보자."
keywords: []
tags: ["os", "linux", "database", "oracle"]
---

# 발단

2주라는 짧은 기간동안 특정 테이블스페이스의 사용률이 65%에서 90%로 급증했다.

<br>

# 환경

- **Architecture** : x86_64  
- **Database** : Oracle Database 12c Standard Edition Release 12.x.x.x.x  
- **Shell** : bash  
- **sqlplus** : sqlplus 실행시 관리자 권한(sys) 필요

<br>

# 원인

이미지 파일이나 음성 등의 비정형 데이터를 담는 LOBSEGMENT 사이즈의 증가가 원인이었다.  

테이블스페이스의 용량 산정에 오류가 발생한 것이 아니라, 정말로 용량이 늘어난 것이다.  

<br>

### LOB 데이터

LOB이란 Large Object의 약자로, 대용량 데이터를 저장하고 관리하기 위해 오라클에서 제공하는 기본 데이터 타입이다.  

LOB 데이터는 사진, 음성, 이미지 등 비구조화된 큰 용량의 파일을 저장하기 때문에 일반 `SELECT ... FROM ...` SQL문으로는 조회가 불가능하다.  

<br>

**LOB의 종류 (Types of LOBs)**
- **CLOB** : Character Large Objects 의 약자. 문자 대형객체(Character), Oracle은 CLOB과 VARCHAR2 사이에 암시적 변환을 수행함.
- **BLOB** : Binary Large Objects 의 약자. 이진 대형객체(Binary), 이미지, 동영상, MP3 등
- **NCLOB** : Nation Character Large Objects 의 약자. 내셔널 문자 대형객체, Oracle에서 정의되는 National Character set을 따르는 문자
- **BFILE** : Binary File Objects 의 약자. OS에 저장되는 이진 파일의 이름과 위치를 저장. 읽기 전용(Read Only) 모드로만 액세스 가능

<br>

# 확인방법

특정 테이블스페이스의 용량 분석 과정은 아래와 같다. 

### 1. 테이블별 용량 확인

**입력 명령어**

```sql
-- SQL 실행결과를 가독성 있게 잘 정렬해서 출력하는 부분
SET LINESIZE 300;

-- 실제 수행 SQL문
SELECT TOTAL.TABLESPACE_NAME, ROUND(TOTAL.MB, 2) AS TOTAL_MB, ROUND(TOTAL.MB - FREE.MB, 2) AS USED_MB, ROUND((1 - FREE.MB / TOTAL.MB) * 100, 2) || '%' AS USED_PER
FROM (SELECT TABLESPACE_NAME, SUM(BYTES)/1024/1024 AS MB FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME) FREE, (SELECT TABLESPACE_NAME, SUM(BYTES)/1024/1024 AS MB FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) TOTAL
WHERE FREE.TABLESPACE_NAME = TOTAL.TABLESPACE_NAME ORDER BY USED_PER DESC;
```

<br>

**명령어 결과**

```sql
TABLESPACE_NAME                  TOTAL_MB    USED_MB USED_PER

------------------------------ ---------- ---------- -----------------------------------------

SYSTEM                               1320    1310.06 99.25%
UNDOTBS1                             1320    1227.88 93.02%
SYSAUX                                900     731.69 81.3%
USERS                                   5          4 80%
SECRET                              30720   24201.69 78.78%
SECRET_IDX                          10240       6.56 .06%

6 행이 선택되었습니다.
```

문의 오기 전에 이미 개발자 요청에 의해서 SECRET 테이블스페이스에 5GB를 추가해서 사이즈를 30GB로 늘린 상황이다.

<br>

### 2. 개발자의 문의

테이블스페이스의 사용률을 낮춰서 안전하게 조치는 끝났다.  

하지만 이후 개발자는 근본적인 테이블스페이스 용량 급증의 원인을 물어봤다.  

<br>

**Developer** : "왜 SECRET 테이블스페이스의 용량이 급증한걸까요?"  
**Sysadmin (me)** : (그건 저도 의문입니다.)  

이제 본격적으로 테이블스페이스에 연결된 테이블별 용량을 확인하는 단계로 들어간다.  

<br>

### 3. 테이블스페이스 용량 확인 (SQL)

**입력 명령어**

```sql
-- SQL 실행결과를 가독성 있게 잘 정렬해서 출력하는 부분
SET LINESIZE 300;
SET PAGES 1000;
COL FILE_NAME FOR A50;

-- 실제 수행 SQL문
SELECT TABLESPACE_NAME, FILE_NAME, ROUND(BYTES/1024/1024/1024, 2) AS GB, ROUND(MAXBYTES/1024/1024/1024, 2) AS MAXGB, AUTOEXTENSIBLE
FROM DBA_DATA_FILES;
```

<br>

**명령어 결과**

```sql
TABLESPACE_NAME                FILE_NAME                                                  GB      MAXGB AUT

------------------------------ -------------------------------------------------- ---------- ---------- ---

SYSTEM                         /data/SECRETDB/system01.dbf                              1.29         32 YES
SYSAUX                         /data/SECRETDB/sysaux01.dbf                               .88         32 YES
UNDOTBS1                       /data/SECRETDB/undotbs01.dbf                             1.29         32 YES
USERS                          /data/SECRETDB/users01.dbf                                  0         32 YES
SECRET                         /data/SECRET                                               30         31 YES
SECRET_IDX                     /data/SECRET_IDX                                           10         20 YES

6 행이 선택되었습니다.
```

SECRET 테이블스페이스의 데이터 파일은 `/data/SECRET`에 위치해있고, 현재 할당된 용량은 30GB이다.  

<br>

### 4. 테이블스페이스 용량 확인 (OS)

```bash
$ ls -lh /data/SECRET
-rw-r----- 1 oracle dba 31G 12월 29 09:22 /data/SECRET
```

`ls -lh` 명령어로 확인해본 결과도 sqlplus에서 확인한 결과처럼 동일하게 31GB이다.  

<br>

### 5. 테이블스페이스에 속한 테이블 조회

**입력 명령어**

```sql
-- SQL 실행결과를 가독성 있게 잘 정렬해서 출력하는 부분
COL OWNER FOR A10;
COL TABLE_NAME FOR A20;

-- 실제 수행 SQL문
SELECT OWNER, TABLE_NAME, TABLESPACE_NAME
FROM DBA_TABLES
WHERE TABLESPACE_NAME='SECRET';
```

<br>

**명령어 결과**

```sql
OWNER      TABLE_NAME           TABLESPACE_NAME

---------- -------------------- ------------------------------

DEVXXX     XXXXX_XXX            SECRET
DEVXXX     XXXX_XXXXX_TBL       SECRET
DEVXXX     XXXXXXX_TBL          SECRET
DEVXXX     XXXXXXX_XXXX_TBL     SECRET
DEVXXX     XXXX_XXXXX_TBL       SECRET
DEVXXX     XXXX_XXX_TBL         SECRET
DEVXXX     XXXXXX_XXXXX_TBL     SECRET

7 행이 선택되었습니다.
```

`SECRET` 테이블스페이스에는 7개의 테이블이 속한다.  

<br>

### 6. 테이블별 용량 조회

**입력 명령어**

```sql
-- SQL 실행결과를 가독성 있게 잘 정렬해서 출력하는 부분
SET PAGESIZE 1000;
SET LINESIZE 1000;
COL OWNER FOR A10;
COL SEGMENT_TYPE FOR A15;
COL SEGMENT_NAME FOR A30;
COL TABLESPACE_NAME FOR A15;

-- 실제 수행 SQL문
SELECT OWNER, SEGMENT_TYPE, SEGMENT_NAME, TABLESPACE_NAME, BYTES/1024/1024 MB
FROM DBA_SEGMENTS
WHERE TABLESPACE_NAME='SECRET' ORDER BY MB DESC;
```

**SQL문 상세 설명**  

- `ORDER BY MB DESC` : MB 단위로 내림차순 정렬  
- `WHERE TABLESPACE_NAME='<테이블스페이스 이름>'` : 특정 테이블스페이스와 관련된 테이블, LOB 객체들만 검색한다.  

<br>

**명령어 결과**

```sql
OWNER      SEGMENT_TYPE    SEGMENT_NAME                   TABLESPACE_NAME         MB

---------- --------------- ------------------------------ --------------- ----------

DEVXXX     LOBSEGMENT      SYS_LOB0000233727C00003$$      SECRET           24190.125
DEVXXX     TABLE           XXXX_XXX_XXX                   SECRET                   5
DEVXXX     TABLE           XXXXXXX_XXX                    SECRET                   3
DEVXXX     INDEX           XXXX_XXX_XXX_PK                SECRET                   1
DEVXXX     TABLE           XXXXX_XXX                      SECRET                   1
DEVXXX     LOBSEGMENT      SYS_LOB0000083246C00003$$      SECRET                .125
DEVXXX     TABLE           XXXXXXX_XXXX_XXX               SECRET                .125
DEVXXX     LOBINDEX        SYS_IL0000233727C00003$$       SECRET               .0625
DEVXXX     TABLE           XXXX_XXXXX_XXX                 SECRET               .0625
DEVXXX     TABLE           XXXX_XXXXX_XXX                 SECRET               .0625
DEVXXX     LOBINDEX        SYS_IL0000083246C00003$$       SECRET               .0625
DEVXXX     TABLE           XXXXXXX_XXXX_XXX               SECRET               .0625

12 행이 선택되었습니다.
```

**확인결과**  
`LOBSEGMENT` 타입인 `SYS_LOB0000233727C00003$$`의 용량이 24190MB(=23.6GB)로 늘어난 상태인걸 확인할 수 있다.  
일반적인 테이블(`TABLE` TYPE)들은 정형 데이터를 보관하고 있기 때문에 5MB 이하의 용량이다.  
그러나 `LOBSEGMENT`는 다른 테이블들과 용량 비교를 했을 때 독보적으로 큰 용량임을 알 수 있다.  
