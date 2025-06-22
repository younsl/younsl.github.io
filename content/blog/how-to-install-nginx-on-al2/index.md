---
title: "Amazon Linux 2에 nginx 설치"
date: 2022-11-22T00:27:15+09:00
lastmod: 2022-11-28T23:17:25+09:00
slug: ""
description: "Amazon Linux 2에 nginx 설치"
keywords: []
tags: ["linux", "aws"]
---

## 개요

Amazon Linux 2 OS가 설치된 EC2 인스턴스에 nginx를 설치하는 방법을 소개하는 가이드입니다.

&nbsp;

## 배경지식

### Amazon Linux Extras

Amazon Linux 2에서는 Extras Library를 사용하여 인스턴스에 애플리케이션 및 소프트웨어 업데이트를 설치할 수 있습니다.  
이러한 소프트웨어 업데이트를 토픽<sup>topic</sup>이라고 합니다. 토픽<sup>topic</sup>의 특정 버전을 설치하거나 버전 정보를 생략하여 최신 버전을 설치할 수 있습니다.

&nbsp;

## 준비사항

### amazon-linux-extras 설치

Amazon Linux 2에는 기본적으로 `amazon-linux-extras` 패키지가 설치되어 있습니다.  
EC2 인스턴스에서 `amazon-linux-extras` 설치 유무 확인은 다음 명령어로 확인 가능합니다.

```bash
$ which amazon-linux-extras
/bin/amazon-linux-extras
```

&nbsp;

EC2 인스턴스에 `amazon-linux-extras` 패키지가 설치되어 있지 않은 경우, yum 패키지 관리자를 사용해 설치합니다.

```bash
$ sudo yum install -y amazon-linux-extras
```

&nbsp;

## 설치방법

`amazon-linux-extras`를 사용해서 nginx 패키지를 쉽게 설치할 수 있습니다.

```bash
# nginx 설치
sudo amazon-linux-extras list | grep nginx
sudo amazon-linux-extras install -y nginx1
nginx -v
```

```bash
# nginx 시작
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

&nbsp;

## 참고자료

[Extras Library(Amazon Linux 2)](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/amazon-linux-ami-basics.html#extras-library)  
`amazon-linux-extras` 명령어 사용법을 설명하는 AWS 공식문서

[Amazon Linux 2 FAQ - Amazon Linux Extras](https://aws.amazon.com/ko/amazon-linux-2/faqs/?nc1=h_ls)  
Amazon Linux Extras 기능에 대한 설명과 동작방식
