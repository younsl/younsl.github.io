---
title: "eks module v17 to v18"
date: 2024-10-31T09:04:05+09:00
lastmod: 2024-10-31T09:04:20+09:00
slug: ""
description: "EKS 모듈을 v17에서 v18로 업그레이드하는 가이드"
keywords: []
tags: ["devops", "container", "kubernetes", "terraform"]
---

## 개요

다음 단계는 EKS 모듈을 v17에서 v18로 업그레이드하는 하나의 제안된 방법입니다. 이 과정에서는 EKS의 두 주요 컴포넌트인 제어 플레인과 데이터 플레인을 보존하는 방식으로 설계되었으며, 기존 데이터 플레인은 서비스 중단을 방지하기 위해 Terraform 제어 영역에서 제거됩니다.

현재 데이터 플레인을 제자리에서 업그레이드<sup>Inplace</sup>하는 방법은 제공되지 않으며, 이는 잠재적인 가동 중지 위험을 피하기 위함입니다. 따라서, 여기서 제안된 단계는 데이터 플레인 업그레이드에 블루/그린 접근 방식을 적용하여 가동 중지를 방지하도록 설계되었습니다.

이 방법에 따라 기존(v17) 데이터 플레인 구성 요소는 Terraform 제어에서 제거되고, 새(v18) 데이터 플레인 구성 요소와 함께 배포됩니다. 새(v18) 데이터 플레인이 프로비저닝된 이후, 이전(v17) 데이터 플레인 구성 요소를 봉쇄<sup>cordon</sup>하고 비우고<sup>drain</sup>, 축소<sup>scale down</sup>한 후 최종적으로 AWS에서 완전히 제거할 수 있습니다.

&nbsp;

자세한 사항은 [Release 18+ Upgrade Guide Breaks Existing Deployments #1744](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1744) 이슈에서 확인할 수 있습니다.

&nbsp;

## 업그레이드 절차

이 시나리오에서는 EKS module `v17.24.0`에서 `v18.31.2`로 업그레이드합니다.

모듈 업그레이드 전에 terraform state를 미리 확인합니다.

```bash
terraform state list
```

```bash
data.aws_eks_cluster.cluster
data.aws_eks_cluster_auth.cluster
data.terraform_remote_state.vpc
aws_security_group.sg_eks_internal_lb
aws_security_group.sg_eks_ssh
aws_security_group.sg_eks_worker_from_lb
aws_security_group_rule.sg_eks_internal_lb
aws_security_group_rule.sg_eks_internal_lb_egress
aws_security_group_rule.sg_eks_internal_lb_http
aws_security_group_rule.sg_eks_internal_lb_https
aws_security_group_rule.sg_eks_worker_from_external_lb
aws_security_group_rule.sg_eks_worker_from_internal_lb
aws_security_group_rule.sg_eks_worker_from_internal_lb_egress
aws_security_group_rule.sg_eks_worker_ssh
aws_security_group_rule.sg_eks_worker_ssh_bastion
module.eks.data.aws_ami.eks_worker[0]
module.eks.data.aws_caller_identity.current
module.eks.data.aws_iam_policy_document.cluster_assume_role_policy
module.eks.data.aws_iam_policy_document.workers_assume_role_policy
module.eks.data.aws_partition.current
module.eks.data.http.wait_for_cluster[0]
module.eks.aws_autoscaling_group.workers_launch_template[0]
module.eks.aws_autoscaling_group.workers_launch_template[1]
module.eks.aws_eks_cluster.this[0]
module.eks.aws_iam_instance_profile.workers_launch_template[0]
module.eks.aws_iam_instance_profile.workers_launch_template[1]
module.eks.aws_iam_role.cluster[0]
module.eks.aws_iam_role.workers[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy[0]
module.eks.aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[0]
module.eks.aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[0]
module.eks.aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[0]
module.eks.aws_launch_template.workers_launch_template[0]
module.eks.aws_launch_template.workers_launch_template[1]
module.eks.aws_security_group.cluster[0]
module.eks.aws_security_group.workers[0]
module.eks.aws_security_group_rule.cluster_egress_internet[0]
module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]
module.eks.aws_security_group_rule.workers_egress_internet[0]
module.eks.aws_security_group_rule.workers_ingress_cluster[0]
module.eks.aws_security_group_rule.workers_ingress_cluster_https[0]
module.eks.aws_security_group_rule.workers_ingress_self[0]
module.eks.kubernetes_config_map.aws_auth[0]
module.eks.local_file.kubeconfig[0]
module.eks.module.fargate.data.aws_partition.current
```

&nbsp;

기존 EKS 모듈 v17 기준으로 상태 백업

```bash
terraform state list > eks-v17.list
terraform state pull > eks-v17.tfstate
```

&nbsp;

### 컨트롤플레인

EKS 모듈 버전을 [릴리즈 페이지](https://github.com/terraform-aws-modules/terraform-aws-eks/releases?q=v18.&expanded=true)를 참고해서 `v18.x` 최신으로 업그레이드합니다.

2024년 10월 31일 기준으로 EKS 모듈 `18.31.2`가 `18.x`의 최신버전입니다.

&nbsp;

EKS 모듈 버전을 `v17`에서 `v18`로 업그레이드합니다.

```bash
terraform init -upgrade=true
```

컨트롤플레인 재생성으로 인한 다운타임을 방지하려면 다음 설정을 EKS 모듈에 추가합니다. 이러한 설정은 중단되는 교체(Create)를 방지하기 위해 `v17.x` 값을 전달합니다.

```terraform
# main.tf
locals {
  region          = "ap-northeast-2"
  name            = "my-test-cluster"
  cluster_version = "1.30"
}

#------------------------------------------------------------------------------
# EKS
#------------------------------------------------------------------------------
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  prefix_separator                   = ""
  iam_role_name                      = local.name
  cluster_security_group_name        = local.name
  cluster_security_group_description = "EKS cluster security group."
}
```

EKS 모듈 v17과 v18의 코드 차이점은 매우 큽니다.

[EKS v17 to v18 업그레이드 공식문서](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md#upgrade-migrations)를 참고해서 v18 기준으로 EKS 코드를 재작성합니다.

```terraform
# main.tf
locals {
  region          = "ap-northeast-2"
  name            = "my-test-cluster"
  cluster_version = "1.30"
}

#------------------------------------------------------------------------------
# EKS
#------------------------------------------------------------------------------
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  # Needed for EKS module Upgrade
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md#upgrade-from-v17x-to-v18x
  prefix_separator                   = ""
  iam_role_name                      = local.name
  cluster_security_group_name        = local.name
  cluster_security_group_description = "EKS cluster security group."

  # Rename worker_groups_launch_template -> self_managed_node_groups
  self_managed_node_groups = {
    dummy = {
      name = "${local.name}-dummy"

      min_size      = 1
      max_size      = 5
      desired_size  = 2
      instance_type = "m6i.large"

      launch_template_name            = "${local.name}-dummy-${local.cluster_version}"
      launch_template_use_name_prefix = false

      ami_id = data.aws_ami.eks_default.id

      bootstrap_extra_args = "--kubelet-extra-args '---node-labels=node.kubernetes.io/name=dummy'"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = false
            volume_size           = 70
            volume_type           = "gp3"
          }
        }
      }

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_instance_pools                      = 2
          spot_allocation_strategy                 = "lowest-price"
        }
      }

      termination_policies                   = ["OldestLaunchTemplate", "OldestInstance"]
      update_launch_template_default_version = true

      tags = {
        "k8s.io/cluster-autoscaler/enabled"       = "true"
        "k8s.io/cluster-autoscaler/${local.name}" = "owned"
      }
    }
  }

  cluster_addons = {
    coredns = {
      addon_version               = "v1.11.3-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        replicaCount = 2
        podDisruptionBudget = {
          enabled        = true
          maxUnavailable = 1
        }
      })
    }
    kube-proxy = {
      addon_version               = "v1.30.3-eksbuild.9"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    vpc-cni = {
      addon_version               = "v1.18.5-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        enableNetworkPolicy = "false"
      })
    }
    aws-ebs-csi-driver = {
      addon_version               = "v1.35.0-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      service_account_role_arn    = "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/${module.eks.cluster_name}-EBS-CSI-DriverRole"
    }
  }

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}

#------------------------------------------------------------------------------
# Supporting resources (VPC, AMI, etc.)
#------------------------------------------------------------------------------
data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v20241024"]
  }
}
```

&nbsp;

이 때 `terraform plan`을 실행하면 실패하게 됩니다.

Terraform 상태 이동 명령어인 `terraform state mv`를 사용하여 클러스터 IAM 역할 리소스 이름을 바꿉니다.

```bash
terraform state mv 'module.eks.aws_iam_role.cluster[0]' 'module.eks.aws_iam_role.this[0]'
```

&nbsp;

컨트롤플레인 리소스를 EKS 모듈 v18로 업그레이드합니다.

```bash
terraform apply -target 'module.eks.aws_iam_role.this[0]'
terraform apply -target 'module.eks.aws_eks_cluster.this[0]'
terraform apply -target 'module.eks.aws_eks_cluster.this[0]' -refresh-only
```

&nbsp;

`module.eks.aws_iam_role.cluster[0]`가 `module.eks.aws_iam_role.this[0]`로 변경됩니다.

```bash
$ terraform state list
data.aws_eks_cluster.cluster
data.aws_eks_cluster_auth.cluster
data.terraform_remote_state.vpc
aws_security_group.sg_eks_internal_lb
aws_security_group.sg_eks_ssh
aws_security_group.sg_eks_worker_from_lb
aws_security_group_rule.sg_eks_internal_lb
aws_security_group_rule.sg_eks_internal_lb_egress
aws_security_group_rule.sg_eks_internal_lb_http
aws_security_group_rule.sg_eks_internal_lb_https
aws_security_group_rule.sg_eks_worker_from_external_lb
aws_security_group_rule.sg_eks_worker_from_internal_lb
aws_security_group_rule.sg_eks_worker_from_internal_lb_egress
aws_security_group_rule.sg_eks_worker_ssh
aws_security_group_rule.sg_eks_worker_ssh_bastion
module.eks.data.aws_ami.eks_worker[0]
module.eks.data.aws_caller_identity.current
module.eks.data.aws_iam_policy_document.assume_role_policy[0]
module.eks.data.aws_iam_policy_document.cluster_assume_role_policy
module.eks.data.aws_iam_policy_document.workers_assume_role_policy
module.eks.data.aws_partition.current
module.eks.data.http.wait_for_cluster[0]
module.eks.aws_autoscaling_group.workers_launch_template[0]
module.eks.aws_autoscaling_group.workers_launch_template[1]
module.eks.aws_eks_cluster.this[0]
module.eks.aws_iam_instance_profile.workers_launch_template[0]
module.eks.aws_iam_instance_profile.workers_launch_template[1]
module.eks.aws_iam_role.this[0]
module.eks.aws_iam_role.workers[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy[0]
module.eks.aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[0]
module.eks.aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[0]
module.eks.aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[0]
module.eks.aws_launch_template.workers_launch_template[0]
module.eks.aws_launch_template.workers_launch_template[1]
module.eks.aws_security_group.cluster[0]
module.eks.aws_security_group.workers[0]
module.eks.aws_security_group_rule.cluster_egress_internet[0]
module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]
module.eks.aws_security_group_rule.workers_egress_internet[0]
module.eks.aws_security_group_rule.workers_ingress_cluster[0]
module.eks.aws_security_group_rule.workers_ingress_cluster_https[0]
module.eks.aws_security_group_rule.workers_ingress_self[0]
module.eks.kubernetes_config_map.aws_auth[0]
module.eks.local_file.kubeconfig[0]
module.eks.module.fargate.data.aws_partition.current
module.eks.module.kms.data.aws_caller_identity.current
module.eks.module.kms.data.aws_partition.current
```

아래 부수 작업들을 수행합니다.

- `aws_auth` configMap을 삭제합니다.
- 기존 EKS v17에서 EKS Addon이 존재하는 경우, terraform state를 삭제합니다. 그리고 바뀐 EKS addon의 상태 주소로 새롭게 추가합니다.
- EKS 모듈 v18부터 새롭게 지원되는 OIDC Provider 리소스를 `terraform import`해서 컨트롤플레인에 추가합니다.

```bash
# [1] Remove aws-auth configMap
## If you are managing the aws-auth configmap using EKS module
## Then remove aws-auth configmap from tf state as now the module dropped the support
terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]'

# [2] If you use addons then remove from state as well
terraform state rm 'aws_eks_addon.kube_proxy' 'aws_eks_addon.vpc_cni' 'aws_eks_addon.coredns' 'aws_eks_addon.aws_ebs_csi_driver'

# [3] Import addons
terraform import 'module.eks.aws_eks_addon.this["kube-proxy"]' <CLUSTER_NAME>:kube-proxy
terraform import 'module.eks.aws_eks_addon.this["vpc-cni"]' <CLUSTER_NAME>:vpc-cni
terraform import 'module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]' <CLUSTER_NAME>:aws-ebs-csi-driver
terraform import 'module.eks.aws_eks_addon.this["coredns"]' <CLUSTER_NAME>:coredns

# [4] Import OIDC Provider
## Starting from EKS module v18, OIDC Provider is supported.
terraform import 'module.eks.aws_iam_openid_connect_provider.oidc_provider[0]' 'arn:aws:iam::<YOUR_ACCOUNT_ID>:oidc-provider/oidc.eks.<REGION>.amazonaws.com/id/<ODIC_ID>'
```

&nbsp;

### 데이터 플레인

현재 다운타임을 초래하지 않는 데이터 플레인을 제자리에서 업그레이드하는 방법은 없습니다. 따라서 여기에 설명된 단계는 데이터 플레인을 업그레이드하는 데 블루/그린 접근 방식을 따라 가동 중지를 방지하도록 설계되었습니다.

`terraform state` 명령어로 워커노드 관련 리소스 상태 구조를 조회합니다.

```bash
terraform state list
```

앞에 `[x]` 표시된 워커노드 관련 리소스들을 이제 삭제할 예정입니다.

```bash
data.aws_ami.eks_default
data.aws_eks_cluster.cluster
data.aws_eks_cluster_auth.cluster
data.terraform_remote_state.vpc
aws_security_group.sg_eks_internal_lb
aws_security_group.sg_eks_ssh
aws_security_group.sg_eks_worker_from_lb
aws_security_group_rule.sg_eks_internal_lb
aws_security_group_rule.sg_eks_internal_lb_egress
aws_security_group_rule.sg_eks_internal_lb_http
aws_security_group_rule.sg_eks_internal_lb_https
aws_security_group_rule.sg_eks_worker_from_external_lb
aws_security_group_rule.sg_eks_worker_from_internal_lb
aws_security_group_rule.sg_eks_worker_from_internal_lb_egress
aws_security_group_rule.sg_eks_worker_ssh
aws_security_group_rule.sg_eks_worker_ssh_bastion
module.eks.data.aws_ami.eks_worker[0]
module.eks.data.aws_caller_identity.current
module.eks.data.aws_default_tags.current
module.eks.data.aws_iam_policy_document.assume_role_policy[0]
module.eks.data.aws_iam_policy_document.cluster_assume_role_policy
module.eks.data.aws_iam_policy_document.workers_assume_role_policy
module.eks.data.aws_partition.current
module.eks.data.http.wait_for_cluster[0]
module.eks.data.tls_certificate.this[0]
[x] module.eks.aws_autoscaling_group.workers_launch_template[0]
[x] module.eks.aws_autoscaling_group.workers_launch_template[1]
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]
module.eks.aws_eks_addon.this["coredns"]
module.eks.aws_eks_addon.this["kube-proxy"]
module.eks.aws_eks_addon.this["vpc-cni"]
module.eks.aws_eks_cluster.this[0]
[x] module.eks.aws_iam_instance_profile.workers_launch_template[0]
[x] module.eks.aws_iam_instance_profile.workers_launch_template[1]
module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
module.eks.aws_iam_role.this[0]
[x] module.eks.aws_iam_role.workers[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy[0]
module.eks.aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy[0]
[x] module.eks.aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[0]
[x] module.eks.aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[0]
[x] module.eks.aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[0]
[x] module.eks.aws_launch_template.workers_launch_template[0]
[x] module.eks.aws_launch_template.workers_launch_template[1]
module.eks.aws_security_group.cluster[0]
[x] module.eks.aws_security_group.workers[0]
[x] module.eks.aws_security_group_rule.cluster_egress_internet[0]
[x] module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]
[x] module.eks.aws_security_group_rule.workers_egress_internet[0]
[x] module.eks.aws_security_group_rule.workers_ingress_cluster[0]
[x] module.eks.aws_security_group_rule.workers_ingress_cluster_https[0]
[x] module.eks.aws_security_group_rule.workers_ingress_self[0]
module.eks.local_file.kubeconfig[0]
module.eks.module.fargate.data.aws_partition.current
module.eks.module.kms.data.aws_caller_identity.current
module.eks.module.kms.data.aws_partition.current
```

&nbsp;

**Workers**:

> ⚠️ **중요**: 다음 명령은 Terraform 제어 영역에서 공유된 "workers" IAM Role과 워커노드용 보안 그룹을 제거합니다. 사용자는 마이그레이션이 완료된 후(더 이상 데이터 플레인 리소스에서 사용되지 않을 때) 이러한 리소스를 수동으로 정리해야 합니다.

```bash
# Remove IAM Role for worker nodes
terraform state rm 'module.eks.aws_iam_role.workers[0]'
terraform state rm 'module.eks.aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[0]'
terraform state rm 'module.eks.aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[0]'
terraform state rm 'module.eks.aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[0]'

# Remove SG for worker nodes
terraform state rm 'module.eks.aws_security_group.workers[0]'
terraform state rm 'module.eks.aws_security_group_rule.workers_ingress_self[0]'
terraform state rm 'module.eks.aws_security_group_rule.workers_ingress_cluster_https[0]'
terraform state rm 'module.eks.aws_security_group_rule.workers_ingress_cluster[0]'
terraform state rm 'module.eks.aws_security_group_rule.workers_egress_internet[0]'
terraform state rm 'module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]'
terraform state rm 'module.eks.aws_security_group_rule.cluster_egress_internet[0]'
```

&nbsp;

**Self Managed Node Group**:

Self Managed Node Group을 구성하는 Auto Scaling Group, Launch Template, Instance Profile의 state를 테라폼 제어영역에서 삭제합니다.

```bash
# Remove first nodegroup resources
terraform state rm 'module.eks.aws_launch_template.workers_launch_template[0]'
terraform state rm 'module.eks.aws_autoscaling_group.workers_launch_template[0]'
terraform state rm 'module.eks.aws_iam_instance_profile.workers_launch_template[0]'

# Remove second nodegroup resources
terraform state rm 'module.eks.aws_launch_template.workers_launch_template[1]'
terraform state rm 'module.eks.aws_autoscaling_group.workers_launch_template[1]'
terraform state rm 'module.eks.aws_iam_instance_profile.workers_launch_template[1]'

# ... Repeat for all nodegroup resources ...
```

&nbsp;

### plan, apply

코드를 변경하고, 데이터플레인 상태를 제거했다면 이제 새 노드그룹을 배포해보도록 합니다.

기존 노드그룹에 대한 리소스(ASG, Launch Template, IAM Role, Worker Node SG)들은 테라폼 영역에서 이미 제거되었으므로 반드시 유지되어야 합니다.

```bash
terraform plan
```

`plan` 결과는 다음과 같아야 합니다.

- 클러스터(컨트롤플레인)를 교체하려고 하면 **안됨**
- 이전 노드 그룹(ASG, Launch Template)은 파괴되면 **안됨**
- 노드 그룹 관련 리소스(sg, sg 규칙, 이전 노드 iam)를 파괴하면 **안됨**
- 일부 클러스터 정책이 변경됨
- 새로운 노드 그룹을 추가하려고 함
- 새로운 노드 그룹 관련 리소스를 추가하려고 함

위 6개 조건이 충족된 경우, `terraform apply`를 실행합니다.

&nbsp;

### 리소스 삭제

이제 오래된 노드 그룹을 수동으로 삭제할 수 있으며, 그러면 Pod가 새로운 노드 그룹에서 다시 시작됩니다.

이전 노드 그룹에 대한 보안 그룹, ASG, Launch Template, IAM Role은 남아있게 되므로 직접 삭제해야 합니다.

&nbsp;

## 결론

EKS 모듈을 v17에서 v18로 업그레이드하면서 컨트롤 플레인은 안전하게 유지되고, 데이터 플레인은 블루/그린 방식으로 무중단 전환됩니다. 파드는 기존 노드 그룹에 있으므로 새 노드 그룹으로의 전환은 직접 수행해야 합니다. 기존 데이터 플레인은 Terraform 제어에서 제외되며, v18로 구성된 새 데이터 플레인이 프로비저닝됩니다. 이후 사용자는 기존 데이터 플레인 노드 그룹, EC2 인스턴스, Auto Scaling 그룹, IAM 역할 및 정책, VPC 보안 그룹 규칙 등을 직접 삭제하여 마이그레이션을 완료합니다.

| 항목 | 내용 |
|-----|-----|
| 업그레이드 방식 | 블루/그린으로 무중단 전환 |
| 기존 데이터 플레인 | Terraform 제어에서 제외 |
| 새 데이터 플레인 | v18로 프로비저닝 |
| 사용자 작업 | 기존 데이터 플레인 리소스 직접 삭제 |
| 컨트롤 플레인 | EKS v17에서 v18로 안전하게 유지 |

&nbsp;

## 관련자료

- [eks-v17-v18-migrate](https://github.com/clowdhaus/eks-v17-v18-migrate): Github
- [Terraform EKS module upgrade from v17.x to v18.x](https://billhegazy.com/eks-terraform-module-upgrade-from-v17-to-v18/): Blog
- [Release 18+ Upgrade Guide Breaks Existing Deployments #1744](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1744): Github Issue
