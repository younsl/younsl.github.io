---
title: "Actions with Automatic Token"
date: 2024-06-15T10:41:30+09:00
lastmod: 2024-06-15T10:41:35+09:00
slug: ""
description: "Actions"
keywords: []
tags: ["github", "actions"]
---

{{< toc >}}

&nbsp;

## 개요

이 글에서는 GitHub Actions에서 자동으로 생성되는 GITHUB_TOKEN을 활용하여 다양한 작업을 수행하는 방법을 설명합니다. `GITHUB_TOKEN`을 사용하면 별도의 관리자 계정이나 개인 액세스 토큰(PAT)을 생성할 필요 없이 이슈 생성, 브랜치 삭제, 클론 등의 작업을 자동화할 수 있습니다. 이를 통해 토큰 관리를 보다 간편하게 할 수 있습니다.

GitHub CLI를 사용한 이슈 생성과 REST API를 통한 브랜치 삭제의 구체적인 예제 코드와 설정 방법을 다룹니다. 더 자세한 정보는 [GitHub Enterprise Server 공식 문서](https://docs.github.com/en/enterprise-server/actions/security-guides/automatic-token-authentication#example-2-calling-the-rest-api)를 참조할 수 있습니다.

&nbsp;

## 배경지식

### automatic token authentication

Workflow Job이 실행될 때, Github은 `GITHUB_TOKEN` 시크릿을 워크플로우 실행동안 자동으로 생성합니다.

자동 생성된 `GITHUB_TOKEN` Secret을 Workflow 과정에서 사용하려면 `${{ secrets.GITHUB_TOKEN }}`을 사용하여 `GITHUB_TOKEN` 시크릿을 사용할 수 있습니다.

`GITHUB_TOKEN` 활용 사례로는 토큰을 브랜치 삭제, 이슈 생성 작업에 대한 입력으로 전달하거나 이를 사용하여 인증된 GitHub Enterprise Server API 요청을 만드는 것이 포함됩니다.

Workflow가 실행될 때 자동 생성되는 `GITHUB_TOKEN`을 사용하여 Workflow Job에서 별도의 관리자 계정이나 유저의 Personal Access Token 없이도 Github 이슈 생성, 브랜치 삭제, Clone 등의 작업을 수행할 수 있습니다.

&nbsp;

## Automatic token 사용 예시

### Github CLI에서 env로 등록하여 사용

이 예제 워크플로에서는 `GH_TOKEN`이라는 이름의 환경변수의 값으로 `GITHUB_TOKEN`이 필요한 GitHub CLI를 사용합니다.

```yaml
name: Open new issue
on: workflow_dispatch

jobs:
  open-issue:
    runs-on: [self-hosted, linux]
    # GITHUB_TOKEN에 부여할 권한
    permissions:
      contents: read
      issues: write
    steps:
      - name: Install gh cli
        run: |
          sudo apt update
          sudo apt install gh
          which gh && gh --version

      - name: Open issue
        run: |
          gh issue --repo ${{ github.repository }} \
            create --title "Issue title" --body "Issue body"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

&nbsp;

### REST API로 브랜치 삭제

자동 생성된 `GITHUB_TOKEN` 시크릿에 `permissions` 키워드로 특정 권한을 부여하면 브랜치 삭제나 아티팩트<sup>Release</sup> 삭제 등의 Github API 호출을 수행할 수 있습니다. 이 예시 워크플로는 GitHub REST API를 사용하여 브랜치를 삭제합니다.

```yaml
name: Delete stale branches
run-name: Delete stale Branch - ${{ github.actor }}

on:
  workflow_dispatch:

jobs:
  delete-branch:
    runs-on: [self-hosted, linux]
    # GITHUB_TOKEN에 부여할 권한
    permissions:
      # Delete branch 할때 contents: write 권한 필요
      contents: write
    steps:
      - name: Checkout repository
        id: checkout
        uses: actions/checkout@v2

      - name: Delete stale branch
        id: delete-branch
        run: |
          curl -L \
               -X DELETE \
               -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
               -H "Accept: application/vnd.github+json" \
               -H "X-GitHub-Api-Version: 2022-11-28" \
               https://<HOSTNAME>/api/v3/repos/${{ github.repository }}/git/refs/<BRANCH_NAME>
```

&nbsp;

### REST API로 브랜치 생성

이 워크플로우는 GitHub Actions를 사용하여 새로운 브랜치를 생성하는 예제입니다. 실행자는 workflow_dispatch 이벤트를 통해 이 워크플로우를 수동으로 트리거할 수 있으며, 실행자의 이름이 run-name에 포함됩니다. 워크플로우는 먼저 저장소를 체크아웃하고, 기본 브랜치(main)의 SHA를 가져와 이를 기반으로 새로운 브랜치를 생성합니다.

```yaml
name: Create a new branch
run-name: Create new Branch - ${{ github.actor }}

on:
  workflow_dispatch:

jobs:
  create-branch:
    runs-on: [self-hosted, linux]
    permissions:
      contents: write
    steps:
      - name: Checkout repository
        id: checkout
        uses: actions/checkout@v2

      - name: Create new branch
        id: create-branch
        env:
          BASE_BRANCH: main
          NEW_BRANCH: new-branch
        run: |
          SHA=$(curl -L \
            -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://<HOSTNAME>/api/v3/repos/${{ github.repository }}/git/ref/heads/${{ env.BASE_BRANCH }} | jq -r .object.sha)
          
          echo "SHA value of the base branch (${{ env.BASE_BRANCH }}): $SHA"

          curl -L \
            -X POST \
            -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://<HOSTNAME>/api/v3/repos/${{ github.repository }}/git/refs \
            -d "{
                  \"ref\": \"refs/heads/${{ env.NEW_BRANCH }}\", 
                  \"sha\": \"$SHA\"
                }"
```

- **permissions 설정**: permissions 섹션에서 contents: write 권한이 필요합니다. 이는 브랜치를 생성하는 데 필수적인 권한입니다.
- **환경변수 사용**: ${{ secrets.GITHUB_TOKEN }}을 사용하여 자동 생성된 토큰을 curl 명령어에 전달함으로써 인증된 API 호출을 수행할 수 있습니다.
- **SHA 가져오기**: curl과 jq를 사용하여 기본 브랜치의 SHA를 가져오는 부분은 GitHub API와 JSON 처리를 이해하는 데 유용한 예제입니다.

&nbsp;

더 자세한 사항은 Github Enterprise Server 공식문서 [Automatic token authentication](https://docs.github.com/en/enterprise-server/actions/security-guides/automatic-token-authentication#example-2-calling-the-rest-api)를 참고합니다.

&nbsp;

## 참고자료

[Automatic token authentication](https://docs.github.com/en/enterprise-server/actions/security-guides/automatic-token-authentication#example-2-calling-the-rest-api)