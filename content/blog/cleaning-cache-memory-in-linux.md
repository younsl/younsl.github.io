---
title: "리눅스 캐시 메모리 비우기"
date: 2021-10-28T18:31:20+09:00
lastmod: 2022-08-13T22:24:10+09:00
slug: ""
description: "리눅스 서버에서 명령어를 통해 캐시 메모리를 비우고 여유 메모리를 확보하는 방법을 설명합니다."
keywords: []
tags: ["os", "linux", "hardware"]
---

## 개요

리눅스 서버에서 명령어를 통해 캐시 메모리를 정리해 여유 메모리를 확보할 수 있다.

&nbsp;

## 환경

- **OS** : Red Hat Enterprise Linux Server release 5.x
- **Shell** : bash

&nbsp;

## 해결법

### 1. 메모리 사용량 요약 확인

```bash
$ free -g
             total       used       free     shared    buffers     cached
Mem:            62         62          0          0          0         55
-/+ buffers/cache:          6         56
Swap:           62          3         59
```

전체 메모리(`total`) 62GB 중 55GB가 캐시 메모리(`cached`)로 잡혀있다.

&nbsp;

### 2. 메모리 사용량 상세 확인

#### 기본 단위(kB)로 보기

```bash
$ cat /proc/meminfo | column -t
MemTotal:         66004284     kB
MemFree:          211724       kB
Buffers:          759392       kB
Cached:           58053888     kB
SwapCached:       2245728      kB
Active:           11509948     kB
Inactive:         53444952     kB
HighTotal:        0            kB
HighFree:         0            kB
LowTotal:         66004284     kB
LowFree:          211724       kB
SwapTotal:        65537156     kB
SwapFree:         62276916     kB
Dirty:            1056         kB
Writeback:        0            kB
AnonPages:        6139572      kB
Mapped:           42920        kB
Slab:             668696       kB
PageTables:       36240        kB
NFS_Unstable:     0            kB
Bounce:           0            kB
CommitLimit:      98539296     kB
Committed_AS:     11802812     kB
VmallocTotal:     34359738367  kB
VmallocUsed:      295112       kB
VmallocChunk:     34359442931  kB
HugePages_Total:  0
HugePages_Free:   0
HugePages_Rsvd:   0
Hugepagesize:     2048         kB
```

`column -t` : 출력결과를 칸에 맞게 정렬해서 가독성을 높여주는 명령어  
확인결과 전체 메모리(`MemTotal`)의 87%가 캐시 메모리(`Cached`)로 잡혀있다.

&nbsp;

#### GB 단위로 보기

kB 단위로 보는게 불편하면 GB 단위로 변환시켜 볼 수도 있다.

```bash
$ awk '$3=="kB"{$2=$2/1024/1024;$3="GB"} 1' /proc/meminfo | column -t
MemTotal:         62.9466     GB
MemFree:          0.191048    GB
Buffers:          0.724033    GB
Cached:           55.3696     GB
SwapCached:       2.14169     GB
Active:           10.6456     GB
Inactive:         51.3047     GB
HighTotal:        0           GB
HighFree:         0           GB
LowTotal:         62.9466     GB
LowFree:          0.191048    GB
SwapTotal:        62.5011     GB
SwapFree:         59.3919     GB
Dirty:            0.00088501  GB
Writeback:        0           GB
AnonPages:        5.8541      GB
Mapped:           0.0409317   GB
Slab:             0.636795    GB
PageTables:       0.0345459   GB
NFS_Unstable:     0           GB
Bounce:           0           GB
CommitLimit:      93.9744     GB
Committed_AS:     11.3072     GB
VmallocTotal:     32768       GB
VmallocUsed:      0.281441    GB
VmallocChunk:     32767.7     GB
HugePages_Total:  0
HugePages_Free:   0
HugePages_Rsvd:   0
Hugepagesize:     0.00195312  GB
```

전체 메모리(`MemTotal`) 64GB 중에서 캐시 메모리(`Cached`)를 55GB 쓰고, 버퍼 메모리(`Buffers`)는 0.7GB 사용중.  
여유 메모리(`MemFree`) 값이 0.1GB로 너무 낮다.

&nbsp;

### 3. 캐시 메모리 정리

#### 메모리 사용량 모니터링

캐시 메모리 정리 전에 <u>메모리 사용량 변화를 모니터링 하기 위해</u> 세션을 하나 더 띄워서 `watch -d -n1 "free -g"` 명령어를 실행한다.

```bash
$ watch -d -n1 "free -g"
```

1초 간격으로 `free -g` 명령어를 실행하는 명령어.  
`-d` 옵션은 변경된 값을 하이라이팅 해서 가독성을 높여준다.  

&nbsp;

#### sync

```bash
$ sync
```

캐시 메모리에 있는 변동사항을 하드디스크에 옮겨서 쓰기(Write)

&nbsp;

#### 캐시 메모리 정리

```bash
$ echo 3 > /proc/sys/vm/drop_caches
```

캐시 메모리를 정리한다. 정리대상은 pagecache, dentry, inode 이다.  

캐시 메모리 정리 소요시간은 서버 환경과 캐시 메모리 용량에 따라 다른데 보통 10초 안으로 정리가 완료된다.

&nbsp;

##### 용어설명

- **pagecache** : 파일의 입출력(I/O)의 속도와 퍼포먼스를 높이기 위해 시스템이 할당한 메모리 영역(임시 메모리 저장소). 예를 들어 어떤 경로의 파일을 한 번 읽어들이면 시스템이 해당 파일 내용을 임시메모리에 저장시키는데 이후에 해당 파일을 다시 읽을 때 이를 새로 읽어들이지 않고 이 메모리에서 바로 불러오면 디스크의 읽기/쓰기 속도가 빨라지므로 효율이 높아짐. 윈도우 OS의 페이지 파일 같은 역할.
- **dentry** : directory entry의 줄임말로 예를 들어 /usr/share 같은 경로에서 usr과 share를 지칭.
- **inode** : 파일과 디렉토리에 관한 정보를 담고 있는 자료구조. 예를 들어 파일의 퍼미션 정보, 디스크 상의 파일의 물리적 위치, 크기, 생성된 일시 정보 등을 저장.

&nbsp;

##### drop_caches 의미

```bash
$ echo 1 > /proc/sys/vm/drop_caches  # To free pagecache
$ echo 2 > /proc/sys/vm/drop_caches  # To free dentries and inodes
$ echo 3 > /proc/sys/vm/drop_caches  # To free pagecache, dentries and inodes
```

&nbsp;

### 4. 메모리 반환 결과 확인

#### 메모리 사용량 요약 확인

```bash
$ free -g                                                                                                       
             total       used       free     shared    buffers     cached
Mem:            62         12         50          0          0          5
-/+ buffers/cache:          6         56
Swap:           62          3         59
```

`-g` : GB 단위로 보여준다.

&nbsp;

#### 메모리 사용량 상세 확인

```bash
$ awk '$3=="kB"{$2=$2/1024/1024;$3="GB"} 1' /proc/meminfo | column -t
MemTotal:         62.9466     GB
MemFree:          48.9179     GB
Buffers:          0.0405312   GB
Cached:           7.78165     GB
SwapCached:       2.14169     GB
Active:           8.87233     GB
Inactive:         4.87525     GB
HighTotal:        0           GB
HighFree:         0           GB
LowTotal:         62.9466     GB
LowFree:          48.9179     GB
SwapTotal:        62.5011     GB
SwapFree:         59.3919     GB
Dirty:            0.00118637  GB
Writeback:        0           GB
AnonPages:        5.92254     GB
Mapped:           0.0409355   GB
Slab:             0.11797     GB
PageTables:       0.0352592   GB
NFS_Unstable:     0           GB
Bounce:           0           GB
CommitLimit:      93.9744     GB
Committed_AS:     11.2496     GB
VmallocTotal:     32768       GB
VmallocUsed:      0.281441    GB
VmallocChunk:     32767.7     GB
HugePages_Total:  0
HugePages_Free:   0
HugePages_Rsvd:   0
Hugepagesize:     0.00195312  GB
```

&nbsp;

#### 메모리 전후 비교표

버퍼 메모리는 작업전부터 크기가 작아 효과가 그리 체감되지는 않지만 94% 줄였고, 캐시 메모리는 87% 줄였다.

| 구분     | 버퍼 메모리    | 캐시 메모리  |
|:------:|:------------:|:---------:|
| Before | 0.7 [GB]     | 55 [GB]   |
| After  | 0.04 [GB]    | 7 [GB]    |

&nbsp;

### 5. 캐시 메모리 스케줄링 등록

시스템 엔지니어가 매번 수동으로 캐시 메모리를 정리하는 건 번거롭고 불가능하니, 서버가 알아서 자동 정리할 수 있도록 crontab에 캐시 메모리 정리 스케줄을 등록해준다.  
반드시 root 계정에서 crontab을 등록해야한다.

> 서버에 부하가 많은 시점에 `drop_cache` 값에 3을 부여하는 행위는 서버 멈춤 현상을 유발할 수 있다. 따라서 캐시 메모리 정리 스케줄링 등록 시 실행시간은 부하(Load)가 적은 새벽 시간대로 설정해야만 한다.

#### Cron 커닝페이퍼(Cheatsheet)

```bash
# * * * * * command to be executed
# - - - - -
# | | | | |
# | | | | +----> Day of Week  (0 - 6) (0 = Sunday ... 6 = Saturday)
# | | | +------> Month        (1 - 12)
# | | +--------> Day of Month (1 - 31)
# | +----------> Hour         (0 - 23)
# +------------> Minute       (0 - 59)
```

crontab을 작성하는 일이 그리 빈번히 발생하는 편이 아니기 때문에 가끔 헷갈릴 때가 있다.  
crontab 윗줄에 주석처리된 커닝페이퍼를 달아놓으면 작업시 눈 앞에 바로 참고자료가 있기 때문에 편리한 서버 관리가 가능하다.  

&nbsp;

#### 스케줄링 등록

```bash
$ crontab -e
0 3 * * * sync && echo 3 > /proc/sys/vm/drop_caches
```

`-e` : crontab을 편집한다.

매일 새벽 3시마다 캐시 메모리를 정리하는 명령어를 실행한다.  

&nbsp;

#### 스케줄링 확인

```bash
$ crontab -l
0 3 * * * sync && echo 3 > /proc/sys/vm/drop_caches
```

`-l` : crontab의 설정 상태를 확인한다.

&nbsp;

## 참고자료

<https://kangwoo.github.io/devops/linux/linux-buffer-cache/>  
<https://linux-mm.org/Drop_Caches>
