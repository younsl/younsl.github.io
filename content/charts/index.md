---
title: "charts"
date: 2024-08-11T15:38:15+09:00
lastmod: 2024-08-11T15:35:33+09:00
slug: ""
description: "Index page for helm chart repoistory"
keywords: []
tags: ["helm", "chart"]
showComments: false
showAdvertisement: false
---

## 개요

헬름 차트 저장소.

현재 [`younsl.github.io`](https://github.com/younsl/younsl.github.io) 블로그 레포지터리는 헬름 차트 저장소로서도 서비스 되고 있습니다.

&nbsp;

## 사용법

`younsl`이라는 이름으로 헬름 차트 저장소를 추가합니다.

```bash
helm repo add younsl https://younsl.github.io
helm repo update
```

`younsl` 차트 저장소에 있는 모든 헬름 차트를 검색합니다. 이를 통해 저장소에 포함된 차트의 목록과 각 차트의 세부 정보를 확인할 수 있습니다.

```bash
helm search repo younsl
```
