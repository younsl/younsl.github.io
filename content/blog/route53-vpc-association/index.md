---
title: "Route 53 VPC Association"
date: 2022-12-23T18:18:30+09:00
lastmod: 2022-12-23T18:19:35+09:00
slug: ""
description: "Private hosted zone에 다른 계정의 VPC를 연결하는 방법"
keywords: []
tags: ["aws", "networking"]
---

## 목차

- [목차](#목차)
- [개요](#개요)
- [배경지식](#배경지식)
  - [설정 방식](#설정-방식)
- [준비사항](#준비사항)
  - [AWS CLI](#aws-cli)
- [VPC Association 설정방법](#vpc-association-설정방법)
  - [1. 타 계정의 VPC 연결 허용](#1-타-계정의-vpc-연결-허용)
  - [2. VPC 연결](#2-vpc-연결)
  - [3. 결과 확인](#3-결과-확인)
- [참고자료](#참고자료)

&nbsp;

## 개요

Route 53의 Private Hosted Zone에 다른 계정 VPC를 연결하는 방법을 설명합니다.

![Route 53 VPC Association 구성 예시](./1.png)

Route 53의 [VPC Association](https://docs.aws.amazon.com/ko_kr/Route53/latest/DeveloperGuide/hosted-zone-private-associate-vpcs-different-accounts.html) 기능을 사용하면 여러 AWS VPC에 걸쳐 같은 Private 도메인을 통합 관리할 수 있습니다.

&nbsp;

## 배경지식

### 설정 방식

VPC Association 구성은 AWS Management Console을 아직 지원하지 않기 때문에 AWS CLI 또는 AWS SDK를 통해서만 작업 진행이 가능합니다.

&nbsp;

## 준비사항

### AWS CLI

로컬 환경에 AWS CLI가 설치되어 있어야 합니다.

```bash
$ aws --version
aws-cli/2.9.8 Python/3.11.0 Darwin/22.2.0 source/arm64 prompt/off
```

macOS 패키지 관리자인 [brew](https://brew.sh)를 사용하는 경우, `brew install awscli`로 쉽게 설치가 가능합니다.

&nbsp;

## VPC Association 설정방법

이 가이드는 AWS CLI를 사용하는 방식으로 설명합니다.

&nbsp;

### 1. 타 계정의 VPC 연결 허용

Private Hosted Zone을 보유한 AWS 계정에서 아래 명령어를 실행합니다.  
위 구성도 기준으로는 Account A가 됩니다.

```bash
aws route53 create-vpc-association-authorization \
  --hosted-zone-id <PRIVATE_HOSTED_ZONE_ID> \
  --vpc VPCRegion=ap-northeast-2,VPCId=<VPC_ID> \
  --region ap-northeast-2
```

`<PRIVATE_HOSTED_ZONE_ID>`와 `<VPC_ID>` 값은 각자의 환경에 맞게 수정합니다.

&nbsp;

### 2. VPC 연결

연결할 VPC가 위치한 AWS 계정에서 아래 명령어를 실행합니다.  
위 구성도 기준으로는 Account B가 됩니다.

```bash
aws route53 associate-vpc-with-hosted-zone \
  --hosted-zone-id <PRIVATE_HOSTED_ZONE_ID> \
  --vpc VPCRegion=ap-northeast-2,VPCId=<VPC_ID> \
  --region ap-northeast-2
```

`<PRIVATE_HOSTED_ZONE_ID>`와 `<VPC_ID>` 값은 각자의 환경에 맞게 수정합니다.

&nbsp;

### 3. 결과 확인

이후 AWS 콘솔에 접속해서 Private hosted zone에 새 VPC가 등록되었는지 확인합니다.

![설정 결과](./2.png)

Associated VPCs 값에 새 VPC가 하나 더 추가된 걸 확인할 수 있습니다.

&nbsp;

## 참고자료

[더 많은 VPC를 프라이빗 호스팅 영역에 연결](https://docs.aws.amazon.com/ko_kr/Route53/latest/DeveloperGuide/hosted-zone-private-associate-vpcs.html)  
[Amazon VPC와 다른 AWS 계정에서 생성한 프라이빗 호스팅 영역의 연결](https://docs.aws.amazon.com/ko_kr/Route53/latest/DeveloperGuide/hosted-zone-private-associate-vpcs-different-accounts.html)  
[Route53 프라이빗 영역, 다른 VPC연결](https://brunch.co.kr/@topasvga/1589)
