
# rbac: Kubernetes RBAC Helm Chart

`rbac` helm chart allows you to manage Kubernetes RBAC<sup>Role-Based Access Control</sup> resources, including `ClusterRole` and `ClusterRoleBinding` definitions. By using this chart, you can maintain a single source of truth for your RBAC configurations, ensuring consistency and simplifying management across your Kubernetes clusters.

For a developer or engineer to access internal resources within Kubernetes, need to perform configuration tasks in the following areas.

<img width="729" alt="image" src="https://github.com/user-attachments/assets/0ca703e8-1156-4934-b503-3d694bba6b58" />

## Configuration

The `values.yaml` file defines the configuration for this chart. Below is a description of the available configuration options:

## values

### global

- `commonLabels`: Common labels applied to all RBAC resources.

```yaml
# rbac/values.yaml
global:
  commonLabels:
    github.com/organization-name: funny-company
    github.com/repository-name: charts
    github.com/team: devops
```

### clusterRoles

Define multiple `ClusterRole` resources with specific rules and labels.

Example configuration in `values.yaml`:

```yaml
# rbac/values.yaml
clusterRoles:
  pod-maintainer-developer:
    labels: {}
    rules:
    - apiGroups: ["keda.sh"]
      resources: ["scaledobjects"]
      verbs: ["get", "list", "watch", "update", "patch"]
    - apiGroups: [""]
      resources: ["pods", "services"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    - apiGroups: [""]
      resources: ["pods/log", "nodes"]
      verbs: ["get", "list"]
    - apiGroups: [""]
      resources: ["pods/exec"]
      verbs: ["create", "get"]
    - apiGroups: [""]
      resources: ["pods/portforward"]
      verbs: ["create", "get"]
    - apiGroups: ["apps"]
      resources: ["deployments", "deployments/scale", "deployments/status", "deployments/rollback", "replicasets", "replicasets/scale", "replicasets/status", "statefulsets", "statefulsets/scale", "statefulsets/status"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    - apiGroups: ["networking.k8s.io"]
      resources: ["ingresses"]
      verbs: ["list", "watch", "get", "patch", "update"]

  security-audit:
    labels:
      funny-jira.atlassian.net/issue-number: FUN-1234
      funny-jira.atlassian.net/requestor: johndoe
    rules:
    - apiGroups: ["rbac.authorization.k8s.io"]
      resources: ["roles", "rolebindings"]
      verbs: ["get", "list", "watch"]
    - apiGroups: ["rbac.authorization.k8s.io"]
      resources: ["clusterroles", "clusterrolebindings"]
      verbs: ["get", "list", "watch"]
    - apiGroups: [""]
      resources: ["pods/attach", "pods/exec"]
      verbs: ["create"]
```

### clusterRoleBindings

Define multiple `ClusterRoleBinding` resources with specific role references and subjects.

Example configuration:

```yaml
clusterRoleBindings:
  pod-maintainer-developer:
    labels: {}
    roleRef:
      kind: ClusterRole
      name: pod-maintainer-developer
    subjects:
      kind: Group
      name: system:developers
  security-audit:
    labels:
      funny-jira.atlassian.net/issue-number: FUN-1234
      funny-jira.atlassian.net/requestor: johndoe
    roleRef:
      kind: ClusterRole
      name: security-audit
    subjects:
      kind: Group
      name: security-engineers
```

## Usage

To use this Helm chart, you need to provide your custom values for the `clusterRoles` and `clusterRoleBindings` in the `values.yaml` file.

1. **Clone the Repository**: Clone the repository containing this Helm chart.

   ```bash
   git clone https://github.com/younsl/charts.git
   cd charts/rbac
   ```

2. **Customize Values**: Edit the `values.yaml` file to define your `ClusterRole` and `ClusterRoleBinding` resources as per your requirements.

3. **Install the Chart**: Install the Helm chart with your custom values.

   ```bash
   helm upgrade \
     --install \
     --namespace kube-system \
     rbac . \
     --values values.yaml
   ```

4. **Verify Installation**: Verify the installation by listing the created RBAC resources.

   ```bash
   kubectl get clusterroles -o wide
   kubectl get clusterrolebindings -o wide
   ```

## Examples

Here are some example configurations for `ClusterRole` and `ClusterRoleBinding` resources:

### Example ClusterRole

```yaml
# rbac/values.yaml
global:
  commonLabels:
    github.com/organization-name: funny-company
    github.com/repository-name: charts
    github.com/team: devops

clusterRoles:
  example-role:
    labels:
      app: example
    rules:
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "list", "watch"]
    - apiGroups: ["apps"]
      resources: ["deployments"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

### Example ClusterRoleBinding

```yaml
# rbac/values.yaml
global:
  commonLabels:
    github.com/organization-name: funny-company
    github.com/repository-name: charts
    github.com/team: devops

clusterRoleBindings:
  example-binding:
    labels:
      app: example
    roleRef:
      kind: ClusterRole
      name: example-role
    subjects:
      - apiGroup: rbac.authorization.k8s.io
        kind: User
        name: example-user
```

## Uninstalling the Chart

To uninstall/delete the `rbac` helm release:

```bash
helm uninstall rbac -n kube-system
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Contributing

If you have any suggestions or improvements for this chart, feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/younsl/charts).

## License

This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details.
