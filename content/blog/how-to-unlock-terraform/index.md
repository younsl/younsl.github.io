---
title: "terraform state lock 해제"
date: 2022-11-25T12:34:15+09:00
lastmod: 2023-08-21T23:11:25+09:00
slug: ""
description: "terraform state lock 해제 가이드"
keywords: []
tags: ["terraform"]
---

## 증상

터미널에서 `terraform plan`, `terraform apply` 명령어가 실행되지 않는 문제가 발생했습니다.

`terraform` 명령어 실행시 `Error: Error acquiring the state lock` 에러 메세지를 리턴합니다.

```bash
$ terraform apply -auto-approve
╷
│ Error: Error acquiring the state lock
│
│ Error message: ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        c963bf90-7ef8-bd88-2d5b-cbfbab8db3ca
│   Path:      xxxxxxxxx-blahblah-xxxx-terraform-state/aws-xxxx/terraform.tfstate
│   Operation: OperationTypePlan
│   Who:       cysl@xxxx-xxxx.local
│   Version:   1.3.5
│   Created:   2022-11-23 08:10:24.298672 +0000 UTC
│   Info:
│
│
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.
```

현재 다른 유저가 `.tfstate` 파일을 잡고 점유하고 있어서 테라폼 명령어를 실행할 수 없는 상황입니다.

&nbsp;

## 환경

로컬 맥북에 설치된 테라폼 환경입니다.

```bash
$ terraform -v
Terraform v1.3.5
on darwin_arm64
+ provider registry.terraform.io/hashicorp/aws v4.30.0
+ provider registry.terraform.io/hashicorp/cloudinit v2.2.0
```

&nbsp;

## 해결방법

### force-unlock

`terraform force-unlock` 명령어를 사용해서 state에 걸려있는 lock을 해제할 수 있습니다.

```bash
$ terraform force-unlock -force c963bf90-7ef8-bd88-2d5b-cbfbab8db3ca
Terraform state has been successfully unlocked!

The state has been unlocked, and Terraform commands should now be able to
obtain a new lock on the remote state.
```

락 세션이 해제되었습니다.

이후 실패했던 `terraform` 명령어를 다시 실행하면 됩니다.

```bash
$ terraform apply -auto-approve
```

&nbsp;

### -lock flag

#### 주의사항

`-lock=false` 옵션은 Terraform 실행 시에 다른 작업이 인프라스트럭처 상태 파일에 접근하지 못하도록 [락을 걸지 않는 것](https://developer.hashicorp.com/terraform/cli/commands/apply#lock-false)을 의미합니다.

`-lock=false` 옵션을 사용하면 동시에 여러 명의 엔지니어가 같은 테라폼 리소스를 수정하려고 할 때 충돌이 발생할 수 있습니다. 프로덕션 환경에 있는 리소스의 경우 위험한 상황이 발생할 수 있음을 인지하고 실행하도록 합니다.

&nbsp;

#### 사용법

`terraform force-unlock` 방법으로 해결이 안될 경우, 이 방법으로 시도하면 됩니다.

```bash
$ terraform apply -lock=false
```

자세한 사항은 [terraform apply 공식문서](https://developer.hashicorp.com/terraform/cli/commands/apply#lock-false)를 참고하세요.

&nbsp;

## 참고자료

[terraform lock 해결방안](https://sarc.io/index.php/cloud/2127-terraform-lock)  
삵<sup>sarc.io</sup>에 올라온 가이드

[Command: force-unlock](https://developer.hashicorp.com/terraform/cli/commands/force-unlock)  
Terraform 명령어 공식문서

[Command: apply](https://developer.hashicorp.com/terraform/cli/commands/apply#lock-false)  
Terraform 명령어 공식문서
