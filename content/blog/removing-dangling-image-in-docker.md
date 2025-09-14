---
title: "Docker dangling 이미지 삭제"
date: 2022-01-05T04:18:20+09:00
lastmod: 2022-06-07T21:15:40+09:00
slug: ""
description: "도커에서 태그가 <none>으로 표기된 dangling 이미지를 명령어로 확인하고 삭제하는 방법을 소개합니다."
keywords: []
tags: ["devops", "docker"]
---

## 개요

도커에서 `<none>` 태그가 붙은 이미지<sup>dangling image</sup>들이 많이 쌓인 상황일 경우, 명령어를 통해 한 번에 dangling image를 정리하는 방법을 설명합니다.  

&nbsp;

## 발단

도커를 사용하던 중 `<none>` 태그가 붙은 쓸모없는 이미지들이 쌓여버렸다.  
4개의 도커 이미지 정리가 필요하다.  

```bash
$ docker image ls
REPOSITORY                             TAG           IMAGE ID       CREATED          SIZE
<none>                                 <none>        a52cae4543de   10 minutes ago   522MB
younsunglee/docker-nodejs-toyproject   746c681       5dee88486167   2 days ago       1GB
younsunglee/docker-nodejs-toyproject   <none>        3a8850aa21bf   3 days ago       1.01GB
younsunglee/docker-nodejs-toyproject   bd2f64b       4ece06c282a8   3 days ago       1GB
younsunglee/docker-nodejs-toyproject   8d27e5f49     7e7bf7400489   3 days ago       1GB
younsunglee/docker-nodejs-toyproject   latest        7e7bf7400489   3 days ago       1GB
younsunglee/docker-nodejs-toyproject   <none>        7e989628d966   3 days ago       1GB
jenkins-docker                         latest        141715b7bf00   3 days ago       522MB
<none>                                 <none>        0bd92a6415d2   3 days ago       522MB
node                                   latest        a283f62cb84b   2 weeks ago      993MB
mysql                                  latest        3218b38490ce   2 weeks ago      516MB
jenkins/jenkins                        lts           2a4bbe50c40b   4 weeks ago      441MB
gradle                                 jdk8-alpine   8017d8c2ba74   2 years ago      204MB
node                                   4.6           e834398209c1   5 years ago      646MB
```

&nbsp;

## 환경

- **Architecture** : x86_64
- **OS** : Ubuntu 20.04.3 LTS
- **Shell** : bash
- **Docker** : version 20.10.12, build e91ed57

&nbsp;

## TL;DR

시간이 없는 분들을 위해서 조치방법만 요약한 내용입니다.  
자세한 해결방법은 아래 [해결방법](#해결방법)을 참조하세요.

```bash
# 이미지 목록 조회
$ docker images

# dangling 이미지 삭제
$ docker rmi $(docker images -f "dangling=true" -q)

# 위 명령어가 실행 안될 경우는 강제 삭제(-f, --force) 시도
$ docker rmi -f $(docker images -f "dangling=true" -q)

# 삭제 결과 확인
$ docker images
```

&nbsp;

## 해결방법

### 1. 이미지 확인

`<none>` 태그가 붙은 쓸모없는 이미지들을 먼저 확인한다.  

```bash
$ docker images
REPOSITORY                             TAG           IMAGE ID       CREATED          SIZE
<none>                                 <none>        a52cae4543de   16 minutes ago   522MB
younsunglee/docker-nodejs-toyproject   746c681       5dee88486167   2 days ago       1GB
younsunglee/docker-nodejs-toyproject   <none>        3a8850aa21bf   3 days ago       1.01GB
younsunglee/docker-nodejs-toyproject   bd2f64b       4ece06c282a8   3 days ago       1GB
younsunglee/docker-nodejs-toyproject   8d27e5f49     7e7bf7400489   3 days ago       1GB
younsunglee/docker-nodejs-toyproject   latest        7e7bf7400489   3 days ago       1GB
younsunglee/docker-nodejs-toyproject   <none>        7e989628d966   3 days ago       1GB
jenkins-docker                         latest        141715b7bf00   3 days ago       522MB
<none>                                 <none>        0bd92a6415d2   3 days ago       522MB
node                                   latest        a283f62cb84b   2 weeks ago      993MB
mysql                                  latest        3218b38490ce   2 weeks ago      516MB
jenkins/jenkins                        lts           2a4bbe50c40b   4 weeks ago      441MB
gradle                                 jdk8-alpine   8017d8c2ba74   2 years ago      204MB
node                                   4.6           e834398209c1   5 years ago      646MB
```

나는 심한 편은 아니지만 약 4개정도의 `<none>` 태그가 붙은 이미지들이 있다.  

Docker에서는 이런 이미지를 댕글링 이미지(dangling image)라고 부른다.  

&nbsp;

#### Dangling Image

댕글링 이미지는 같은 이름과 태그의 새 이미지로 덮어쓸 때 생성된다.  
동일한 태그를 가진 Docker 이미지가 빌드될 경우, 기존에 있던 이미지는 삭제되지는 않고 tag가 `<none>`으로 변경된 상태로 남아 있는다.  
댕글링 이미지는 태그가 지정된 이미지와 관련이 없는 불필요한 레이어이기 때문에 정리가 필요하다.

- 댕글링 이미지는 더 이상 이미지 빌드에 사용하지 못하고 디스크 공간만 차지할 뿐이다.
- 관리적 측면에서도 `docker images` 명령어로 도커 이미지를 확인하는 상황에서 헷갈리게 만든다.

이런 여러가지 이유로 주기적으로 댕글링 이미지(dangling image)를 정리할 필요가 있다.  

&nbsp;

### 2. 삭제 전 IMAGE ID 확인

```bash
$ docker images -f "dangling=true" -q
a52cae4543de
3a8850aa21bf
7e989628d966
0bd92a6415d2
```

`<none>` 태그가 붙은 도커 이미지의 Image ID만 출력된다.  

**명령어 옵션**  
`-f <Key=Value>` : 이미지를 조회할 때 특정 조건(filter)을 걸어서 조건에 해당되는 이미지만 출력한다.  
`-q` (`--quiet`) : 이미지 ID만 출력한다.

&nbsp;

### 3. 이미지 삭제

`<none>` 태그가 붙은 dangling된 이미지들만 필터링해서 삭제한다.

```bash
$ docker rmi $(docker images -f "dangling=true" -q)
Deleted: sha256:a52cae4543de475309ec97e30d7e1ec26b837bd6b1c34d8964e50f6d32be2742
Deleted: sha256:aad7d00427d8fdddfe06e6163e2a0696954bc9a0561f52e035b200b554f2e910
Deleted: sha256:f28088ff254ca63f5eb796dc7cb6cd34a51b9f6904f5b46ab36b84e817369c95
Deleted: sha256:2683a7c7d842eab9795d164c7a5271753eac60024d8a95bcb74c27a150c9438f
Untagged: younsunglee/docker-nodejs-toyproject@sha256:52baff698058be6b7bd961857038e19ad019a03e95210ca053176bee6eb37f9e
Deleted: sha256:3a8850aa21bfc17d9ddd3bb2a1cbbae7c752b69ed62ef15d9f6d5220f9ae7d02
Deleted: sha256:b69cba1495e82131fc54da34b136fa88f8d4066e8cb18354b25f2b3dd0ecf84d
Deleted: sha256:69e70dbd2172741b5215a4ccc127d14a3c44d17ceba5d4d214f8cbe0b931c64f
Deleted: sha256:1d850ae78effc483872e1f594733ef7858b09c9c98276d30c6350674527d48e9
Deleted: sha256:bad8a7081865b98d6d799161ca21c3e4328b235d30f3510d0ef78e586a63d836
Deleted: sha256:06e0c9e5ff491fd138f7762d1d1a2803e545aff3d22bfdcaace5d9a44d2542ed
Deleted: sha256:0bd92a6415d2e368042811b8a1cb4b2481b5fab4fd5e82bd5e7af83d154e0eff
Deleted: sha256:ac00a7709991e802542a5ef86251f01e1aced9369d6bbcc9dbcae9fa1f8f3a21
Deleted: sha256:254da0fd6eee155fdd01d19c02efde3ed476d495925c02ddd463147978d7df84
```

&nbsp;

#### 특정 컨테이너 이미지가 삭제 안될 경우

**증상**  
컨테이너 이미지 삭제 과정에서 `image is being used by stopped container ...` 에러 메세지와 함께 특정 이미지가 삭제되지 않는다.

```bash
$ docker rmi $(docker images -f "dangling=true" -q)
Deleted: sha256:a52cae4543de475309ec97e30d7e1ec26b837bd6b1c34d8964e50f6d32be2742
Deleted: sha256:aad7d00427d8fdddfe06e6163e2a0696954bc9a0561f52e035b200b554f2e910
Deleted: sha256:f28088ff254ca63f5eb796dc7cb6cd34a51b9f6904f5b46ab36b84e817369c95
Deleted: sha256:2683a7c7d842eab9795d164c7a5271753eac60024d8a95bcb74c27a150c9438f
Untagged: younsunglee/docker-nodejs-toyproject@sha256:52baff698058be6b7bd961857038e19ad019a03e95210ca053176bee6eb37f9e
Deleted: sha256:3a8850aa21bfc17d9ddd3bb2a1cbbae7c752b69ed62ef15d9f6d5220f9ae7d02
Deleted: sha256:b69cba1495e82131fc54da34b136fa88f8d4066e8cb18354b25f2b3dd0ecf84d
Deleted: sha256:69e70dbd2172741b5215a4ccc127d14a3c44d17ceba5d4d214f8cbe0b931c64f
Deleted: sha256:1d850ae78effc483872e1f594733ef7858b09c9c98276d30c6350674527d48e9
Deleted: sha256:bad8a7081865b98d6d799161ca21c3e4328b235d30f3510d0ef78e586a63d836
Deleted: sha256:06e0c9e5ff491fd138f7762d1d1a2803e545aff3d22bfdcaace5d9a44d2542ed
Deleted: sha256:0bd92a6415d2e368042811b8a1cb4b2481b5fab4fd5e82bd5e7af83d154e0eff
Deleted: sha256:ac00a7709991e802542a5ef86251f01e1aced9369d6bbcc9dbcae9fa1f8f3a21
Deleted: sha256:254da0fd6eee155fdd01d19c02efde3ed476d495925c02ddd463147978d7df84
Error response from daemon: conflict: unable to delete 7e989628d966 (cannot be forced) - image is being used by stopped container 234d5e511f5f
```

**원인**  
해당 이미지를 중지된 상태(stopped container)의 컨테이너가 참조하고 있어서 삭제가 불가능하다는 의미이다.  

**조치방법**  
도커 이미지를 삭제 명령어인 `docker rmi`를 실행할 때 강제 삭제<sup>`-f`, `--force`</sup> 옵션을 주면 된다.  

```bash
$ docker rmi -f $(docker images -f "dangling=true" -q)
Untagged: younsunglee/docker-nodejs-toyproject@sha256:a7098ab967d86ee2b2d7431cc4be1c940b100cb964e86fb29fb6f964ba67d381
Deleted: sha256:7e989628d966c9c6c79477d85551cf72deac685286b3a598369e31465335b50e
Deleted: sha256:172a4bf7f894bd7531cf11c24462aa3445667ec4ad80f5b7dec91b2326f70291
Deleted: sha256:8aaa4b338fc57490904b23497b579b4f760291a565d27f72d951c94b87c344fd
Deleted: sha256:e00dfa43e425da0e1a3d3493b40cb6a298cf3ab82621531f4a87edb0542d4ece
```

아까 삭제 실패했던 이미지가 `-f` 옵션을 주니까 삭제 처리된다.  

&nbsp;

### 4. 이미지 삭제결과 확인

```bash
$ docker images
REPOSITORY                             TAG           IMAGE ID       CREATED       SIZE
younsunglee/docker-nodejs-toyproject   746c681       5dee88486167   2 days ago    1GB
younsunglee/docker-nodejs-toyproject   bd2f64b       4ece06c282a8   3 days ago    1GB
younsunglee/docker-nodejs-toyproject   8d27e5f49     7e7bf7400489   3 days ago    1GB
younsunglee/docker-nodejs-toyproject   latest        7e7bf7400489   3 days ago    1GB
jenkins-docker                         latest        141715b7bf00   3 days ago    522MB
node                                   latest        a283f62cb84b   2 weeks ago   993MB
mysql                                  latest        3218b38490ce   2 weeks ago   516MB
jenkins/jenkins                        lts           2a4bbe50c40b   4 weeks ago   441MB
gradle                                 jdk8-alpine   8017d8c2ba74   2 years ago   204MB
node                                   4.6           e834398209c1   5 years ago   646MB
```

이것으로 `<none>` 태그가 붙은 dangling 이미지들이 모두 삭제되었다.  

조치 완료.
