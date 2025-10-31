---
title: aws provider eks compatibility
date: 2025-10-28T09:50:00+09:00
lastmod: 2025-10-28T09:50:30+09:00
description: Terraform AWS Provider 6.2 업그레이드 시 EKS 모듈과의 호환성 문제 및 해결 방법
keywords: []
tags: ["kubernetes", "eks", "terraform"] 
---

## 개요

Terraform의 hashicorp/aws Provider를 6.2 버전으로 업그레이드하면 terraform-aws-modules/eks 모듈(v17.24.0)과 충돌이 발생합니다. 이는 AWS가 Elastic Inference 서비스를 종료하면서 관련 코드를 Provider에서 제거했지만, EKS 모듈에서는 아직 해당 코드를 참조하고 있기 때문입니다.

**해결 방법**: hashicorp/aws Provider 버전을 5.x대로 고정하면 문제없이 사용할 수 있습니다.

## 문제 상황

AWS Provider 6.2 최신 버전과 EKS 모듈 v17.24.0 간의 호환성 문제로 인해 `terraform plan` 실행 시 다음과 같은 오류가 발생합니다:

```bash
Error: Unsupported block type

  on .terraform/modules/eks/workers_launch_template.tf line 359, in resource "aws_launch_template" "workers_launch_template":
  359:   dynamic "elastic_inference_accelerator" {

Blocks of type "elastic_inference_accelerator" are not expected here.
```

## 원인

AWS Provider 6.x 버전에서 `elastic_inference_accelerator` 블록이 제거되었으나, EKS 모듈 v17.24.0에서는 여전히 해당 블록을 참조하고 있어 발생하는 문제입니다.

Amazon Elastic Inference 서비스가 2024년 4월 종료되면서 관련 Terraform 리소스들이 AWS Provider 6.0+에서 제거되었습니다.

## 해결 방법

### 1단계: AWS Provider 버전 고정

EKS 리소스 디렉토리의 `versions.tf` 파일을 열어 AWS Provider 버전을 6.0 미만으로 제한합니다:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72, < 6.0"  # 6.0 미만으로 제한
    }
  }
}
```

> **참고**: AWS Provider 5.100.0은 EKS 모듈 v17.24.0과 호환됩니다.

### 2단계: Terraform 재초기화

변경된 버전 제약을 적용합니다:

```bash
terraform init -upgrade
```

정상적으로 5.x 버전이 설치되었는지 확인하세요:

```bash
...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)
...
```

### 3단계: 변경사항 확인

```bash
terraform plan
```

오류 없이 plan이 실행되면 성공입니다. 이제 `terraform apply`를 실행할 수 있습니다.

## 향후 대응

- AWS Provider 6.x 버전 사용 시 EKS 모듈 업그레이드 필요
- 호환성 매트릭스 확인 후 단계적 업그레이드 진행
- 새로운 EKS 모듈 버전에서 `elastic_inference_accelerator` 블록 제거 확인 필요

## 관련 참고 자료

- [AWS Provider 6.0 릴리즈 노트](https://github.com/hashicorp/terraform-provider-aws/issues/41101)
- [Elastic Inference 서비스 종료 관련 이슈](https://github.com/hashicorp/terraform-provider-aws/issues/40992)
- [EKS 모듈 v17에서 v18 업그레이드 가이드](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1744)
- [Amazon Elastic Inference 서비스 종료 공지](https://docs.aws.amazon.com/sagemaker/latest/dg/ei.html)
