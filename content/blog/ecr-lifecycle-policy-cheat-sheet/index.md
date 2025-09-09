---
title: "ECR Lifecycle Policy 설정 가이드"
date: 2022-12-19T17:27:15+09:00
lastmod: 2023-07-26T22:15:25+09:00
slug: ""
description: "ECR Lifecycle Policy 설정 시에 참고할만한 가이드 문서"
keywords: []
tags: ["aws", "docker"]
---

## 개요

ECR Lifecycle Policy 설정이 필요한 이유와 설정시 참고할만한 정책 예시를 설명합니다.

&nbsp;

## 배경지식

### ECR Lifecycle Policy

ECR 기능 중 하나인 수명 주기 정책<sup>Lifecycle Policy</sup>을 사용하여 오래되거나 사용하지 않는 이미지를 자동으로 제거함으로써 컨테이너 이미지 리포지토리를 깔끔하게 정리할 수 있습니다.

[수명 주기 정책의 사용 예시](https://docs.aws.amazon.com/ko_kr/AmazonECR/latest/userguide/lifecycle_policy_examples.html)는 다음과 같습니다.

- 90일이 지난 태그가 없는 이미지 삭제
- 90일이 지난 개발 태그가 붙은 이미지 삭제
- 180일이 지난 스테이징 태그가 붙은 이미지 삭제
- 1년이 지난 프로덕션 태그가 붙은 이미지 삭제
- `latest` 태그가 붙은 이미지를 1개만 유지
- 태그가 달린 이미지를 최근 120개만 유지

&nbsp;

## ECR 수명 주기 정책 예시

```json
{
    "rules": [
        {
            "rulePriority": 10,
            "description": "Keep last 1 images tagged latest",
            "selection": {
              "tagStatus": "tagged",
              "tagPrefixList": ["latest"],
              "countType": "imageCountMoreThan",
              "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 20,
            "description": "Keep last 5 images tagged main",
            "selection": {
              "tagStatus": "tagged",
              "tagPrefixList": ["main"],
              "countType": "imageCountMoreThan",
              "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 980,
            "description": "Keep only one untagged image, expire all others",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 990,
            "description": "Keep only tagged images for 90 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 90
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 1000,
            "description": "Keep only 120 tagged images, expire all others",
            "selection": {
                "tagStatus": "tagged",
                "countType": "imageCountMoreThan",
                "countNumber": 120
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
```

각 Lifecycle Policy를 설명드리면 다음과 같습니다.

1. 우선순위 `10`인 규칙: `latest` 태그가 달린 이미지 중 가장 최근에 푸시된 1개의 이미지만 유지하고, 나머지는 자동 삭제됩니다.
2. 우선순위 `20`인 규칙: `main` 태그가 달린 이미지 중 최근 5개의 이미지만 유지하고, 나머지는 자동 삭제됩니다.
3. 우선순위 `980`인 규칙: 태그가 없는 이미지 중 가장 최근에 푸시된 1개의 이미지만 유지하고, 나머지는 자동 삭제됩니다.
4. 우선순위 `990`인 규칙: 모든 태그가 달린 이미지, 안달린 이미지들 중에 최근 90일 이내에 푸시된 이미지들만 유지하고, 이후의 이미지들은 자동 삭제됩니다.
5. 우선순위 `1000`인 규칙: 태그가 달린 이미지를 최근 120개만 유지하고, 120개를 초과하는 이미지들은 자동으로 삭제됩니다.

> [**규칙 우선순위**](https://docs.aws.amazon.com/ko_kr/AmazonECR/latest/userguide/LifecyclePolicies.html#lp_rule_priority)  
> 규칙 우선순위 값인 `rulePriority`가 낮을수록 중요도가 높은 것으로 해석되므로 해당 룰이 가장 먼저 적용됩니다.

&nbsp;

## 결론

ECR Lifecycle Policy를 설정하면 이미지 관리 및 저장소 용량 관리를 효과적으로 수행할 수 있습니다.  
자동화된 이미지 라이프사이클 관리를 통해 개발 및 운영팀에 시간을 절약하고, 컨테이너 이미지의 안정성과 일관성을 유지하는 데 도움을 줍니다.

&nbsp;

## 참고자료

[Amazon ECR 수명 주기 정책을 통한 컨테이너 이미지 자동 삭제 기능 출시](https://aws.amazon.com/ko/blogs/korea/clean-up-your-container-images-with-amazon-ecr-lifecycle-policies/)

[수명 주기 정책의 예제](https://docs.aws.amazon.com/ko_kr/AmazonECR/latest/userguide/lifecycle_policy_examples.html)  
AWS 공식문서

[Gist Example](https://gist.github.com/xiaket/b16623765e11a657cbe52b61f1aeda8d)
