---
title: "About"
date: 2022-08-31T15:38:15+09:00
lastmod: 2024-12-01T17:32:33+09:00
slug: ""
description: "About"
keywords: []
tags: ["bio", "profile"]
showAdvertisement: false
---

### Younsung Lee

DevOps Engineer. I work in cloud-based distributed systems like kubernetes. I also have a general interest in cloud native technologies including Kubernetes, Observability, and Infrastructure Ops.

[Github](https://github.com/younsl), [Slides](https://github.com/younsl/box/tree/main/box/slides)

&nbsp;

### Work Experience

**DevOps Engineer** @ [Coinone](https://coinone.co.kr)  
May 30, 2023 ― Present <small>(1 yr 10 mo)</small>

AWS, GCP, Kubernetes, Observability, CI/CD, Terraform, Infrastructure Ops

- Managed and operated 6 EKS clusters across multiple stages, performing in-place upgrades from EKS versions v1.24 to v1.32.
- Migrated EKS node groups provisioned with Terraform from Amazon Linux 2 (AL2) to Amazon Linux 2023 (AL2023).
- Operated the kubernetes policy engine, Kyverno, and the Node Termination Handler. _[*](/blog/k8s/kyverno/) [**](/blog/k8s/nth/)_
- Enhanced scalability by implementing pod autoscaling based on Throughput Per Second metrics using KEDA in production. _[*](/blog/k8s/keda/)_
- Automated repetitive operational tasks using Golang and Bash scripts.
- Managed CI/CD pipelines utilizing GitHub Actions Workflow and ArgoCD.
- Built and operated RabbitMQ, MSK Cluster, and OpenSearch Cluster. _[*](/blog/kafka/) [**](/blog/elasticsearch-admin-guide/)_
- Developed and maintained GitHub Enterprise Server, backup utilities, and Actions Runner Controller. _[*](/blog/ghe-backup-utils/) [**](/blog/k8s/actions-runner-admin-guide/)_
- Containerized GitHub Enterprise Backup Utilities (backup-utils) and migrated workloads from EC2 to Kubernetes CronJobs for optimized resource usage.
- Developed and released the GitHub Enterprise Backup Utilities Helm chart as a maintainer. _[*](https://younsl.github.io/charts/)_
- Designed and implemented modular Terraform infrastructure for core cluster resources (EKS, MSK, RabbitMQ, OpenSearch) across 4+ AWS accounts, reducing provisioning time by 50%.
- Implemented secure cross-cloud authentication between AWS EKS and GCP using Workload Identity Federation (WIF), eliminating the security risks of managing GCP service account keys while enabling EKS pods to securely access GCP APIs.
- Implemented and managed a Velero server in a production EKS cluster, orchestrating scheduled backups and conducting recovery tests. _[*](/blog/k8s/velero-irsa/)_
- Automated daily resource creation using GitHub Actions for Terraform apply, enhancing workflows with Atlantis for collaboration. _[*](/blog/k8s/atlantis/)_
- Deployed and managed Linkerd, a service mesh, to improve cluster security with mTLS and enhance observability between microservices.

&nbsp;

**DevOps Engineer** @ [Greenlabs Financial](https://seedglobal.co)  
Sep 5, 2022 ― Apr 7, 2023 <small>(7 mos)</small>

AWS, Kubernetes, Istio, Observability, CI/CD, Terraform, MLOps, Infrastructure Ops

- Acquired electronic finance business license #2022-483 after building multi-account AWS infrastructure for 3 months from September to December 2022. _[*](https://www.fsc.go.kr/po040200/79214?srchCtgry=&curPage=&srchKey=&srchText=&srchBeginDt=&srchEndDt)_
- Managed and operated 2 EKS clusters in a multi-stage environment: experienced EKS versions v1.24 to v1.25. _[*](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar)_
- Provisioned and operated multi-stage AWS infrastructure using terraform.
- Optimized multi-account infrastructure and reduced monthly AWS cost from $6800 to $4800, 30% monthly cost savings from Jan 2023 to Mar 2023.

&nbsp;

**Cloud Engineer** @ [Watcha](https://watcha.team)  
Feb 14, 2022 ― Aug 5, 2022 <small>(6 mos)</small>

AWS, Kubernetes, CI/CD, Terraform, Infrastructure Ops

&nbsp;

**System Engineer** @ [KDN](https://kdn.com)  
Dec 16, 2013 ― Feb 11, 2022 <small>(8 yrs 2 mos)</small>

On-premise, Linux administration, VMware Cluster administration, Storage administration, Backup and Recovery, Monitoring, Infrastructure Ops

- Orchestrated the uninterrupted operation of VMware cluster environments, guaranteeing stability and high availability.
- Automated routine operational tasks using python and bash script.
- Collaborated closely with the development team to understand their virtual machine provisioning needs.
- Provided technical support for virtualization-related incidents and challenges, consistently ensuring prompt issue resolution.
- Collaborated with vendors to address hardware and software issues, resulting in minimal disruptions to operations.
- Installed and configured backup agents for VMs, executing OS and database-level backup and recovery procedures using EMC Networker.
- Out of job due to military service, ROKAF from Nov 2014 to Nov 2016.

&nbsp;

### Education

**BSE, ICT Applied** @ Chosun University  
Mar 2018 ― Feb 2022

<!-- GPA: 4.09 / 4.5 -->

&nbsp;

### Certification

- Linux Foundation Certified IT Associate: 2024.11.29 - 2026.11.29
- Kubernetes and Cloud Native Associate: 2024.11.29 - 2026.11.29
- AWS Certified Solutions Architect - Professional: 2023.05.21 - 2026.05.21
- AWS Certified Developer - Associate: 2023.05.18 - 2026.05.18
- AWS Certified SysOps Administrator - Associate: 2023.05.13 - 2026.05.13
- AWS Certified Cloud Practitioner: 2023.05.04 - 2026.05.04
- Certified Kubernetes Administrator: 2022.09.13 ― 2025.09.13
- AWS Certified Solutions Architect - Associate: 2020.06.26 - 2026.05.21
