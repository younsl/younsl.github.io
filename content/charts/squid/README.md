# Squid Helm Chart

A Helm chart for running [Squid](http://www.squid-cache.org/) proxy server on Kubernetes.

## Background

## What is Squid?

Squid is a web proxy that caches HTTP, HTTPS, and FTP requests. It helps speed up web browsing and reduce bandwidth usage.

## Requirements

- Kubernetes 1.21+
- Helm 3.2.0+

## Installation

### Helm Chart

First of all, add the helm repository:

```bash
helm repo add younsl https://younsl.github.io/charts
helm repo update
```

Search squid chart in helm repository:

```bash
helm search repo younsl/squid
```

Customize your values.yaml and install the chart with your values file:

Strongly recommend to install squid helm chart with dedicated namespace(e.g. `squid`) for security reasons.

```bash
# Install with dedicated namespace
helm install squid younsl/squid \
  --namespace squid \
  --create-namespace

# Install with custom values file
helm install squid younsl/squid \
  --namespace squid \
  --create-namespace \
  --values your-values.yaml
```

## Configuration

### Basic Settings

Avilable all parameters in [values.yaml](values.yaml).

| Parameter | Description | Default |
|-----------|-------------|---------|
| **General** | | |
| `replicaCount` | Number of pods | `2` |
| `revisionHistoryLimit` | Number of old deployments to keep | `10` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full name | `""` |
| `commonLabels` | Common labels for all resources | `{}` |
| `commonAnnotations` | Common annotations for all resources | `{description: "Squid is a HTTP/HTTPS proxy server supporting caching and domain whitelist access control."}` |
| **Image** | | |
| `image.repository` | Squid image repository | `ubuntu/squid` |
| `image.tag` | Image tag | `6.10-24.10_beta` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| **Service** | | |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3128` |
| `service.targetPort` | Container port | `3128` |
| `service.nodePort` | NodePort (if type is NodePort) | `""` |
| `service.externalTrafficPolicy` | External traffic policy | `""` |
| `service.loadBalancerIP` | Load balancer IP | `""` |
| `service.loadBalancerSourceRanges` | Load balancer source ranges | `[]` |
| **Resources** | | |
| `resources.limits.memory` | Memory limit | `256Mi` |
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| **Security** | | |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.automountServiceAccountToken` | Whether to auto-mount service account token to pod | `false` |
| `podSecurityContext.fsGroup` | File system group (pre-defined group in squid container image) | `13` |
| `securityContext.runAsUser` | Run as user ID (pre-defined user in squid container image) | `13` |
| `securityContext.runAsGroup` | Run as group ID (pre-defined group in squid container image) | `13` |
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `false` |
| **Pod Lifecycle** | | |
| `terminationGracePeriodSeconds` | Pod termination grace period | `60` |
| `squidShutdownTimeout` | Squid shutdown timeout | `30` |
| **DNS** | | |
| `dnsPolicy` | DNS policy | `ClusterFirst` |
| `dnsConfig` | DNS configuration | `{}` |
| **High Availability** | | |
| `podDisruptionBudget.enabled` | Enable PDB | `true` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |
| `topologySpreadConstraints` | Pod distribution rules | `[]` |
| **Auto Scaling** | | |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `2` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `70` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization | `80` |
| `autoscaling.behavior.scaleDown.stabilizationWindowSeconds` | Scale down stabilization period | `600` |
| **Storage** | | |
| `persistence.enabled` | Enable persistent storage | `false` |
| `persistence.size` | Storage size | `1Gi` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.storageClassName` | Storage class name | `""` |
| **Network** | | |
| `config.allowedNetworks.extra` | Additional allowed networks | `[]` |
| **Ingress** | | |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts | `[{host: "squid.local", paths: [{path: "/", pathType: "Prefix"}]}]` |
| **[Squid Exporter (Prometheus Metrics)](https://github.com/boynux/squid-exporter)** [^1] | | |
| `squidExporter.enabled` | Enable squid-exporter sidecar container to collect metrics from squid | `true` |
| `squidExporter.image.repository` | Squid exporter image | `boynux/squid-exporter` |
| `squidExporter.image.tag` | Squid exporter image tag | `v1.13.0` |
| `squidExporter.port` | Metrics port | `9301` |
| `squidExporter.metricsPath` | Metrics endpoint path | `/metrics` |
| `squidExporter.squidHostname` | Squid hostname for exporter | `localhost` |
| `squidExporter.squidPort` | Squid port for exporter | `~` (uses service.targetPort) |
| `squidExporter.extractServiceTimes` | Extract service times | `true` |
| `squidExporter.customLabels` | Custom labels for metrics | `{}` |
| `squidExporter.resources.limits.memory` | Exporter memory limit | `64Mi` |
| `squidExporter.resources.requests.cpu` | Exporter CPU request | `10m` |
| `squidExporter.resources.requests.memory` | Exporter memory request | `32Mi` |
| **Grafana Dashboard** | | |
| `dashboard.enabled` | Whether to create squid grafana dashboard provided by squid-exporter | `false` |
| `dashboard.grafanaNamespace` | Namespace where grafana is installed | `""` |
| `dashboard.annotations` | A resource-specific annotations for ConfigMap | `{}` |

[^1]: Squid Exporter is a Prometheus exporter sidecar for Squid proxy server. It collects metrics from Squid and exports them to Prometheus.

### Squid Configuration

#### Network Access

Add allowed networks:

```yaml
config:
  allowedNetworks:
    extra:
      - name: "office"
        cidr: "10.1.0.0/24"
        description: "office network"
```

#### Domain Filtering

Enable domain whitelist in `values.yaml`:

```yaml
config:
  squid.conf: |
    # Uncomment these lines:
    acl allowed_domains dstdomain .example.com
    acl allowed_domains dstdomain .google.com
    
    # Change access rule from:
    # http_access allow allowed_nets
    # To:
    http_access allow allowed_nets allowed_domains
```

## Usage

### Test Connection

```bash
# Port forward to local machine
kubectl port-forward svc/my-squid 3128:3128

# Test proxy connection
export http_proxy=http://localhost:3128
curl -v https://www.google.com
```

This creates a tunnel from your local machine to the Squid proxy running in Kubernetes. The `curl` command will route through the proxy. You should see proxy-related headers in the output if it's working correctly.

Expected output:

- Connection to proxy established
- HTTP headers showing the request went through Squid
- Successful response from the target website

### Use in Applications

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-app
spec:
  containers:
  - name: app
    image: curlimages/curl
    env:
    - name: http_proxy
      value: "http://squid.squid.svc.cluster.local:3128"
    - name: https_proxy
      value: "http://squid.squid.svc.cluster.local:3128"
```

## Monitoring

Check logs:

```bash
kubectl logs deployment/squid --namespace squid
```

Check squid configuration file:

```bash
kubectl exec deployment/squid --namespace squid -- cat /etc/squid/squid.conf
```

## Upgrade

```bash
helm upgrade squid younsl/squid \
  --install \
  --namespace squid \
  --values your-modified-values.yaml
```

## Uninstall

Uninstall helm chart:

```bash
helm uninstall squid --namespace squid
```

Delete dedicated namespace:

```bash
kubectl get namespace squid
kubectl delete namespace squid
```

## License

MIT License