---
title: "git 삭제된 파일 복구"
date: 2022-08-31T15:38:15+09:00
lastmod: 2023-08-12T18:48:25+09:00
slug: ""
description: "깃허브 삭제된 파일 복구"
keywords: []
tags: ["git", "dev"]
---

## 문제상황

실수로 Github 레포지터리 안에 포함된 한 디렉토리를 삭제해버린 상황입니다.

```bash
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
    deleted:    docs/meme-library/README.md
    deleted:    docs/meme-library/asset/2001-sysadmin-and-2020-devops.jpg
    deleted:    docs/meme-library/asset/box-of-devops.jpg
    deleted:    docs/meme-library/asset/bring-solutions-istio.png
    deleted:    docs/meme-library/asset/cncf-landscape-meme.jpeg
    deleted:    docs/meme-library/asset/devops-nowadays.jpeg
    deleted:    docs/meme-library/asset/it-came-with-a-message.jpeg
    deleted:    docs/meme-library/asset/its-the-hard-way-folks.png
    deleted:    docs/meme-library/asset/k8s-api.jpg
    deleted:    docs/meme-library/asset/simpsons-against-devops.png
    deleted:    docs/meme-library/asset/woman-yelling-at-a-k8s-cat.jpeg
    deleted:    docs/meme-library/asset/yeah-automate.jpeg
```

또는 아래 방법으로도 삭제된 파일 리스트를 확인할 수 있습니다.

```bash
$ git ls-files -d
```

&nbsp;

## 환경

- **git** : git version 2.32.1 (Apple Git-133)
- **shell** : zsh + oh-my-zsh

&nbsp;

## 해결방법

### 여러 파일 복구

Github 레포지터리 안에서 삭제된 전체 파일을 복구합니다.

```bash
$ git ls-files -d | xargs git checkout --
```

&nbsp;

명령어 실행 결과는 다음과 같습니다.

```bash
Updated 12 paths from the index
```

&nbsp;

모든 deleted 파일이 복구되었습니다.

```bash
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

&nbsp;

### 단일 파일 복구

하나의 특정 파일만 복구합니다.

```bash
$ git checkout <file-name-to-restore>
```
