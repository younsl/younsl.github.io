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

리눅스 서버에서 명령어를 통해 캐시 메모리를 정리해 여유 메모리를 확보할 수 있습니다.

&nbsp;

## 환경

- **OS** : Red Hat Enterprise Linux Server release 5.x
- **Shell** : bash
- **User**: `root`

&nbsp;

## 준비사항

### root 권한 확인

모든 조치는 `root` 계정으로 진행합니다. 시스템 캐시 메모리를 조작하는 작업은 시스템 전체에 영향을 미치는 민감한 작업이므로 `/proc/sys/vm/drop_caches` 파일 조작 시에는 반드시 `root` 권한이 필요합니다.

작업 전에 현재 사용자가 `root` 계정인지 아래 명령어들을 통해 확인할 수 있습니다.

```bash
whoami
id
```

&nbsp;

## 캐시 메모리 정리 방법

### 1. 메모리 사용량 요약 확인

`free` 명령어를 통해 메모리 사용량을 GB 단위로 확인할 수 있습니다.

```bash
free -g
```

```bash
             total       used       free     shared    buffers     cached
Mem:            62         62          0          0          0         55
-/+ buffers/cache:          6         56
Swap:           62          3         59
```

전체 메모리(`total`) 62GB 중 55GB가 캐시 메모리(`cached`)로 잡혀있는 걸 확인할 수 있습니다.

&nbsp;

### 2. 메모리 사용량 상세 확인

#### 기본 단위(kB)로 보기

`/proc/meminfo` 파일을 통해 메모리 사용량을 확인할 수 있습니다.

```bash
cat /proc/meminfo | column -t
```

- `column -t` : 출력결과를 칸에 맞게 정렬해서 가독성을 높여주는 명령어

```bash
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

확인결과 전체 메모리(`MemTotal`)의 87%가 캐시 메모리(`Cached`)로 잡혀있는 걸 확인할 수 있습니다.

&nbsp;

#### GB 단위로 보기

kB 단위로 보는게 불편하면 GB 단위로 변환시켜 볼 수도 있습니다.

```bash
awk '$3=="kB"{$2=$2/1024/1024;$3="GB"} 1' /proc/meminfo | column -t
```

`awk` 명령어의 계산식을 통해 kB 단위를 GB 단위로 변환해줍니다.

```bash
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

전체 메모리(`MemTotal`) 64GB 중에서 캐시 메모리(`Cached`)를 55GB 쓰고, 버퍼 메모리(`Buffers`)는 0.7GB 사용중입니다.

```bash
MemTotal:         62.9466     GB
...
Buffers:          0.724033    GB
Cached:           55.3696     GB
```

여유 메모리(`MemFree`) 값은 0.19GB로 너무 낮습니다.

```bash
MemFree:          0.191048    GB
```

&nbsp;

### 3. 캐시 메모리 정리

#### 메모리 사용량 모니터링

캐시 메모리 정리 전에 <u>메모리 사용량 변화를 모니터링 하기 위해</u> 세션을 하나 더 띄워서 `watch -d -n1 "free -g"` 명령어를 실행합니다.

```bash
watch -d -n 1 "free -g"
```

watch 명령어는 명령어 실행 결과를 지속적으로 모니터링하는 명령어로 시스템 관리자는 이를 통해 메모리 사용량 변화를 모니터링할 수 있습니다.

- `-d`, `--difference` : 변경된 값을 하이라이팅 해서 가독성을 높여줍니다.
- `-n 1` : 1초 간격으로 `free -g` 명령어를 실행합니다.

자세한 옵션 설명은 `watch --help` 명령어를 통해 확인할 수 있습니다.

&nbsp;

#### sync

`sync` 명령어는 캐시 메모리에 있는 변동사항을 하드디스크에 옮겨서 쓰는 작업을 수행합니다.

```bash
sync
```

> **sync와 데이터 동기화**: 리눅스는 성능 향상을 위해 파일 시스템 변경사항을 즉시 디스크에 쓰지 않고 메모리 버퍼에 임시로 저장합니다. 이런 방식을 통해 디스크 I/O 작업을 최소화하고 시스템 성능을 최적화할 수 있습니다. `sync` 명령어는 이 버퍼에 있는 모든 더티 페이지(수정된 데이터)를 강제로 디스크에 기록합니다. 더티 페이지란 메모리에서 수정되었지만 아직 디스크에 기록되지 않은 데이터를 의미합니다. 특히 `shutdown`을 통한 시스템 종료나 캐시 메모리 정리 전에 `sync` 명령어를 실행하면 데이터 손실을 방지할 수 있습니다. 시스템이 갑자기 종료되면 버퍼에 있는 데이터가 손실될 수 있기 때문입니다.

&nbsp;

#### 캐시 메모리 정리

리눅스 커널 2.6.16 버전부터는 명령어로 페이지 캐시, inode, dentry 캐시를 정리할 수 있게 되었습니다. 이를 통해 많은 메모리를 확보할 수 있습니다. `/proc/sys/vm/drop_caches` 파일에 숫자만 입력하면 됩니다.

`pagecache`, `dentry`, `inode` 캐시 메모리 영역은 다음과 같은 역할을 합니다.

- **pagecache** : 파일의 입출력(I/O)의 속도와 퍼포먼스를 높이기 위해 시스템이 할당한 메모리 영역(임시 메모리 저장소). 예를 들어 어떤 경로의 파일을 한 번 읽어들이면 시스템이 해당 파일 내용을 임시메모리에 저장시키는데 이후에 해당 파일을 다시 읽을 때 이를 새로 읽어들이지 않고 이 메모리에서 바로 불러오면 디스크의 읽기/쓰기 속도가 빨라지므로 효율이 높아짐. 윈도우 OS의 페이지 파일 같은 역할.
- **dentry** : directory entry의 줄임말로, 리눅스 파일시스템에서 디렉토리 구조를 캐싱하는 객체입니다. 예를 들어 `/usr/share` 같은 경로에서 `usr`과 `share`를 지칭합니다. 파일시스템 탐색 속도를 높이기 위해 자주 사용되는 디렉토리 정보를 메모리에 캐시하며, 각 `dentry`는 파일이나 디렉토리의 이름, 부모 디렉토리에 대한 포인터, inode 정보 등을 포함합니다. 이를 통해 파일시스템 경로 검색 시 디스크 접근 없이 빠르게 탐색이 가능합니다.
- **inode** : 파일과 디렉토리에 관한 정보를 담고 있는 자료구조. 예를 들어 파일의 퍼미션 정보, 디스크 상의 파일의 물리적 위치, 크기, 생성된 일시 정보 등을 저장.

각 숫자마다 정리할 캐시 메모리 영역이 다르므로 상황에 따라 `1`, `2`, `3` 중 적절한 숫자를 입력해야 합니다.

| 값 | pagecache | dentries | inodes |
|:---:|:---:|:---:|:---:|
| 1 | Drop | - | - |
| 2 | - | Drop | Drop |
| 3 | Drop | Drop | Drop |

> 안심하세요. 리눅스의 캐시 메모리 정리 작업(`drop_caches`)은 현재 사용 중인 데이터나 중요한 데이터를 파괴하지 않습니다. 전혀 사용되지 않는 것들만 해제합니다.

```bash
echo 1 > /proc/sys/vm/drop_caches  # To free pagecache
echo 2 > /proc/sys/vm/drop_caches  # To free dentries and inodes
echo 3 > /proc/sys/vm/drop_caches  # To free pagecache, dentries and inodes
```

&nbsp;

이 시나리오에서는 `3`을 입력해 `pagecache`, `dentry`, `inode` 캐시를 모두 정리합니다. 일반적으로 시스템 전체의 캐시를 정리하려면 `3`을 사용하는 것이 가장 효과적입니다.

```bash
echo 3 > /proc/sys/vm/drop_caches  # To free pagecache, dentries and inodes
```

캐시 메모리 정리 소요시간은 서버 환경과 캐시 메모리 용량에 따라 다른데 보통 10초 안으로 정리가 완료됩니다.

&nbsp;

### 4. 메모리 반환 결과 확인

#### 메모리 사용량 요약 확인

캐시 메모리를 정리한 후 `free -g` 명령어를 통해 메모리 사용량을 다시 확인합니다.

```bash
free -g
```

- `-g` : 메모리 사용량을 GB 단위로 보여줍니다.

```bash
             total       used       free     shared    buffers     cached
Mem:            62         12         50          0          0          5
-/+ buffers/cache:          6         56
Swap:           62          3         59
```

&nbsp;

#### 메모리 사용량 상세 확인

`/proc/meminfo` 파일을 통해 메모리 사용량을 확인할 수 있습니다. `awk` 명령어를 통해 kB 단위를 GB 단위로 변환해줍니다.

```bash
awk '$3=="kB"{$2=$2/1024/1024;$3="GB"} 1' /proc/meminfo | column -t
```

```bash
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

`drop_caches` 파일 조작 후 버퍼 메모리(Buffers)의 사용량이 94% 줄고, 캐시 메모리(Cached)의 사용량이 87% 줄었습니다.

| 구분 | 정리 전 | 정리 후 | 감소율 |
|:---:|:---:|:---:|:---:|
| Buffers | 0.7 GB | 0.04 GB | -94% |
| Cached | 55 GB | 7 GB | -87% |

이 리눅스 서버는 버퍼 메모리가 원래 0.7GB로 크기가 작았지만, 캐시 메모리는 55GB에서 7GB로 크게 감소했다는 점이 주목할 만한 결과입니다.

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

`crontab -e` 명령어를 통해 crontab을 편집합니다.

> [cron 모범사례](https://github.com/mnestorov/cron-cheat-sheet?tab=readme-ov-file#best-practices-1)에 따라 `crontab`에 등록하기 전에 터미널에서 먼저 명령어를 테스트해보세요. 이를 통해 오류를 미리 잡을 수 있습니다.

> **권한 주의**: `/proc/sys/vm/drop_caches` 파일은 시스템 관련 파일이므로 반드시 root 계정의 crontab에 등록해야 합니다. 일반 사용자 계정의 crontab에 등록하면 권한 부족으로 실행되지 않습니다. 반드시 `whoami` 명령어를 통해 현재 사용자가 `root` 계정인지 확인해야 합니다.

```bash
crontab -e
```

```bash
0 3 * * * sync && echo 3 > /proc/sys/vm/drop_caches
```

매일 새벽 3시마다 캐시 메모리를 정리하는 명령어를 실행합니다.

```bash
sync && echo 3 > /proc/sys/vm/drop_caches
```

위 명령어는 `sync` 명령어로 버퍼 메모리를 디스크에 쓰는 작업을 정상적으로 완료한 후 `echo 3 > /proc/sys/vm/drop_caches` 명령어로 캐시 메모리를 정리하는 작업을 수행합니다.

&nbsp;

#### 스케줄링 확인

`crontab -l` 명령어를 통해 crontab에 등록된 스케줄을 확인할 수 있습니다.

```bash
crontab -l
```

```bash
0 3 * * * sync && echo 3 > /proc/sys/vm/drop_caches
```

오전 3시마다 캐시 메모리를 정리하는 명령어가 등록되어 있는 걸 확인할 수 있습니다.

&nbsp;

## 더 나아가서

### 커널 소스 코드 분석

`/proc/sys/vm/drop_caches` 파일 조작 시 실제로 어떤 작업이 수행되는지 확인해보기 위해, [drop_caches.c](https://github.com/torvalds/linux/blob/v6.13/fs/drop_caches.c) 파일을 열어보았습니다.

`drop_caches_sysctl_handler()` 함수는 `drop_caches` 파일 조작 시 실제로 수행되는 작업을 정의한 함수입니다. `drop_caches` 파일에 `3`을 입력하면 이진수로 `0b11`이기 때문에 `&` (비트 AND 연산자)를 통해 `1`과 `2`가 모두 참이 되어 버퍼 메모리와 캐시 메모리를 모두 정리하게 됩니다.

```bash
3 (0b11) & 1 (0b01) = 1 (0b01)  // 첫 번째 비트가 둘 다 1이므로 True
3 (0b11) & 2 (0b10) = 2 (0b10)  // 두 번째 비트가 둘 다 1이므로 True
```

&nbsp;

Linux Kernel 6.13 버전의 `drop_caches.c` 파일 원본 코드는 다음과 같습니다. 흥미로운 점은 `stfu`(shut the f up의 줄임말) 변수를 통해 `4`(0b100) 이상의 값을 입력하면 출력을 무시하는 것을 확인할 수 있습니다.

```bash
4 (0b100) & 4 (0b100) = 4 (0b100)  // 세번째 비트가 둘 다 1이므로 True
5 (0b101) & 4 (0b100) = 4 (0b100)  // 세번째 비트가 둘 다 1이므로 True
# ... 6 and above are omitted for brevity ...
```

즉, `drop_caches` 파일에 `1`, `2`, `3` 값만 입력할 수 있는 것을 확인할 수 있습니다. `4` 이상의 값을 입력하면 출력을 무시하는 것을 확인할 수 있습니다.

```c
int drop_caches_sysctl_handler(const struct ctl_table *table, int write,
		void *buffer, size_t *length, loff_t *ppos)
{
	int ret;

	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
	if (ret)
		return ret;
	if (write) {
		static int stfu;

		if (sysctl_drop_caches & 1) {
			lru_add_drain_all();
			iterate_supers(drop_pagecache_sb, NULL);
			count_vm_event(DROP_PAGECACHE);
		}
		if (sysctl_drop_caches & 2) {
			drop_slab();
			count_vm_event(DROP_SLAB);
		}
		if (!stfu) {
			pr_info("%s (%d): drop_caches: %d\n",
				current->comm, task_pid_nr(current),
				sysctl_drop_caches);
		}
		stfu |= sysctl_drop_caches & 4;
	}
	return 0;
}
```

&nbsp;

## 참고자료

- [drop_caches.c](https://github.com/torvalds/linux/blob/v6.13/fs/drop_caches.c) : 리눅스 커널 6.13 버전의 `drop_caches.c` 파일 원본 코드
- [Linux buffer/cache 비우기](https://kangwoo.github.io/devops/linux/linux-buffer-cache/)  
- [Linux Memory Management](https://linux-mm.org/Drop_Caches) : 리눅스 메모리 관리 위키
- [cron 모범사례](https://github.com/mnestorov/cron-cheat-sheet?tab=readme-ov-file#best-practices-1) : `cron` 관리 모범사례