---
title: "Jenkins 컨테이너에 AWS CLI 설치"
date: 2023-04-26T23:13:15+09:00
lastmod: 2023-04-26T23:45:25+09:00
slug: ""
description: "Jenkins 컨테이너에 AWS CLI 설치"
keywords: []
tags: []
---

## 개요

Jenkins 도커 컨테이너에 AWS CLI를 설치하는 방법을 소개합니다.

![전체 작업순서](./1.png)

&nbsp;

## 환경

- **CPU 아키텍처** : ARM64 (aarch64)
- **컨테이너 이미지** : [jenkins/jenkins:2.402-jdk11](https://hub.docker.com/r/jenkins/jenkins/tags)
- **컨테이너 OS** : Debian 11.6

&nbsp;

로컬 환경에서 Jenkins 컨테이너를 실행하는 명령어는 다음과 같습니다.

```bash
$ docker run -d \
    -p 8080:8080 \
    -p 50000:50000 \
    --name jenkins \
    jenkins/jenkins:2.402-jdk11
```

&nbsp;

## 설치방법

### AWS CLI

Jenkins 컨테이너에 root로 접속합니다.

```bash
# Take a note of the running Jenkins containers
# and then run to login as a root
docker exec -u 0 -it 85f0af1f40e4 /bin/bash
```

컨테이너 ID인 `85f0af1f40e4`는 자신의 환경에 맞게 변경해주세요.  
`-u 0`은 UID 0인 root를 의미합니다.

&nbsp;

AWS CLI를 다운로드 받고 설치 스크립트를 실행합니다.

```bash
# Next, update the packages list:
apt-get update

# Download AWS CLI zip file from AWS.
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" \
  -o "awscliv2.zip"

# Unzip the package
unzip awscliv2.zip

# Install the AWS CLI by running the script
./aws/install

# Check if the AWS CLI has been installed properly.
aws –version
```

&nbsp;

## 참고자료

[How to Install AWS CLI and Terraform in Jenkins Docker Container](https://securitywing.com/how-to-install-aws-cli-in-jenkins-docker-container/)  
[AWS 공식문서 - 최신 버전의 AWS CLI 설치 또는 업데이트](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
