# Overprovisioning

Overprovisioning keeps spare capacity in your cluster to reduce pod startup time. It works by running dummy pods that reserve resources. When real workloads need resources, the dummy pods are removed and replaced instantly.

## How It Works

1. **Dummy pods run** on your cluster with low priority
2. **Real workloads arrive** and need resources
3. **Dummy pods get evicted** to make room
4. **New dummy pods start** on new nodes to maintain spare capacity

## Configuration

### Basic Setup

```yaml
nodePool:
  default:
    overprovisioning:
      enabled: true
      nodes: 2
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 100m
          memory: 128Mi
```

### Advanced Configuration

```yaml
nodePool:
  default:
    overprovisioning:
      enabled: true
      nodes: 3
      
      # Resource requirements for dummy pods
      resources:
        requests:
          cpu: 200m
          memory: 256Mi
        limits:
          cpu: 200m
          memory: 256Mi
      
      # Spread dummy pods across different nodes
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app.kubernetes.io/component: overprovisioning
      
      # Allow dummy pods on tainted nodes
      tolerations:
      - key: node.kubernetes.io/unschedulable
        operator: Exists
        effect: NoSchedule
      
      # Add custom labels and annotations
      podLabels:
        team: platform
        purpose: overprovisioning
      
      podAnnotations:
        description: "Dummy pod for spare capacity"
```

## Key Features

### Low Priority
Dummy pods use priority class `-1000`, so they're evicted first when resources are needed.

### Node Distribution
Uses `topologySpreadConstraints` to spread dummy pods across different nodes:
- `maxSkew: 1` - allows maximum 1 pod difference between nodes
- `whenUnsatisfiable: DoNotSchedule` - ensures quality distribution

### Flexible Resources
Supports standard Kubernetes resource format with separate requests and limits.

## When to Use

- **Fast response times** are critical
- **Burst traffic** patterns
- **Batch jobs** with strict timing requirements
- **Cost vs performance** trade-off favors performance

## Cost Considerations

⚠️ **Important**: Overprovisioning increases infrastructure costs by keeping spare nodes running.

- **Additional compute costs** for dummy pods and their nodes
- **Idle resource expenses** during low traffic periods  
- **Cost scales** with the number of spare nodes configured
- **Consider carefully** if the performance benefit justifies the extra cost

Use overprovisioning when the cost of slow pod startup exceeds the cost of spare capacity.

## Monitoring

Check dummy pods are running:
```bash
kubectl get pods -l app.kubernetes.io/component=overprovisioning
```

View pod distribution across nodes:
```bash
kubectl get pods -l app.kubernetes.io/component=overprovisioning -o wide
```

## Troubleshooting

### Dummy pods not spreading
- Check `topologySpreadConstraints` configuration
- Verify node labels match topology key
- Ensure cluster has multiple nodes

### Pods stuck in Pending
- Review resource requests vs node capacity
- Check tolerations match node taints
- Verify `whenUnsatisfiable: DoNotSchedule` setting
