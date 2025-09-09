---
title: eks module v20 to v21
date: 2025-09-04T09:09:40+09:00
lastmod: 2025-09-04T09:09:45+09:00
slug: ""
description: Terraform EKS 모듈 v20에서 v21로 업그레이드하는 절차입니다. 
keywords: []
tags: ["devops", "kubernetes", "terraform"]
---

## 개요

EKS 테라폼 모듈 v20.37.2을 v21.1.0으로 업그레이드하는 방법을 정리한 문서입니다.

EKS Terraform Module로 EKS 클러스터를 관리하는 DevOps Engineer를 대상으로 작성되었습니다.

## 배경지식

[EKS 모듈 v17에서 v20 업그레이드 가이드](/blog/eks-module-v17-to-v18)를 토대로 terraform-aws-modules/eks/aws v20이 준비된 상태에서 v21로 버전 업그레이드를 수행합니다.

## 업그레이드 절차

아래 시나리오는 terraform-aws-modules/eks/aws v20.37.2를 v21.1.0로 업그레이드하는 과정을 설명합니다.

메인 테라폼 코드에서 EKS 모듈 버전을 업그레이드합니다.

```hcl
# main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.0" # Bump from 20.37.2 to 21.1.0
}
```

terraform-aws-modules/eks/aws v21 버전부터는 aws provider v6.x 버전과 완전히 호환되므로, versions.tf를 통해 AWS Provider 버전을 6.0 미만으로 강제할 필요가 없습니다.

karpenter 서브모듈은 eks 모듈에 포함되어 있습니다. 만약 Karpenter 서브모듈도 같이 사용하고 있다면 EKS 모듈과 버전을 동일하게 맞춰줍니다.

```hcl
# main.tf
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.1.0" # Bump from 20.37.2 to 21.1.0
}
```

EKS 모듈의 변수 이름 변경:

EKS 모듈 v21의 가장 큰 변경사항은 모든 변수 이름에서 `cluster_` prefix가 제거된다는 점입니다.

대부분의 Variable 이름이 변경 범위에 해당되므로 아래 공식 가이드에 언급된 변경사항을 참고해서 테라폼 코드에 반영합니다.

```hcl
# main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.0" # Bump from 20.37.2 to 21.1.0

  # cluster_name -> name
  name = local.name

  # cluster_version -> kubernetes_version
  kubernetes_version = local.cluster_version
}
```

변경 대상 Variable 목록

- Variables prefixed with `cluster_*` have been stripped of the prefix to better match the underlying API:
  - `cluster_name` -> `name`
  - `cluster_version` -> `kubernetes_version`
  - `cluster_enabled_log_types` -> `enabled_log_types`
  - `cluster_force_update_version` -> `force_update_version`
  - `cluster_compute_config` -> `compute_config`
  - `cluster_upgrade_policy` -> `upgrade_policy`
  - `cluster_remote_network_config` -> `remote_network_config`
  - `cluster_zonal_shift_config` -> `zonal_shift_config`
  - `cluster_additional_security_group_ids` -> `additional_security_group_ids`
  - `cluster_endpoint_private_access` -> `endpoint_private_access`
  - `cluster_endpoint_public_access` -> `endpoint_public_access`
  - `cluster_endpoint_public_access_cidrs` -> `endpoint_public_access_cidrs`
  - `cluster_ip_family` -> `ip_family`
  - `cluster_service_ipv4_cidr` -> `service_ipv4_cidr`
  - `cluster_service_ipv6_cidr` -> `service_ipv6_cidr`
  - `cluster_encryption_config` -> `encryption_config`
  - `create_cluster_primary_security_group_tags` -> `create_primary_security_group_tags`
  - `cluster_timeouts` -> `timeouts`
  - `create_cluster_security_group` -> `create_security_group`
  - `cluster_security_group_id` -> `security_group_id`
  - `cluster_security_group_name` -> `security_group_name`
  - `cluster_security_group_use_name_prefix` -> `security_group_use_name_prefix`
  - `cluster_security_group_description` -> `security_group_description`
  - `cluster_security_group_additional_rules` -> `security_group_additional_rules`
  - `cluster_security_group_tags` -> `security_group_tags`
  - `cluster_encryption_policy_use_name_prefix` -> `encryption_policy_use_name_prefix`
  - `cluster_encryption_policy_name` -> `encryption_policy_name`
  - `cluster_encryption_policy_description` -> `encryption_policy_description`
  - `cluster_encryption_policy_path` -> `encryption_policy_path`
  - `cluster_encryption_policy_tags` -> `encryption_policy_tags`
  - `cluster_addons` -> `addons`
  - `cluster_addons_timeouts` -> `addons_timeouts`
  - `cluster_identity_providers` -> `identity_providers`
- `eks-managed-node-group` sub-module
  - `cluster_version` -> `kubernetes_version`
- `self-managed-node-group` sub-module
  - `cluster_version` -> `kubernetes_version`
  - `delete_timeout` -> `timeouts`
- `fargate-profile` sub-module
  - None
- `karpenter` sub-module
  - None

self_managed_node_group_defaults를 삭제합니다. terraform-aws-modules/eks/aws v21.x부터 지원되지 않는 값입니다.

```hcl
# main.tf
module "eks" {
  # self_managed_node_group_defaults = {
  #   ami_type               = "AL2023_x86_64_STANDARD"
  #   vpc_security_group_ids = [aws_security_group.sg_eks_worker_from_lb.id]
  # }
}
```

mixed_instances_policy의 launch_template 값과 vpc_security_group_ids 값을 추가합니다. self_managed_node_groups에 선언된 노드 그룹이 여러개인 경우 이 과정을 반복합니다.

```hcl
# main.tf
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "21.1.0" # Bump from 20.37.2 to 21.1.0

    self_managed_node_groups = {
        my_nodegroup_1 = {
            vpc_security_group_ids = [
                aws_security_group.sg_eks_worker_from_lb.id
            ]

            mixed_instances_policy = {
                # Add launch_template in mixed_instances_policy
                launch_template = {
                    override = [
                        {
                            instance_requirements = {
                                cpu_manufacturers                           = ["intel"]
                                instance_generations                        = ["current", "previous"]
                                spot_max_price_percentage_over_lowest_price = 100

                                vcpu_count = {
                                    min = 1
                                }

                                allowed_instance_types = ["t*", "m*"]
                            }
                        }
                    ]
                }
            }
        }
    }
}
```

Terraform EKS module v21.1.0 부터는 [EKS 삭제 방지(Deletion Protection)](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/deletion-protection.html) 기능이 지원되므로 아래와 같이 deletion_protection 값을 설정하는 걸 권장합니다. 실수에 의한 클러스터 삭제를 방지할 수 있습니다.

```hcl
# main.tf
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "21.1.0"

    name                = local.name
    kubernetes_version  = local.cluster_version
    deletion_protection = true
}
```

v21.1.0 버전 기준으로 모든 변경사항이 반영 완료된 경우, EKS 모듈 버전 업그레이드를 수행합니다.

```bash
terraform init -upgrade
terraform plan
terraform apply
```

## 결론

### Terraform Module 운영 모범사례

EKS 테라폼 모듈은 기능이 많고 복잡한 구조를 가지고 있어, 메이저 버전 간격이 너무 벌어지면 업그레이드 작업이 기하급수적으로 복잡해집니다. 특히 여러 메이저 버전을 건너뛰게 되면 영향도 큰 변경사항(Breaking Changes)이 누적되어 마이그레이션 작업이 매우 어려워질 수 있습니다.

따라서 EKS 테라폼 모듈을 사용하는 환경에서는 메이저 버전이 릴리즈될 때마다 틈틈이 업그레이드를 따라가는 것이 중요합니다. 이를 통해 각 업그레이드 단계의 변경사항을 점진적으로 적용할 수 있고, 전체적인 유지보수 부담을 줄일 수 있습니다.

## 관련자료

- [Upgrade from v20.x to v21.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-21.0.md)
- [Example code for terraform-aws-modules/eks/aws v21.0.7](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v21.0.7/examples/self-managed-node-group)
- [eks module v17 to v18](/blog/eks-module-v17-to-v18): 제가 작성한 EKS terraform module v17에서 v18로 업그레이드하는 가이드입니다.
