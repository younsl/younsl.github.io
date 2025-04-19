---
title: "xcrun error"
date: 2021-10-27T01:13:09+09:00
lastmod: 2024-12-02T21:11:05+09:00
slug: ""
description: "macOS 업데이트 이후 git 명령어 실행시 발생하는 xcrun: error: invalid active developer path 에러 해결하기"
keywords: []
tags: ["dev", "terminal", "macos"]
---

## 개요

`git` 명령어 실행시 `xcrun: error: invalid active developer path` 에러가 발생하면 해당 가이드를 참고해서 문제를 해결할 수 있습니다.

해당 에러는 macOS 업데이트 완료 이후 발생할 수 있습니다.

&nbsp;

## 환경

### 로컬 환경

에러가 발생한 시스템 환경은 다음과 같습니다.

- **Model** : MacBook Pro (13inch, M1, 2020)
- **OS** : macOS Monterey 12.0.1
- **Shell** : zsh
- **터미널** : macOS 기본 터미널

```bash
$ sw_vers
ProductName:  macOS
ProductVersion: 12.0.1
BuildVersion: 21A559
```

&nbsp;

## 증상

macOS Catalina 11.6에서 macOS Monterey 12.0.1로 소프트웨어 업데이트를 한 이후부터 `git` 명령어를 실행하면 `xcrun: error: invalid active developer path` 에러 메세지가 반환되며 명령어를 실행할 수 없습니다.

`git` 명령어를 실행할 때 발생하는 에러 메세지는 다음과 같습니다.

```bash
$ git commit -m 'rebuilding site 2021년 10월 27일 수요일 00시 34분 04초 KST'

xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
```

&nbsp;

`git commit` 명령어 뿐만 아니라 `git push` 실행시에도 동일한 에러 메세지가 발생합니다.

```bash
$ git push origin master

xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
```

&nbsp;

## 원인

macOS에서 OS 업데이트가 진행될때마다 자주 발생되는 Xcode CLI 관련 호환성 이슈입니다.

대표적인 개발툴인 git, make, gcc가 Xcode CLI의 영향을 받습니다.

&nbsp;

## 해결방법

### 1. Xcode CLI 설치

Xcode CLI를 수동으로 설치해서 문제를 해결할 수 있습니다.

```bash
xcode-select --install
```

&nbsp;

명령어 실행 결과는 다음과 같습니다.

```bash
xcode-select: note: install requested for command line developer tools
```

이후 GUI 환경에서 [설치] 버튼을 눌러 명령어 라인 개발자 도구(Command line developer tools)를 설치하면 됩니다.

설치후에 이전에 실행되지 않았던 명령어가 잘 실행되는 지 테스트합니다.

&nbsp;

### 2. Xcode CLI 초기화

Xcode CLI를 설치해도 증상이 동일하다고 하면 Xcode CLI를 초기화합니다.  
초기화 시에는 root 계정 권한이 필요합니다.

```bash
$ sudo xcode-select --reset
Password: [패스워드 입력]
```

&nbsp;

### 3. git 명령어 테스트

이전에 에러가 발생했던 `git` 명령어를 다시 실행합니다.

```bash
$ git commit -m 'rebuilding site 2021년 10월 27일 수요일 00시 45분 23초 KST'
... omitted for brevity ...
 2 files changed, 28 insertions(+), 3 deletions(-)
```

```bash
$ git push origin master
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 8 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 1.33 KiB | 1.33 MiB/s, done.
... omitted for brevity ...
   5936bbc..902284d  master -> master
```

Xcode CLI를 설치완료 이후에는 `xcrun: error: invalid active developer path` 에러 메세지 없이 `git` 명령어가 정상적으로 실행됩니다.

&nbsp;

## 관련자료

- [Mac 업그레이드 후 xcrun: error: invalid active developer path 에러 해결하기](https://www.hahwul.com/2019/11/18/how-to-fix-xcrun-error-after-macos-update/)
- [Apple forum의 문의글 - xcrun: error: invalid active developer path](https://forums.developer.apple.com/forums/thread/673827)
