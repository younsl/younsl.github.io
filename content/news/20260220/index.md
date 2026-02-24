---
title: "2026-02-20"
date: 2026-02-20T00:00:00+09:00
tags: ["news"]
---

Weekly roundup of SRE, Cloud Native, and Infrastructure news.

<!-- more -->

## TeamPCP worm compromises 60,000+ cloud servers via Docker and Kubernetes

A worm-driven campaign by [TeamPCP](https://thehackernews.com/2026/02/teampcp-worm-exploits-cloud.html) has compromised at least 60,000 servers worldwide since late December 2025. The campaign exploits exposed Docker APIs, Kubernetes clusters, Ray dashboards, and Redis servers, combined with CVE-2025-55182 (React2Shell, CVSS 10.0). Kubernetes-specific payloads harvest cluster credentials, discover pods/namespaces via API, and deploy privileged pods that mount the host filesystem. Azure (61%) and AWS (36%) account for 97% of compromised servers.

## Kubernetes nodes/proxy GET enables full cluster takeover via monitoring tools

A high-impact Kubernetes security issue was [publicly disclosed](https://edera.dev/stories/your-monitoring-stack-just-became-a-rce-vector-a-deep-dive-into-the-kubernetes-nodes-proxy-rce): the `nodes/proxy` GET permission, commonly granted to monitoring tools, enables remote code execution on any pod in any namespace with no audit trail. An attacker with this permission and Kubelet port 10250 access can execute arbitrary commands on privileged system pods. Kubernetes Security Team classified this as "working as intended" (no CVE issued). The mitigation path is [KEP-2862](https://github.com/kubernetes/enhancements/issues/2862) (Fine-Grained Kubelet API Authorization), currently in Beta, expected to GA in Kubernetes 1.36.

## Docker Hardened Images now free under Apache 2.0

[Docker](https://www.docker.com/blog/docker-hardened-images-for-every-developer/) made its catalog of Docker Hardened Images (DHI) free and fully open source under the Apache 2.0 license. These images reduce vulnerabilities by up to 95% compared to traditional community images using a distroless runtime. Every image includes complete SBOM, SLSA Build Level 3 provenance, and cryptographic proof of authenticity.

## Kyverno 1.17 stabilizes CEL policy engine to v1

[Kyverno 1.17](https://www.cncf.io/blog/2026/02/18/announcing-kyverno-1-17/) stabilized the next-generation [Common Expression Language (CEL)](https://kubernetes.io/docs/reference/using-api/cel/) policy engine to v1 (production-ready). The release introduces namespaced mutation and generation for CEL policies, expands function libraries, and enhances supply chain security with upcoming Cosign v3 support. ClusterPolicy and CleanupPolicy are officially deprecated in favor of CEL-based engines.

## Datadog integrates Google ADK into LLM Observability

[Datadog's LLM Observability](https://www.infoq.com/news/2026/02/datadog-google-llm-observability/) now provides automatic instrumentation for applications built with Google's Agent Development Kit (ADK). The integration enables teams to visualize agent decision paths, trace tool calls, measure token usage and latency per workflow branch, and identify unexpected loops or misrouted steps — all without code changes.

## Grafana Loki Helm chart migrates to community repository on March 16

Effective March 16, 2026, the [Grafana Loki Helm chart](https://grafana.com/docs/loki/latest/release-notes/v3-6/) will be forked from the Loki monorepo to the new [grafana-community/helm-charts](https://github.com/grafana-community/helm-charts) repository. The chart in the Loki repository will continue to be maintained for GEL (Grafana Enterprise Logs) users only. Loki 3.6 also deprecates Simple Scalable Deployment (SSD) mode before Loki 4.0, and moves the built-in UI to a separate [Grafana plugin](https://github.com/grafana/loki-operational-ui). Additionally, four legacy Helm charts — `lgtm-distributed`, `loki-canary`, `loki-distributed`, and `loki-simple-scalable` — are now deprecated.

## OpenTelemetry Collector Docker images move from DockerHub to GHCR

The OpenTelemetry project has [migrated its Collector Docker images](https://github.com/open-telemetry/opentelemetry-collector-releases) from DockerHub to GitHub Container Registry (GHCR). The previous image paths `otel/opentelemetry-collector` and `otel/opentelemetry-collector-contrib` are replaced by `ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector` and the corresponding `-contrib` variant. Some versions may still be published to both registries, but relying on DockerHub will eventually break. Users must update image references in Kubernetes manifests, Helm values, and Docker Compose files.

## OpenTelemetry Collector batch processor headed for deprecation

The OpenTelemetry Collector's [batch processor is being deprecated](https://www.dash0.com/blog/why-the-opentelemetry-batch-processor-is-going-away-eventually) in favor of exporter-level batching backed by persistent storage. The core issue is that the batch processor buffers telemetry in memory and operates on an at-most-once delivery model — crash testing showed 100% data loss of queued telemetry after Collector restart, while applications still received success confirmations for data that never reached the backend. The replacement approach integrates batching directly into exporters with disk-based queuing, providing at-least-once delivery guarantees and better backpressure propagation from downstream saturation.

## containerd 1.7 end of active support in March 2026

[containerd 1.7](https://containerd.io/releases/) exits active community support on March 10, 2026 (extended support by individual maintainers through September 2026). Kubernetes 1.35 is the last release supporting containerd 1.x — any Kubernetes version after 1.35 will require containerd 2.x. Schema 1 images and CRI v1alpha2, deprecated in 1.7, are removed in 2.0. Users should check for deprecation warnings in 1.7 logs and upgrade to containerd 2.1+ before moving beyond Kubernetes 1.35.

## Grafana Promtail reaches end of life on February 28, 2026

[Grafana Promtail](https://community.grafana.com/t/promtail-end-of-life-eol-march-2026-how-to-migrate-to-grafana-alloy-for-existing-loki-server-deployments/159636), the default log collection agent for Grafana Loki, reaches end of life on February 28, 2026 and will stop receiving any updates including security fixes. This follows Grafana Agent itself reaching EOL on November 1, 2025. Users must migrate to [Grafana Alloy](https://grafana.com/docs/loki/latest/setup/migrate/migrate-to-alloy/), the next-generation collector built on OpenTelemetry Collector, which supports metrics, logs, traces, and profiles with native OTLP compatibility.
