---
title: "mongodb 설치"
date: 2021-11-27T01:52:09+09:00
lastmod: 2021-11-27T10:32:03+09:00
slug: ""
description: "M1 칩셋을 사용하는 macOS 환경에서 homebrew를 이용해 mongodb community edition 5.0을 설치하는 메뉴얼"
keywords: []
tags: ["database", "mongodb"]
---

# 개요

M1 칩셋이 장착된 맥북에서 Homebrew를 이용해 mongodb를 설치한다.  

mongodb를 설치하는 방법은 여러가지가 있다.  

mongodb 공식 사이트에서 제공하는 tar ball을 받아서 설치하는 방법도 있지만 복잡하다. macOS를 사용한다면 Homebrew로 설치하는게 간편하고 빠르다.  

<br>

# 환경

- **Hardware** : MacBook Pro (13", M1, 2020)
- **OS** : macOS Monterey 12.0.1
- **패키지 관리자** : Homebrew 3.3.5
- **MongoDB 5.0** : Homebrew를 통한 설치

<br>



# 전제조건

Homebrew 설치가 완료된 macOS  

<br>

# 본문

## 설치

### 1. tap 확인

homebrew에서 tap은 homebrew의 기본 레포지터리(Master Repository)에 포함되지 않은 다른 레포지터리를 의미한다. 레포지터리는 여러 패키지가 모여있는 저장소라고 보면 된다.  

현재 brew에 등록된 탭 목록을 확인해보자.  

```bash
$ brew tap
homebrew/cask
homebrew/core
```

`homebrew/cask`, `homebrew/core`는 homebrew 설치시 기본적으로 제공되는 tap이다.

<br>



### 2. mongodb tap 등록

mongodb community edition을 다운로드 받기 위해 mongodb에서 공식적으로 운영하는 [The MongoDB Homebrew tap](https://github.com/mongodb/homebrew-brew)을 등록한다.

```bash
$ brew tap mongodb/brew
==> Tapping mongodb/brew
Cloning into '/opt/homebrew/Library/Taps/mongodb/homebrew-brew'...
remote: Enumerating objects: 794, done.
remote: Counting objects: 100% (291/291), done.
remote: Compressing objects: 100% (208/208), done.
remote: Total 794 (delta 144), reused 139 (delta 80), pack-reused 503
Receiving objects: 100% (794/794), 173.59 KiB | 1.19 MiB/s, done.
Resolving deltas: 100% (382/382), done.
Tapped 14 formulae (30 files, 238.3KB).
```

<br>



mongodb tap이 등록되었는지 확인한다.

```bash
$ brew tap
homebrew/cask
homebrew/core
mongodb/brew
```

`mongodb/brew`라는 이름의 tap이 잘 등록되었다.

<br>




### 3. mongodb 설치

등록한 mongodb tap에서 mongodb community edition을 다운로드 받는다.

<br>



**최신 버전의 mongodb 설치**  

```bash
$ brew install mongodb-community
```

설치시 따로 버전을 표기하지 않으면 자동적으로 최신 버전(latest)의 mongodb community edition을 설치한다.

<br>



**특정 버전의 mongodb 설치**  

mongodb-community edition 5.0 버전을 설치한다. 참고로 MongoDB 5.0 Community Edition은 macOS 10.14 버전부터 지원한다.  

```bash
$ brew install mongodb-community@5.0
Updating Homebrew...
==> Auto-updated Homebrew!
Updated 1 tap (homebrew/core).
==> Updated Formulae
Updated 1 formula.

==> Downloading https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/brotli/manifests/1.0.9
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/brotli/blobs/sha256:5e9bddd862b
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sh
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/c-ares/manifests/1.18.1
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/c-ares/blobs/sha256:7b1eacc9efb
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sh
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/icu4c/manifests/69.1
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/icu4c/blobs/sha256:3771949f1799
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sh
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/macos-term-size/manifests/1.0.0
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/macos-term-size/blobs/sha256:f4
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sh
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/node/14/manifests/14.18.1
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/node/14/blobs/sha256:92ea528d60
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sh
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/mongosh/manifests/1.1.4
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/mongosh/blobs/sha256:b3ccc98848
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sh
######################################################################## 100.0%
==> Downloading https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-5.0.3.tgz
######################################################################## 100.0%
==> Installing mongodb-community from mongodb/brew
==> Installing dependencies for mongodb/brew/mongodb-community: mongodb-database-tools, brotli, c-ares, icu4c, macos-term-size, node@14 and mongosh
==> Installing mongodb/brew/mongodb-community dependency: mongodb-database-
🍺  /opt/homebrew/Cellar/mongodb-database-tools/100.5.1: 13 files, 115.7MB, built in 3 seconds
==> Installing mongodb/brew/mongodb-community dependency: brotli
==> Pouring brotli--1.0.9.arm64_monterey.bottle.tar.gz
🍺  /opt/homebrew/Cellar/brotli/1.0.9: 25 files, 2.3MB
==> Installing mongodb/brew/mongodb-community dependency: c-ares
==> Pouring c-ares--1.18.1.arm64_monterey.bottle.tar.gz
🍺  /opt/homebrew/Cellar/c-ares/1.18.1: 87 files, 665.3KB
==> Installing mongodb/brew/mongodb-community dependency: icu4c
==> Pouring icu4c--69.1.arm64_monterey.bottle.tar.gz
🍺  /opt/homebrew/Cellar/icu4c/69.1: 259 files, 73.3MB
==> Installing mongodb/brew/mongodb-community dependency: macos-term-size
==> Pouring macos-term-size--1.0.0.arm64_monterey.bottle.tar.gz
🍺  /opt/homebrew/Cellar/macos-term-size/1.0.0: 5 files, 36.9KB
==> Installing mongodb/brew/mongodb-community dependency: node@14
==> Pouring node@14--14.18.1.arm64_monterey.bottle.tar.gz
🍺  /opt/homebrew/Cellar/node@14/14.18.1: 3,923 files, 52.6MB
==> Installing mongodb/brew/mongodb-community dependency: mongosh
==> Pouring mongosh--1.1.4.arm64_monterey.bottle.tar.gz
🍺  /opt/homebrew/Cellar/mongosh/1.1.4: 5,617 files, 32.5MB
==> Installing mongodb/brew/mongodb-community
==> Caveats
To start mongodb/brew/mongodb-community now and restart at login:
  brew services start mongodb/brew/mongodb-community
Or, if you don't want/need a background service you can just run:
  mongod --config /opt/homebrew/etc/mongod.conf
==> Summary
🍺  /opt/homebrew/Cellar/mongodb-community/5.0.3: 11 files, 180.7MB, built in 2 seconds
==> Caveats
==> mongodb-community
To start mongodb/brew/mongodb-community now and restart at login:
  brew services start mongodb/brew/mongodb-community
Or, if you don't want/need a background service you can just run:
  mongod --config /opt/homebrew/etc/mongod.conf
```

mongodb 설치가 문제없이 끝났다.  

<br>



#### mongodb 경로안내

M1 맥북 기준으로 중요파일, 디렉토리의 경로는 아래와 같다. Intel CPU가 장착된 맥북은 M1 맥북의 경로와 다르다.  

- **설정파일** : `/opt/homebrew/etc/mongod.conf`
- **로그 디렉토리** : `/opt/homebrew/var/log/mongodb`
- **데이터 디렉토리** : `/opt/homebrew/var/mongodb`

<br>



### 4. mongodb 실행

```bash
$ brew services start mongodb-community@5.0
==> Successfully started `mongodb-community` (label: homebrew.mxcl.mongodb-community)
```

mongodb-community 서비스를 시작한다.

<br>



```bash
$ brew services list
Name              Status  User File
emacs             stopped
mongodb-community started xxx  ~/Library/LaunchAgents/homebrew.mxcl.mongodb-community.plist
unbound           stopped
```

mongodb-community가 실행중이다.

<br>



```bash
$ ps -ef | grep mongo | grep -v grep
  501 43139     1   0  1:04AM ??         0:02.63 /opt/homebrew/opt/mongodb-community/bin/mongod --config /opt/homebrew/etc/mongod.conf
```

ps 명령어로도 mongodb용 서비스 데몬인 `mongod`가 실행되는 걸 확인할 수 있다.

<br>



#### `Error: Unknown command: services` 에러 발생시 해결방법

**증상**  
설치한 mongodb를 실행할 수 없다.

```bash
$ brew services start mongodb-community@5.0
Error: Unknown command: services
```

<br>



**원인**  
`brew services` 명령어를 찾지 못해서 발생하는 오류다. `brew services`는 숨겨진 명령어이기 때문에 homebrew를 설치한 후 따로 설정을 해줘야 사용이 가능하다.  

<br>



**해결방법**  
tap에 `homebrew/services`를 새로 추가한다.  

```bash
$ brew tap homebrew/services
==> Tapping homebrew/services
Cloning into '/opt/homebrew/Library/Taps/homebrew/homebrew-services'...
remote: Enumerating objects: 1535, done.
remote: Counting objects: 100% (414/414), done.
remote: Compressing objects: 100% (303/303), done.
remote: Total 1535 (delta 171), reused 283 (delta 101), pack-reused 1121
Receiving objects: 100% (1535/1535), 448.79 KiB | 1.82 MiB/s, done.
Resolving deltas: 100% (647/647), done.
Tapped 1 command (38 files, 558.8KB).
```
<br>



```bash
$ brew tap
homebrew/cask
homebrew/core
homebrew/services
mongodb/brew
```

tap 목록에 `homebrew/services`가 새로 추가되었다.

<br>




```bash
$ brew services
Name              Status  User File
emacs             stopped
mongodb-community stopped
unbound           stopped
```

`homebrew/services` tap을 새로 추가한 후 `brew services` 명령어를 실행하면 오류는 해결된다.  

<br>



### 5. mongodb 접속

mongodb에 접속하려면 `mongosh`명령어를 사용한다. mongodb는 기본적으로 TCP 27017 포트를 사용한다.  



`mongosh`의 예전버전 명령어인  `mongo`는 `mongosh`로 대체(Superseded)된 후 차기 버전에서 삭제될 예정이므로 가급적이면 사용하지 말자.  

```bash
$ mongosh
Current Mongosh Log ID:	61a1070d11290afddd3fa6d8
Connecting to:		mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000
Using MongoDB:		5.0.3
Using Mongosh:		1.1.4

For mongosh info see: https://docs.mongodb.com/mongodb-shell/

------
   The server generated these startup warnings when booting:
   2021-11-27T01:04:58.779+09:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
------

Warning: Found ~/.mongorc.js, but not ~/.mongoshrc.js. ~/.mongorc.js will not be loaded.
  You may want to copy or rename ~/.mongorc.js to ~/.mongoshrc.js.
test>
```

mongodb에 제대로 접속했다.  

<br>



mongodb에 접속하면 기본적으로 `test` DB를 사용한다.  

```bash
test> db
test
```

<br>



이제 전체 DB 목록을 확인한다.  

```sql
test> show dbs
admin     41 kB
config   111 kB
local   73.7 kB
```

<br>



```sql
test> use admin
switched to db admin
```

사용중인 DB를 `test`에서 `admin`으로 변경해본다.  

<br>



```bash
test> exit
$
```

mongosh에서 빠져나와 macOS의 쉘로 돌아오고 싶다면 `exit` 명령어를 입력한다.  

<br>



```bash
$ mongotop
2021-11-27T01:16:06.812+0900	connected to: mongodb://localhost/

                    ns    total    read    write    2021-11-27T01:16:07+09:00
  admin.system.version      0ms     0ms      0ms
config.system.sessions      0ms     0ms      0ms
   config.transactions      0ms     0ms      0ms
  local.system.replset      0ms     0ms      0ms

                    ns    total    read    write    2021-11-27T01:16:08+09:00
  admin.system.version      0ms     0ms      0ms
config.system.sessions      0ms     0ms      0ms
   config.transactions      0ms     0ms      0ms
  local.system.replset      0ms     0ms      0ms

                    ns    total    read    write    2021-11-27T01:16:09+09:00
  admin.system.version      0ms     0ms      0ms
config.system.sessions      0ms     0ms      0ms
   config.transactions      0ms     0ms      0ms
  local.system.replset      0ms     0ms      0ms
```

`mongotop`은 리눅스 서버를 모니터링할 때 사용하는 `top` 명령어의 mongodb 버전이다. `mongotop`을 실행하면 동작중인 `mongod`와 연결된 후 DB 사용량 통계를 주기적으로 뽑아낸다.  

<br>



### 6. 실습환경 정리

mongodb 실습이 끝난 후에는 반드시 Homebrew를 이용해서 mongodb 서비스를 종료해준다.

mongodb 포트가 계속 열려있으면 보안에 문제가 될수도 있고 또한 개인 컴퓨터의 리소스 낭비를 막을 수 있다.  

<br>



**mongodb 서비스 종료**

```bash
$ brew services stop mongodb-community@5.0
Stopping `mongodb-community`... (might take a while)
==> Successfully stopped `mongodb-community` (label: homebrew.mxcl.mongodb-community)
```

<br>



**mongodb 서비스 상태확인**

```bash
$ brew services list
Name              Status  User File
emacs             stopped
mongodb-community stopped
unbound           stopped
```
`mongodb-community` 서비스가 중지된 상태(`stopped`)다.  

<br>



```bash
$ ps -ef | grep mongo | grep -v grep
```

mongod도 중지된 것이 확인됐다. 끝!  

<br>



## 추가설정
### 외부접속 허용하기
mongodb를 설치하면 기본값으로 설치한 로컬(127.0.0.1)에서만 접속이 가능하도록 설정되어 있다. 방화벽이 열려있어도 외부에서 들어올 수 없는 상태이므로, 외부에서 접속이 필요하다면 mongodb 설정파일(`mongod.conf`)을 열어서 접속 가능한 IP 설정값(`bindIp`)을 변경하도록 한다.  

<br>



**설정파일 확인**  
mongodb 설정파일의 이름은 `mongodb.conf` 이다.  

M1 mac 기준으로 설정파일의 디폴트 위치는 `/opt/homebrew/etc/mongod.conf` 이다.

```bash
$ cat /opt/homebrew/etc/mongod.conf
systemLog:
  destination: file
  path: /opt/homebrew/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /opt/homebrew/var/mongodb
net:
  bindIp: 127.0.0.1
```

<br>



**mongodb 포트확인**  

```bash
$ netstat -antp tcp | grep 27017
tcp4       0      0  127.0.0.1.27017        *.*                    LISTEN
```
4번째 칸에 위치한 Local Address 값이 `127.0.0.1.27017` 이다.  

**참고사항** : macOS용 `netstat`은 Linux에서의 `netstat`과 명령어 옵션 체계가 살짝 다르다.  

<br>



**설정파일 변경**  
vi 편집기를 이용해서 `bindIp` 값을 `127.0.0.1`에서 `0.0.0.0` 으로 변경해준다.  

```bash
$ vi /opt/homebrew/etc/mongod.conf
systemLog:
  destination: file
  path: /opt/homebrew/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /opt/homebrew/var/mongodb
net:
  bindIp: 0.0.0.0
```

<br>



**서비스 재시작**  
변경된 `bindIp` 설정을 적용하기 위해 homebrew 명령어로 mongodb를 재시작한다.  

```bash
$ brew services restart mongodb-community@5.0
Stopping `mongodb-community`... (might take a while)
==> Successfully stopped `mongodb-community` (label: homebrew.mxcl.mongodb-community)
==> Successfully started `mongodb-community` (label: homebrew.mxcl.mongodb-community)
```

<br>



**mongodb 포트 재확인**  

```bash
$ netstat -antp tcp | grep 27017
tcp4       0      0  *.27017                *.*                    LISTEN
```
4번째 칸에 위치한 Local Address 값이 `127.0.0.1.27017`에서 `*.27017`로 변경된 걸 확인할 수 있다.  

이제 mongodb로 모든 IP가 접근할 수 있다는 걸 의미한다.  

<br>



# 결론

사실 설치, 구성보다 중요한건 운영이 지속 가능하도록 유지해주는 보안 설정이다.  

mongodb 보안 설정은 이 글에 설명하기엔 너무 방대하기 때문에 기본적인 설치 과정만 다루었다.  

자료를 조사하는 과정에서 개인 목적의 개발용 mongodb 서버가 랜섬웨어로 털리는 케이스가 은근히 많은 것 같다. 이 글을 통해 계속 상시 운영되는 개발용 mongodb를 설치했다면, <u>반드시 다른 보안관련 포스트들을 참고해서 관리자용 계정 생성, Security authorization enabled 등의 DB 보안 설정을 적용해 운영하도록 하자.</u> 아무리 개인 학습용 mongodb일지라도 해커한테 털리면 귀찮아지니까. 끝!   

<br>

 


# 참고자료

https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/ : MongoDB 공식페이지의 설치 가이드 문서  

https://github.com/mongodb/homebrew-brew : mongodb tap 공식페이지  

https://apple.stackexchange.com/questions/150300/need-help-using-homebrew-services-command : brew services 명령어 에러 발생 관련 해결방법  