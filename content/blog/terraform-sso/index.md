---
title: "terraform sso"
date: 2024-10-20T13:01:00+09:00
lastmod: 2024-10-20T13:01:00+09:00
slug: ""
description: "AWS IAM Identity Center의 인증 환경에서 terraform CLI 사용하기"
keywords: []
tags: ["devops", "iac", "terraform"]
---

## 개요

이 문서는 AWS IAM Identity Center(SSO)를 활용하여 Terraform 환경을 설정하고 사용하는 방법을 안내합니다. 로컬 환경에서 `tfenv`로 Terraform 버전을 설정하고, AWS CLI와 연동된 SSO 프로파일로 여러 환경(dev, prd, ops)을 손쉽게 전환하여 Terraform을 실행할 수 있도록 돕습니다.

&nbsp;

## TLDR

### terraform CLI의 버전

⚠️ 중요: `terraform` CLI에서 AWS IAM Identity Center를 사용하려면 반드시 Terraform v1.6.0 이상을 사용해야 합니다. Terraform v1.6.0 미만에서는 AWS IAM Identity Center 관련 리소스를 지원하지 않기 때문에, 적절한 기능을 사용하려면 버전 업데이트가 필수적입니다.

현재 사용중인 Terraform 버전을 확인하려면:

```bash
terraform version
```

업데이트가 필요한 경우 tfenv와 같은 버전 관리 도구를 사용하여 쉽게 해결할 수 있습니다:

```bash
tfenv use 1.6.0
```

자세한 사항은 [#32465 이슈](https://github.com/hashicorp/terraform/issues/32465#issuecomment-1741080877)를 참고합니다.

&nbsp;

## 설정방법

[tfenv](https://github.com/tfutils/tfenv)는 여러 버전의 Terraform을 쉽게 관리할 수 있는 버전 관리 도구입니다. 이를 사용하면 다양한 프로젝트에서 요구하는 Terraform의 특정 버전을 쉽게 설치하고 전환할 수 있습니다. 이는 특히 여러 프로젝트에서 다른 Terraform 버전을 사용할 때 유용합니다.

이 시나리오에서는 tfenv를 사용하여 Terraform 버전을 설정하는 방법과 설명이 포함되어 있습니다.

&nbsp;

우선 `tfenv`를 설치해야 합니다. Homebrew를 사용하는 경우 다음 명령어로 간단히 설치할 수 있습니다:

```bash
brew install tfenv
tfenv -v
```

&nbsp;

`tfenv`를 사용해서 `terraform` 버전을 v1.6.0 이상으로 설정합니다.

```bash
tfenv use 1.6.0
```

&nbsp;

`tfenv`로 세팅된 현재 로컬 terraform 버전이 1.6.0임을 확인합니다.

```bash
$ tfenv list
* 1.6.0 (set by /opt/homebrew/Cellar/tfenv/3.0.0/version)
  1.3.2
```

```bash
$ terraform version
Terraform v1.6.0
on darwin_arm64

Your version of Terraform is out of date! The latest version
is 1.9.8. You can update by downloading from https://www.terraform.io/downloads.html
```

&nbsp;

아래와 같이 AWS CLI 설정파일이 작성되어 있는지 검증합니다:

```bash
cat ~/.aws/config
```

```bash
#--------------------------------------------
# IAM Roles provided by IAM Identity Center
#--------------------------------------------
[profile dev]
sso_session = ghost-company-sso
sso_account_id = 111122223333
sso_role_name = <YOUR_SSO_ROLE_NAME>
region = ap-northeast-2
output = json

[profile prd]
sso_session = ghost-company-sso
sso_account_id = 444455556666
sso_role_name = <YOUR_SSO_ROLE_NAME>
region = ap-northeast-2
output = json

[sso-session ghost-company-sso]
sso_start_url = https://<YOUR_SSO_DOMAIN>.awsapps.com/start/#
sso_region = ap-northeast-2
sso_registration_scopes = sso:account:access
```

&nbsp;

Terraform 코드 디렉토리로 이동한 후, 사용할 AWS 프로필을 설정합니다.

```bash
export AWS_PROFILE=dev
```

SSO로 환경에 로그인합니다.

```bash
aws sso login
```

또는, `asp` 명령어를 사용하여 더 간편하게 로그인할 수 있습니다.

```bash
# asp <PROFILE> login
asp dev login
```

`asp`는 AWS SSO 프로필 관리와 로그인을 자동화해주는 도구입니다. Zsh 플러그인 aws에 이미 내장되어 있으므로, 별도로 설치할 필요가 없습니다. Oh My Zsh을 사용하는 경우, `~/.zshrc` 파일에 `aws` 플러그인을 추가하여 `asp`를 바로 사용할 수 있습니다:

```bash
# $HOME/.zshrc
plugins=(
  aws
)
```

설정 후, 터미널을 다시 시작하거나 `source ~/.zshrc` 명령어로 플러그인을 적용하면 `asp` 명령어를 사용할 수 있습니다.

&nbsp;

SSO 로그인 성공 이후, 현재 자신이 점유하고 있는 SSO Role을 확인합니다.

```bash
$ aws sts-get-caller-identity
{
    "UserId": "XYZX43YZ5XYZXYZXYZOXY:<REDACTED>",
    "Account": "111122223333",
    "Arn": "arn:aws:sts::111122223333:assumed-role/AWSReservedSSO_<REDACTED>_<REDACTED>/<REDACTED>"
}
```

&nbsp;

이제 테라폼 디렉토리에 위치한 상태에서 `terraform` 명령어를 실행합니다.

```bash
terraform init
terraform plan
terraform apply
```

&nbsp;

이후 SSO IAM Role에 설정된 세션 유지시간 동안에는 다른 환경에서도 다음 절차로 `asp prd login` 등의 로그인 과정 없이 즉시 사용 가능합니다.

```bash
# "dev" 작업 이후 "prd" 환경의 테라폼 디렉토리로
# 다시 이동한 상황이라고 가정합니다.
export AWS_PROFILE=prd
terraform init
terraform plan
terraform apply
```

또는, `asp` 명령어를 사용해서 동일한 작업을 수행할 수 있습니다.

```bash
# "dev" 작업 이후 "prd" 환경의 테라폼 디렉토리로
# 다시 이동한 상황이라고 가정합니다.
asp prd
terraform init
terraform plan
terraform apply
```

&nbsp;

## 관련자료

아래 가이드 문서가 잘 정리되어 있습니다.

- [Guide to configuring AWS SSO with Terraform](https://overmind.tech/blog/guide-to-configuring-aws-sso-terraform)
- [관련 이슈 AWS S3 state backend fails with AWS SSO new profile format](https://github.com/hashicorp/terraform/issues/32465#issuecomment-1741080877)
