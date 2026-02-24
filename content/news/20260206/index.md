---
title: "2026-02-06"
date: 2026-02-06T00:00:00+09:00
tags: ["news"]
---

Weekly roundup of SRE, Cloud Native, and Infrastructure news.

<!-- more -->

## Grafana Labs caps a breakout year with $400M+ ARR

[Grafana Labs announced](https://grafana.com/about/press/2026/02/03/grafana-labs-caps-a-breakout-year-of-growth-and-product-innovation/) on February 3 that its annual recurring revenue has surpassed $400M, now supporting 7,000+ organizations including 70% of the Fortune 50. Ted Young, OpenTelemetry co-founder, joined Grafana Labs, and the company donated Beyla, its eBPF-based auto-instrumentation project, to the OpenTelemetry community. GrafanaCON 2026 is scheduled for April 20-22 in Barcelona.

## CNCF survey: Kubernetes hits 82% production adoption

The [2025 CNCF Annual Cloud Native Survey](https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/) published on January 20 shows 82% of container users now run Kubernetes in production. 68% of respondents deploy AI workloads on Kubernetes, up from 52% the previous year. Notably, the top challenge has shifted from technical to organizational — "cultural changes with the development team" is now the #1 barrier, cited by 47%.

## GenAI reshapes observability: 85% adoption, but efficiency gains lag

[Elastic's 2026 observability trends report](https://www.elastic.co/blog/2026-observability-trends-generative-ai-opentelemetry) published on February 4 reveals 85% of organizations now use GenAI for observability, projected to reach 98% within two years. Top use cases include automated correlation of telemetry signals (58%), root cause analysis (49%), and remediation automation (48%). However, only 14% report substantial efficiency gains so far. OpenTelemetry production adoption nearly doubled year-over-year from 6% to 11%, with 89% of production users considering vendor compliance critical.

## Reclaiming underutilized GPUs with Kubernetes scheduler plugins

CNCF published a [blog post on reclaiming underutilized GPUs](https://www.cncf.io/blog/2026/01/20/reclaiming-underutilized-gpus-in-kubernetes-using-scheduler-plugins/) using custom Kubernetes scheduler plugins. The ReclaimIdleResource plugin queries Prometheus for GPU utilization metrics from DCGM and preempts pods only when actual usage falls below a configured threshold. A related [DaoCloud case study](https://www.cncf.io/case-studies/daocloud/) demonstrated 3x improvement in GPU utilization using HAMi across 10,000+ GPU cards.

## Ingress NGINX Controller retires in March 2026

[Kubernetes SIG Network announced](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/) that the Ingress NGINX Controller will be officially retired in March 2026. After retirement, no security patches, CVE fixes, or new releases will be provided. Compatibility with Kubernetes 1.35+ is expected to break. SIG Network recommends all users begin [migrating to Gateway API](https://gateway-api.sigs.k8s.io/) immediately, the modern persona-driven replacement for the legacy Ingress resource.

## Kubernetes Node Readiness Controller: declarative node scheduling gates

SIG Node introduced the [Node Readiness Controller](https://kubernetes.io/blog/2026/02/03/introducing-node-readiness-controller/), a new project that provides declarative scheduling gates for Kubernetes nodes via a custom resource called [`NodeReadinessRule`](https://github.com/kubernetes/enhancements/pull/5416). The controller addresses limitations of the standard node Ready condition by allowing operators to define complex infrastructure dependencies — such as CNI plugin health, GPU driver availability, or DaemonSet readiness — before a node accepts workloads. Key features include continuous and bootstrap-only enforcement modes, dry-run simulation for safe fleet-wide rollout, and integration with Node Problem Detector for condition reporting. Currently at alpha v0.1.1.

## Prometheus v3.9: Native Histograms are now stable

[Prometheus v3.9.0](https://github.com/prometheus/prometheus/releases/tag/v3.9.0) released on January 6 removes the experimental native-histogram feature flag entirely. Native Histograms are now a stable feature controlled via scrape_native_histograms config setting. Compared to classic histograms, native histograms offer [higher resolution with 30%+ storage efficiency](https://prometheus.io/docs/specs/native_histograms/), atomic composite sample storage, and compatibility with OpenTelemetry exponential histograms. Starting from v4.0, scrape_native_histograms and send_native_histograms will both default to true.
