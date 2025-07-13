---
title: "terraform nodegroup delete"
date: 2024-10-21T21:34:00+09:00
lastmod: 2024-10-21T21:34:00+09:00
slug: ""
description: "v18 이하 버전의 EKS 모듈에서 노드그룹을 안전하게 삭제하는 절차를 설명합니다"
keywords: []
tags: ["devops", "iac", "terraform"]
---

## 개요

EKS 모듈 v18 이전 버전에서는 노드 그룹이 list 구조로 관리되기 때문에, 중간 노드 그룹을 삭제하면 인덱스가 재정렬되며 이후 모든 노드 그룹이 재생성되는 문제가 있습니다.

이는 서비스 장애를 유발할 수 있으므로 주의가 필요합니다. 문제를 방지하려면 `terraform state mv` 명령어로 인덱스를 재정렬한 후, ASG<sup>Auto Scaling Group</sup>, Launch Template 등의 노드 그룹 리소스를 수작업으로 안전하게 삭제해야 합니다.

&nbsp;

## 배경지식

### 권장되는 노드그룹 삭제 방식

새로운 워커 그룹을 추가한 후, 목록 상단의 워커 그룹을 삭제하면 Terraform이 모든 워커 그룹을 재생성하려고 합니다. 이는 Terraform의 count 사용 방식과 모듈의 제한 때문입니다. 가장 안전하고 간단한 방법은 "제거"할 워커 그룹의 `asg_min_size`와 `asg_max_size` 값을 0으로 설정하는 것입니다.

이 문제는 Terraform이 **count**로 리소스를 생성할 때 발생하는 특성 때문입니다. 워커 그룹이 list 형태로 정의되면, 리스트의 인덱스 순서가 중요해지며, 상단의 요소를 삭제할 경우 해당 인덱스 뒤에 있는 리소스들이 전부 재생성됩니다.

반면에 map을 사용하면 키-값 기반으로 관리되기 때문에 특정 리소스를 삭제해도 다른 리소스에 영향을 주지 않습니다. 하지만 이 모듈에서는 list와 count를 조합해 사용하므로 인덱스가 변경될 때 의도치 않은 재생성이 발생합니다.

이런 이유로, 안전한 방법으로는 기존 워커 그룹을 삭제하지 않고 **asg_min_size**와 **asg_max_size**를 0으로 설정해 비활성화하는 것이 권장됩니다.

자세한 사항은 [FAQ 페이지의 How do I safely remove old worker groups](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v17.24.0/docs/faq.md#how-do-i-safely-remove-old-worker-groups)를 참고합니다. 해당 가이드에서는 최소<sup>`asg_min_size`</sup>/최대 노드 풀<sup>`asg_max_size`</sup> 크기를 `0`으로 설정하고 빈 노드 풀을 그대로 두는 것을 제안합니다.

&nbsp;

### EKS 모듈 v17과 v18 노드 그룹 코드 비교

아래는 EKS 모듈 v17.x 코드입니다. `worker_groups_launch_template`에서 첫 번째 워커 그룹(frontend-node-group)을 삭제하면, 이후 그룹들의 인덱스가 변경됩니다. 이로 인해 Terraform이 인덱스가 바뀐 그룹들을 재생성하려고 시도합니다.

리스트 구조에서는 각 노드 그룹이 배열의 객체로 정의되며, 인덱스 순서가 중요합니다. 하나의 그룹을 삭제하면 나머지 그룹들의 인덱스가 재정렬되어 문제가 발생할 수 있습니다.

```terraform
# main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  # worker_groups_launch_template는 "리스트(List)" 구조입니다.
  # 각 항목은 노드 그룹 설정을 담고 있는 객체(Object)입니다.
  worker_groups_launch_template = [
    {
      name                 = "frontend-node-group"

      asg_min_size         = 2
      asg_max_size         = 5
      asg_desired_capacity = 3
      instance_type        = "t3.medium"
    },
    {
      name                 = "backend-node-group"

      asg_min_size         = 2
      asg_max_size         = 4
      asg_desired_capacity = 3
      instance_type        = "t3.large"
    },
    {
      name                 = "data-processing-node-group"

      asg_min_size         = 1
      asg_max_size         = 3
      asg_desired_capacity = 2
      instance_type        = "t3.xlarge"
    }
  ]
}
```

&nbsp;

EKS `v18` 모듈부터는 `List`에서 `Map` 구조로 전환되면서 인덱스 기반 재생성 문제가 해소되었습니다. 이로 인해 더 유연하게 워커 그룹을 관리할 수 있으며, 삭제 시에도 안전하게 비활성화할 수 있습니다.

```terraform
# main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  # self_managed_node_groups는 "맵(Map)" 구조입니다.
  # 각 key(frontend, backend, data_processing)는 노드 그룹 이름이며,
  # 각 value는 노드 그룹 설정을 담고 있는 객체(Object)입니다.
  self_managed_node_groups = {
    frontend = {
      name          = "frontend-node-group"

      min_size      = 2
      max_size      = 5
      desired_size  = 3
      instance_type = "t3.medium"
    },
    backend = {
      name          = "backend-node-group"

      min_size      = 2
      max_size      = 4
      desired_size  = 3
      instance_type = "t3.large"
    },
    data_processing = {
      name             = "data-processing-node-group"
      
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = "t3.xlarge"
    }
  }
}
```

&nbsp;

## 삭제방법

### 1. 백업 및 리소스 조회

EKS 모듈 v17.x 기준으로 중간의 노드그룹을 안전하게 삭제하는 절차는 다음과 같습니다.

&nbsp;

기존 EKS 구성의 Terraform 상태 파일을 백업하려면 다음 명령을 실행하세요:

```bash
export AWS_PROIFLE=<YOUR_PROFILE>
terraform init
terraform state pull > terraform-backup.tfstate
```

기존 EKS 구성의 Terraform 상태 파일을 백업하면 실수나 파일 손상 시 빠르게 복구해 예상치 못한 리소스 재생성이나 장애를 방지할 수 있습니다.

&nbsp;

모든 노드그룹에 대한 리소스를 조회합니다. EKS module v17 기준으로 한 노드그룹은 3개의 리소스(ASG, Launch Template, Instance Profile)로 구성됩니다.

```bash
$ terraform state list
module.eks.aws_autoscaling_group.workers_launch_template[0]
module.eks.aws_autoscaling_group.workers_launch_template[1] # <-- target nodegroup to delete
module.eks.aws_autoscaling_group.workers_launch_template[2]
module.eks.aws_autoscaling_group.workers_launch_template[3]
module.eks.aws_autoscaling_group.workers_launch_template[4]
module.eks.aws_autoscaling_group.workers_launch_template[5]
module.eks.aws_autoscaling_group.workers_launch_template[6]
module.eks.aws_autoscaling_group.workers_launch_template[7]
module.eks.aws_autoscaling_group.workers_launch_template[8]
module.eks.aws_autoscaling_group.workers_launch_template[9]
module.eks.aws_autoscaling_group.workers_launch_template[10]
module.eks.aws_autoscaling_group.workers_launch_template[11]
module.eks.aws_autoscaling_group.workers_launch_template[12]
... truncated ...
module.eks.aws_iam_instance_profile.workers_launch_template[0]
module.eks.aws_iam_instance_profile.workers_launch_template[1] # <-- target nodegroup to delete
module.eks.aws_iam_instance_profile.workers_launch_template[2]
module.eks.aws_iam_instance_profile.workers_launch_template[3]
module.eks.aws_iam_instance_profile.workers_launch_template[4]
module.eks.aws_iam_instance_profile.workers_launch_template[5]
module.eks.aws_iam_instance_profile.workers_launch_template[6]
module.eks.aws_iam_instance_profile.workers_launch_template[7]
module.eks.aws_iam_instance_profile.workers_launch_template[8]
module.eks.aws_iam_instance_profile.workers_launch_template[9]
module.eks.aws_iam_instance_profile.workers_launch_template[10]
module.eks.aws_iam_instance_profile.workers_launch_template[11]
module.eks.aws_iam_instance_profile.workers_launch_template[12]
... truncated ...
module.eks.aws_launch_template.workers_launch_template[0]
module.eks.aws_launch_template.workers_launch_template[1] # <-- target nodegroup to delete
module.eks.aws_launch_template.workers_launch_template[2]
module.eks.aws_launch_template.workers_launch_template[3]
module.eks.aws_launch_template.workers_launch_template[4]
module.eks.aws_launch_template.workers_launch_template[5]
module.eks.aws_launch_template.workers_launch_template[6]
module.eks.aws_launch_template.workers_launch_template[7]
module.eks.aws_launch_template.workers_launch_template[8]
module.eks.aws_launch_template.workers_launch_template[9]
module.eks.aws_launch_template.workers_launch_template[10]
module.eks.aws_launch_template.workers_launch_template[11]
module.eks.aws_launch_template.workers_launch_template[12]
```

&nbsp;

### 2. 스크립트 설정 및 인덱스 삭제 준비

`reindex-workers.sh` 스크립트는 삭제할 노드그룹에 대한 인덱스를 삭제하고, 비어있는 인덱스를 채우기 위해 그 이후 인덱스들에 대한 노드그룹을 하나씩 앞당기는 스크립트입니다.

```bash
# reindex-workers.sh
resource_base="module.eks.aws_launch_template.workers_launch_template"
# resource_base="module.eks.aws_autoscaling_group.workers_launch_template"
# resource_base="module.eks.aws_iam_instance_profile.workers_launch_template"
```

`reindex-workers.sh` 스크립트의 환경변수를 설정한 후 실행합니다:

```bash
# reindex-workers.sh
deletion_target_index=1  # 삭제할 노드그룹의 인덱스
total_resources=13       # 전체 리소스 개수 (마지막 인덱스 + 1)
```

<details>
<summary>reindex-workers.sh</summary>
  
```bash
#!/bin/bash

# 리소스의 베이스 경로
resource_base="module.eks.aws_autoscaling_group.workers_launch_template"
# resource_base="module.eks.aws_iam_instance_profile.workers_launch_template"
#resource_base="module.eks.aws_launch_template.workers_launch_template"

# 삭제할 대상 인덱스 (예: 1)
deletion_target_index=1

# 총 리소스 개수
total_resources=13

# 삭제할 리소스 이름 출력 함수
print_deletion_info() {
  echo "!! YOU ARE ABOUT TO DELETE:"
  echo "- $resource_base[$deletion_target_index]"
}

# 인덱스 재배치 목록 출력 함수
print_reindexing_info() {
  echo "!! THE FOLLOWING RESOURCES WILL BE MOVED:"
  for (( i=deletion_target_index + 1; i<total_resources; i++ )); do
    old_index=$i  # 현재 인덱스
    new_index=$((i - 1))  # 새로운 인덱스
    echo "~ Moving $resource_base[$old_index] -> $resource_base[$new_index]"
  done
}

# 리소스 삭제 함수
delete_resource() {
  terraform state rm "$resource_base[$deletion_target_index]"
}

# 인덱스 재배치 함수
reindex_resources() {
  for (( i=deletion_target_index + 1; i<total_resources; i++ )); do
    old_index=$i  # 현재 인덱스
    new_index=$((i - 1))  # 새로운 인덱스
    echo "Moving $resource_base[$old_index] -> $resource_base[$new_index]"
    terraform state mv "$resource_base[$old_index]" "$resource_base[$new_index]"
  done
}

# 사용자 확인 및 실행 함수
confirm_and_execute() {
  read -p "Do you want to proceed with these changes? (y/n): " confirmation
  if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
    delete_resource
    reindex_resources
    echo "Changes completed."
  else
    echo "Operation canceled."
  fi
}

# 메인 실행 흐름
print_deletion_info
print_reindexing_info
confirm_and_execute
```

</details>

&nbsp;

### 3. 인덱스 삭제 및 재배열 실행

아래 명령어를 실행하여 삭제 대상 노드 그룹과 인덱스 재배열 작업을 확인합니다.

```bash
sh reindex-workers.sh
```

&nbsp;

스크립트가 삭제할 리소스를 표시하며 사용자에게 확인을 요청합니다.

```bash
!! YOU ARE ABOUT TO DELETE:
- module.eks.aws_autoscaling_group.workers_launch_template[1]
!! THE FOLLOWING RESOURCES WILL BE MOVED:
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[2] -> module.eks.aws_autoscaling_group.workers_launch_template[1]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[3] -> module.eks.aws_autoscaling_group.workers_launch_template[2]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[4] -> module.eks.aws_autoscaling_group.workers_launch_template[3]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[5] -> module.eks.aws_autoscaling_group.workers_launch_template[4]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[6] -> module.eks.aws_autoscaling_group.workers_launch_template[5]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[7] -> module.eks.aws_autoscaling_group.workers_launch_template[6]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[8] -> module.eks.aws_autoscaling_group.workers_launch_template[7]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[9] -> module.eks.aws_autoscaling_group.workers_launch_template[8]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[10] -> module.eks.aws_autoscaling_group.workers_launch_template[9]
~ Moving module.eks.aws_autoscaling_group.workers_launch_template[11] -> module.eks.aws_autoscaling_group.workers_launch_template[10]
~ Moving mmodule.eks.aws_autoscaling_group.workers_launch_template[12] -> module.eks.aws_autoscaling_group.workers_launch_template[11]
Do you want to proceed with these changes? (y/n): y
```

`y` 키를 입력하면 삭제 및 인덱스 재배열이 시작됩니다.

&nbsp;

```bash
Removed module.eks.aws_autoscaling_group.workers_launch_template[1]
Successfully removed 1 resource instance(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[2] -> module.eks.aws_autoscaling_group.workers_launch_template[1]
Move "module.eks.aws_autoscaling_group.workers_launch_template[2]" to "module.eks.aws_autoscaling_group.workers_launch_template[1]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[3] -> module.eks.aws_autoscaling_group.workers_launch_template[2]
Move "module.eks.aws_autoscaling_group.workers_launch_template[3]" to "module.eks.aws_autoscaling_group.workers_launch_template[2]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[4] -> module.eks.aws_autoscaling_group.workers_launch_template[3]
Move "module.eks.aws_autoscaling_group.workers_launch_template[4]" to "module.eks.aws_autoscaling_group.workers_launch_template[3]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[5] -> module.eks.aws_autoscaling_group.workers_launch_template[4]
Move "module.eks.aws_autoscaling_group.workers_launch_template[5]" to "module.eks.aws_autoscaling_group.workers_launch_template[4]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[6] -> module.eks.aws_autoscaling_group.workers_launch_template[5]
Move "module.eks.aws_autoscaling_group.workers_launch_template[6]" to "module.eks.aws_autoscaling_group.workers_launch_template[5]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[7] -> module.eks.aws_autoscaling_group.workers_launch_template[6]
Move "module.eks.aws_autoscaling_group.workers_launch_template[7]" to "module.eks.aws_autoscaling_group.workers_launch_template[6]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[8] -> module.eks.aws_autoscaling_group.workers_launch_template[7]
Move "module.eks.aws_autoscaling_group.workers_launch_template[8]" to "module.eks.aws_autoscaling_group.workers_launch_template[7]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[9] -> module.eks.aws_autoscaling_group.workers_launch_template[8]
Move "module.eks.aws_autoscaling_group.workers_launch_template[9]" to "module.eks.aws_autoscaling_group.workers_launch_template[8]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[10] -> module.eks.aws_autoscaling_group.workers_launch_template[9]
Move "module.eks.aws_autoscaling_group.workers_launch_template[10]" to "module.eks.aws_autoscaling_group.workers_launch_template[9]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[11] -> module.eks.aws_autoscaling_group.workers_launch_template[10]
Move "module.eks.aws_autoscaling_group.workers_launch_template[11]" to "module.eks.aws_autoscaling_group.workers_launch_template[10]"
Successfully moved 1 object(s).
Moving module.eks.aws_autoscaling_group.workers_launch_template[12] -> module.eks.aws_autoscaling_group.workers_launch_template[11]
Move "module.eks.aws_autoscaling_group.workers_launch_template[12]" to "module.eks.aws_autoscaling_group.workers_launch_template[11]"
Successfully moved 1 object(s).
Changes completed
```

하나의 노드그룹은 `aws_autoscaling_group`, `aws_instance_profile`, `aws_launch_template` 등의 리소스로 구성되므로 만약 테라폼 구성에서 해당된다면 `resource_base` 값을 바꿔서 이어서 인덱스를 재배열<sup>reindexing</sup> 합니다.

1. `aws_autoscaling_group`
2. `aws_instance_profile`
3. `aws_launch_template`

```bash
# reindex-workers.sh
# resource_base="module.eks.aws_autoscaling_group.workers_launch_template"
resource_base="module.eks.aws_iam_instance_profile.workers_launch_template"
# resource_base="module.eks.aws_launch_template.workers_launch_template"
```

```bash
# reindex-workers.sh
# resource_base="module.eks.aws_autoscaling_group.workers_launch_template"
# resource_base="module.eks.aws_iam_instance_profile.workers_launch_template"
resource_base="module.eks.aws_launch_template.workers_launch_template"
```

&nbsp;

### 4. 변경사항 적용 및 최종 검증

삭제 및 재배열 후 인덱스가 정상적으로 정리되었는지 확인합니다.

```bash
terraform state list
```

```bash
module.eks.aws_autoscaling_group.workers_launch_template[0]
module.eks.aws_autoscaling_group.workers_launch_template[1]
module.eks.aws_autoscaling_group.workers_launch_template[2]
module.eks.aws_autoscaling_group.workers_launch_template[3]
module.eks.aws_autoscaling_group.workers_launch_template[4]
module.eks.aws_autoscaling_group.workers_launch_template[5]
module.eks.aws_autoscaling_group.workers_launch_template[6]
module.eks.aws_autoscaling_group.workers_launch_template[7]
module.eks.aws_autoscaling_group.workers_launch_template[8]
module.eks.aws_autoscaling_group.workers_launch_template[9]
module.eks.aws_autoscaling_group.workers_launch_template[10]
module.eks.aws_autoscaling_group.workers_launch_template[11]
...
module.eks.aws_iam_instance_profile.workers_launch_template[0]
module.eks.aws_iam_instance_profile.workers_launch_template[1]
module.eks.aws_iam_instance_profile.workers_launch_template[2]
module.eks.aws_iam_instance_profile.workers_launch_template[3]
module.eks.aws_iam_instance_profile.workers_launch_template[4]
module.eks.aws_iam_instance_profile.workers_launch_template[5]
module.eks.aws_iam_instance_profile.workers_launch_template[6]
module.eks.aws_iam_instance_profile.workers_launch_template[7]
module.eks.aws_iam_instance_profile.workers_launch_template[8]
module.eks.aws_iam_instance_profile.workers_launch_template[9]
module.eks.aws_iam_instance_profile.workers_launch_template[10]
module.eks.aws_iam_instance_profile.workers_launch_template[11]
...
module.eks.aws_launch_template.workers_launch_template[0]
module.eks.aws_launch_template.workers_launch_template[1]
module.eks.aws_launch_template.workers_launch_template[2]
module.eks.aws_launch_template.workers_launch_template[3]
module.eks.aws_launch_template.workers_launch_template[4]
module.eks.aws_launch_template.workers_launch_template[5]
module.eks.aws_launch_template.workers_launch_template[6]
module.eks.aws_launch_template.workers_launch_template[7]
module.eks.aws_launch_template.workers_launch_template[8]
module.eks.aws_launch_template.workers_launch_template[9]
module.eks.aws_launch_template.workers_launch_template[10]
module.eks.aws_launch_template.workers_launch_template[11]
```

마지막 인덱스 번호가 `[12]`가 아닌 `[11]`로 삭제된 인덱스 번호를 채우기 위해 한칸씩 앞당겨진 걸 확인할 수 있습니다.

&nbsp;

변경 사항이 정상 반영되었는지 검토한 후, Terraform을 통해 코드를 적용합니다.

```bash
terraform plan
terraform apply
```

예상 결과 (인덱스가 재배열된 코드와 실제 인프라가 일치함을 의미):

```bash
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

위 메시지가 출력되면 코드와 state 파일이 완벽하게 일치하며, 추가적인 변경이 필요하지 않습니다.

만약 위와 같은 `No changes` 메세지가 나오지 않는다면, 기존에 백업해둔 `.tfstate` 파일을 사용해서 다시 원래 상태로 복구한 후, 트러블슈팅 과정을 진행합니다. 자세한 `.tfstate` 복구 절차는 [Terraform state restoration overview](https://support.hashicorp.com/hc/en-us/articles/4403065345555-Terraform-State-Restoration-Overview) 아티클을 참고합니다.

&nbsp;

### 5. 남은 리소스 삭제

직접 Management Console 또는 AWS CLI를 사용해서, `terraform state rm`으로 제거했던 ASG와 Launch Template 리소스를 삭제합니다.

&nbsp;

## 결론

> 노드그룹을 순차적으로 선언하는 EKS 모듈 v17 이하에서는 특정 노드그룹을 삭제할 때 인덱스 재배열이 필요합니다.

Terraform의 list 기반 인덱스 재배열 문제는 리소스 재생성을 유발할 수 있어, 변경 전 `terraform plan`으로 반드시 검토해야 합니다.

Terraform EKS 모듈 v18부터는 map 구조를 사용해 노드그룹을 선언하므로 인덱스 재배열의 문제가 자연스럽게 해결됩니다. 이를 통해 특정 노드그룹의 삭제나 변경 작업이 더 직관적이고 관리하기 쉬워졌습니다.

노드 그룹 삭제 시 ASG의 min/max 노드수를 0으로 설정하는 기존 방식은 리소스가 방치되고 코드가 누적되는 단점이 있습니다. 따라서, EKS 모듈 v17 이하 버전에서도 노드 그룹 인덱스를 재배열해 불필요한 리소스를 정리하는 것이 더 깔끔하고 효율적인 운영 방법입니다.

&nbsp;

## 관련자료

- [can't apply if trying to remove worker_groups_launch_template](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/887): Github issue
- [How do I safely remove old worker groups?](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v17.24.0/docs/faq.md#how-do-i-safely-remove-old-worker-groups): EKS module's FAQ