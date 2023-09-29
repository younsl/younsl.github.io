---
title: "EC2 인스턴스 타입이 지원하는 AZ 확인"
date: 2022-05-09T19:56:48+09:00
lastmod: 2022-08-11T22:00:44+09:00
slug: ""
description: "특정 EC2 인스턴스 타입이 어디 가용영역(Availiability Zone)에서 지원하는지 AWS CLI 명령어를 통해 확인하는 방법"
keywords: []
tags: ["aws"]
---

## 개요

AWS CLI 명령어를 사용해서 특정 EC2 인스턴스 타입이 어디 가용영역<sup>AZ, Availiability Zone</sup>에서 지원하는지 확인하는 방법을 소개합니다.

&nbsp;

## 전제조건

AWS CLI가 미리 설치되어 있어야 합니다.

&nbsp;

**AWS CLI 설치**  
AWS CLI가 설치되어 있지 않을 경우, macOS 패키지 관리자인 brew를 통해 쉽게 설치할 수 있습니다.

```bash
$ brew install awscli
```

&nbsp;

설치 후 AWS CLI 명령어가 잘 동작하는지 확인합니다.

```bash
$ aws --version
aws-cli/2.7.0 Python/3.9.12 Darwin/21.4.0 source/arm64 prompt/off
```

AWS CLI 2.7.0 버전이 설치된 상태입니다.

&nbsp;

## 확인방법  

### 명령어 형식

```bash
$ aws ec2 describe-instance-type-offerings \
    --filters Name=instance-type,Values=<INSTANCE-TYPE> \
    --location-type availability-zone \
    --region <REGION>
```

`INSTANCE-TYPE`과 `REGION` 값은 각자 상황에 맞게 변경해서 실행합니다.  
AWS Region 리스트는 [AWS 공식문서](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions)에서 확인할 수 있습니다.

&nbsp;

### 명령어 예시

#### 예제 1 명령어

`g4dn.xlarge` 인스턴스 타입(GPU)이 도쿄 리전<sup>`ap-northeast-1`</sup>의 어떤 가용영역<sup>AZ, Availiability Zone</sup>에서 지원하는지 확인하는 명령어

```bash
$ aws ec2 describe-instance-type-offerings \
    --filters Name=instance-type,Values=g4dn.xlarge \
    --location-type availability-zone \
    --region ap-northeast-1
```

&nbsp;

#### 예제 1 결과값

```json
{
    "InstanceTypeOfferings": [
        {
            "InstanceType": "g4dn.xlarge",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-1b"
        },
        {
            "InstanceType": "g4dn.xlarge",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-1d"
        },
        {
            "InstanceType": "g4dn.xlarge",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-1c"
        }
    ]
}
```

`g4dn.xlarge` 인스턴스 타입은 도쿄 리전<sup>ap-northeast-1</sup>의 가용영역 b, c, d에서만 지원하고 있습니다.

&nbsp;

#### 예제 2 명령어

`t3.medium` 인스턴스 타입이 서울 리전<sup>`ap-northeast-2`</sup>의 어떤 가용영역<sup>AZ, Availiability Zone</sup>에서 지원하는지 확인하는 명령어

```bash
$ aws ec2 describe-instance-type-offerings \
    --filters Name=instance-type,Values=t3.medium \
    --location-type availability-zone \
    --region ap-northeast-2
```

&nbsp;

#### 예제 2 결과값

```json
{
    "InstanceTypeOfferings": [
        {
            "InstanceType": "t3.medium",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-2b"
        },
        {
            "InstanceType": "t3.medium",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-2d"
        },
        {
            "InstanceType": "t3.medium",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-2c"
        },
        {
            "InstanceType": "t3.medium",
            "LocationType": "availability-zone",
            "Location": "ap-northeast-2a"
        }
    ]
}
```

`t3.medium` 인스턴스 타입은 서울 리전<sup>ap-northeast-2</sup>의 가용영역 전체(a, b, c, d)에서 지원하고 있습니다.  
`t2`나 `t3`가 속한 범용 인스턴스 패밀리는 일반적으로 모든 가용영역에서 지원하고 있습니다.  

&nbsp;

## 참고자료

Example 3: To check whether an instance type is supported 섹션을 참고  
[AWS CLI Command Reference - describe-instance-type-offerings](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instance-type-offerings.html#examples)
