---
title: "err pnpm no lockfile"
date: 2025-06-06T16:50:00+09:00
lastmod: 2025-06-06T16:50:00+09:00
description: How to fix 'Cannot install with frozen-lockfile because pnpm-lock.yaml is absent' error in CI/CD pipelines
keywords: []
tags: ["actions", "pnpm", "cicd", "docker"]
---

## 개요

CI/CD 파이프라인에서 Dockerfile이 `pnpm install`을 사용할 때 다음과 같은 오류가 발생할 수 있습니다:

```dockerfile
Step 5/8 : RUN pnpm install --frozen-lockfile
 ---> Running in 30f66c05418a
 ERR_PNPM_NO_LOCKFILE  Cannot install with "frozen-lockfile" because pnpm-lock.yaml is absent
```

## 문제 원인

이 오류는 일반적으로 CI 환경의 pnpm 버전과 로컬 개발 환경의 pnpm 버전이 다를 때 발생합니다. 파이프라인 로그에서 다음과 같은 경고를 확인할 수 있습니다:

```dockerfile
Ignoring not compatible lockfile at pnpm-lock.yaml
```

## 해결 방법

GitHub Actions에서 pnpm을 사용하는 경우, 다음과 같이 설정을 업데이트합니다.

1. [pnpm/action-setup](https://github.com/pnpm/action-setup) 액션을 최신 버전으로 업데이트
2. [pnpm/action-setup](https://github.com/pnpm/action-setup) 액션에서 [version](https://github.com/pnpm/action-setup?tab=readme-ov-file#inputs) 옵션을 사용하여 로컬 환경에서 빌드 성공시에 사용한 pnpm 버전을 명시적으로 지정

Actions Workflow를 사용하는 경우:

```yaml
# .github/workflows/your-workflow.yml
jobs:
  your-job-name:
    # ... other steps ...
    steps:
      - uses: pnpm/action-setup@v4
        with:
          version: 9.5.0
```

Dockerfile에서 pnpm을 사용하는 경우:

```dockerfile
# your-project/Dockerfile
FROM node:20

# ... omiitted for brevity ...

RUN npm install -g pnpm@9.5.0
RUN pnpm install --frozen-lockfile
```

`--frozen-lockfile` 옵션은 패키지 매니저가 lockfile을 읽기 전용으로 처리하도록 하는 옵션입니다.

로컬 pnpm 버전은 다음 명령어로 확인할 수 있습니다:

```bash
which pnpm && pnpm --version
```

## 관련자료

- **원문**: [How to Fix Cannot Install with Frozen Lockfile Because pnpm-lock.yaml is Absent in pnpm](https://www.bstefanski.com/blog/how-to-fix-cannot-install-with-frozen-lockfile-because-pnpm-lockyaml-is-absent-in-pnpm)
