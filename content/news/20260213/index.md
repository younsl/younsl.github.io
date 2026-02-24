---
title: "2026-02-13"
date: 2026-02-13T00:00:00+09:00
lastmod: 2026-02-16T13:00:04+09:00
tags: ["news"]
---

Weekly roundup of SRE, Cloud Native, and Infrastructure news.

<!-- more -->

## Agentic workloads are coming to EKS in 2026

According to [The New Stack](https://thenewstack.io/2026-will-be-the-year-of-agentic-workloads-in-production-on-amazon-eks/), production deployments of agentic AI workloads on EKS are ramping up in 2026, shifting from experimental LLM inferencing to production-grade agent architectures.

## OpenTofu v1.11.5 released

[OpenTofu v1.11.5](https://github.com/opentofu/opentofu/releases) dropped on February 12 with GCS backend `universe_domain` support for sovereign GCP services and security fixes for GO-2026-4341/4340.

## Terraform v1.14.5 stable

[HashiCorp Terraform v1.14.5](https://github.com/hashicorp/terraform/releases) was published on February 11. The 1.15.0 alpha is also available with upcoming features in development.

## Grafana launches free LGTM tier

[Grafana Labs](https://grafana.com/blog/2026-observability-trends-predictions-from-grafana-labs-unified-intelligent-and-open/) introduced a free tier with 10k Prometheus metrics, 50GB logs, 50GB traces, and 500VUh synthetic testing. Grafana Alloy, a unified telemetry pipeline supporting Prometheus, OTel, Loki, and Pyroscope, is also now available.

Grafana also argues that observability is breaking free from the engineering silo — 73% of executives have adopted or are transitioning to unified observability, yet only 14% call their tool consolidation "very successful." The focus is shifting from collecting more data to keeping smarter data, with Adaptive Telemetry filtering 50-80% of low-value signals while retaining what matters.

## The SRE Report 2026: slow is the new down

[LogicMonitor's SRE Report 2026](https://www.logicmonitor.com/press/the-sre-report-2026-reliability-is-being-redefined) surveyed 400+ SRE professionals and found that nearly two-thirds say performance degradations are as serious as outages. Median toil remains at 34% of engineers' time. Only 17% run chaos experiments regularly in production.

## Kubernetes v1.35 introduces in-place Pod restart

[Kubernetes v1.35 "Timbernetes"](https://kubernetes.io/blog/2026/01/02/kubernetes-v1-35-restart-all-containers/) shipped a new alpha feature enabling full in-place restart of all containers in a Pod without rescheduling. This is particularly useful for AI/ML workloads where failure recovery can be offloaded to sidecars and declarative Kubernetes configuration.

## Kubernetes v1.36 enhancements freeze

[Kubernetes v1.36](https://www.kubernetes.dev/resources/release/) hit its enhancements freeze on February 11. The release is targeting April 22 and will remove IPVS mode from kube-proxy, which was deprecated in v1.35.

## KubeCon EU 2026 in Amsterdam

[KubeCon + CloudNativeCon Europe 2026](https://www.cncf.io/) is scheduled for March 23-26 in Amsterdam.
