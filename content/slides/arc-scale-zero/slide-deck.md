---
marp: true
header: "SRE Weekly"
paginate: true
style: |
  section {
    color: white; /* 폰트 컬러를 흰색으로 설정 */
    background-color: black; /* 배경색을 블랙으로 설정 */
  }
  table {
    color: black;
  }
footer: "© 2025 Younsung Lee. All rights reserved."
---

## Actions Runner Controller Scaling

Scale-zero로 러너 컴퓨팅 비용 절감하기

---

### Topics

- **Actions Runner Controller의 스케일링 방식**
- **Webhook-driven scaling 구현 방법**
- **Scale zero 설정시 주의사항**

---

### Actions Runner Controller의 스케일링 방식

![](./assets/1.png)

---

### Actions Runner Controller의 스케일링 방식

![](./assets/2.png)

---

### ARC에서 권장하는 스케일링 방식

![](./assets/3.png)

반응 빠름, Scale zero 가능, 안전함 (Github API Rate Limit 영향 받지 않음)

---

### Actions Runner Controller 아키텍처

![height:560px](./assets/4.png)

---

### 웹훅의 여정

![Webhook 이벤트가 웹훅 서버까지 도달하는 과정](./assets/5.png)

---

### HorizontalRunnerAutoscaler 설정

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: HorizontalRunnerAutoscaler
metadata:
  name: scalezero-test-runner-hra
  namespace: actions-runner
spec:
  # You can set minReplicas to 0 to enable scale-to-zero functionality
  minReplicas: 0
  maxReplicas: 5
  scaleTargetRef:
    kind: RunnerDeployment
    name: scalezero-test-runner
  scaleUpTriggers:
  - amount: 1
    duration: 5m
    githubEvent:
      # Workflow job queued, waiting, in progress, or completed on a repository
      workflowJob: {}
```

---

### RunnerDeployment 설정 및 주의사항

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: scalezero-test-runner
  namespace: actions-runner
spec:
  template:
    spec:
      labels:
      - self-hosted  # Explicitly add this label for GHES
      - linux        # Explicitly add this label for GHES
      - test-runner
      repository: ORGANIZATION_NAME/REPO_NAME
```

<style scoped>
code {
  line-height: 1.1;
}
pre {
  line-height: 1.1;
}
</style>

:warning: runnerDeployment에 러너에 **자동생성되는 라벨**도 명시적(Explicitly)으로 추가해야 ARC 웹훅 서버가 웹훅 이벤트를 받아 스케일링 대상(scale target)을 인식할 수 있습니다.

---

### EOD.