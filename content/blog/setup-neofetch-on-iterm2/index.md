---
title: "neofetch로 터미널 꾸미기"
date: 2022-08-03T21:04:30+09:00
lastmod: 2023-06-05T23:34:35+09:00
slug: ""
description: "neofetch 설치 후 커스텀 이미지 설정하는 방법"
keywords: []
tags: ["dev"]
---

## 개요

neofetch를 사용해서 터미널에 좋아하는 사진을 걸어놓는 방법을 소개합니다.
이 글은 터미널 프로그램으로 iTerm2를 사용하는 환경 기준으로 설명합니다.

&nbsp;

neofetch를 사용하면 자신이 좋아하는 이미지를 걸어서 터미널을 꾸밀 수 있고, 터미널을 열 때마다 시스템 스펙과 상세정보를 자동 확인할 수 있는 장점이 있습니다.

![neofetch가 적용된 화면](./1.png)

&nbsp;

## 환경

- **OS** : macOS Monterey 12.5 (M2)
- **Shell** : zsh + oh-my-zsh
- **neofetch** 7.1.0
  - brew로 설치
- **iTerm2** 3.4.16
  - brew로 설치

&nbsp;

## 준비사항

### 사용자 로컬 환경

- macOS 패키지 관리자인 [brew](https://brew.sh/) 설치가 필요합니다.
- brew를 사용해서 터미널 프로그램인 [iTerm2](https://iterm2.com/) 설치가 필요합니다.

brew와 iTerm2 설치 방법은 이 글의 주제를 벗어나는 내용이기 때문에 생략합니다.

&nbsp;

## 사용방법

### neofetch 설치

패키지 관리자인 brew를 이용해서 `neofetch`를 설치합니다.

```bash
$ brew install neofetch
```

&nbsp;

### imagemagick 설치

이미지 렌더링에 필요한 `imagemagick`도 설치합니다.

```bash
$ brew install imagemagick
```

[imagemagick](https://imagemagick.org/index.php)는 디지털 이미지를 생성, 편집, 구성 또는 변환하는 플러그인입니다. PNG, JPEG, GIF, WebP, HEIC, SVG, PDF, DPX, EXR 및 TIFF를 포함한 다양한 확장자(200개 이상)의 이미지를 읽고 쓸 수 있습니다.

&nbsp;

`neofetch` 명령어가 잘 동작하는 지 확인합니다.

```bash
$ which neofetch
/opt/homebrew/bin/neofetch
```

```bash
$ neofetch --version
Neofetch 7.1.0
```

현재 `Neofetch 7.1.0`이 설치된 상태입니다.

&nbsp;


### 소스 이미지 준비

neofetch에서 사용할 이미지 파일을 인터넷에서 검색한 후 다운로드 받습니다.

**neofetch에서 사용할 수 있는 이미지 확장자**  
`.jpg`, `.jpeg`, `.png`, `.webp` 확장자 모두 정상 동작합니다.

&nbsp;

### neofetch 설정

이후 neofetch 경로 안에 띄울 이미지를 보관할 전용 디렉토리를 만듭니다.

```bash
$ mkdir -p ~/.config/neofetch/images
```

&nbsp;

준비한 이미지 파일을 `mv` 명령어 또는 finder 탐색기를 통해서 `~/.config/neofetch/images/` 경로에 옮깁니다.

```bash
$ tree ~/.config/neofetch/
/Users/younsl/.config/neofetch/
├── config.conf              # neofetch 설정파일
└── images                   # 이미지 소스 경로
    └── redvelvet-irene.jpg  # 사용할 이미지

1 directory, 2 files
```

저같은 경우는 레드벨벳을 좋아해서 아이린 사진 `redvelvet-irene.jpg`을 준비했습니다.

&nbsp;

`neofetch` 설정파일인 `config.conf`를 수정합니다.

```bash
$ vi ~/.config/neofetch/config.conf
```

&nbsp;

아래와 같이 `config.conf` 파일을 수정합니다.  
중요 설정은 3개로 다음과 같습니다.

```bash
# default value is "ascii"
image_backend="iterm2"

...

# NOTE: 'auto' will pick the best image source for whatever image backend is used.
#       In ascii mode, distro ascii art will be used and in an image mode, your
#       wallpaper will be used.
image_source="/사용할/이미지/절대/경로.jpg"

...

# default value is "auto"
image_size="auto"
```

`image_source` 값 설정 시 주의사항은 다음과 같습니다.

- `image_source` 값의 경우 무조건 절대경로를 써야 합니다.  
- `~/.config/neofetch/images/test.jpg` 같이 `~` 상대경로를 사용하면 이미지 로드에 실패합니다.  
- `$HOME` 환경변수를 사용하는 것은 가능합니다.

&nbsp;

neofetch 설정 상태를 확인합니다.

```bash
$ cat -n ~/.config/neofetch/config.conf \
    | egrep 'image_size=|image_source=|image_backend'
```

```bash
   697  image_backend="iterm2"
   711  image_source="$HOME/.config/neofetch/images/redvelvet-irene.jpg"
   829  image_size="auto"
```

위 설정처럼 `image_source` 경로에 `$HOME` 환경변수가 들어간 경우, 로컬 환경에 `$HOME` 환경변수가 제대로 설정되어 있어야 이미지를 정상적으로 불러올 수 있습니다.

`echo` 명령어를 실행해서 `$HOME` 환경변수가 설정되어 있는지를 확인할 수 있습니다.

```bash
$ echo $HOME
/Users/younsl
```

&nbsp;

Visual Studio Code를 사용할 경우, `code` 명령어로 IDE를 실행하면서 지정한 설정파일을 띄울 수 있습니다.

```bash
$ code ~/.config/neofetch/config.conf
```

&nbsp;

### iTerm2 최적화 설정

neofetch 이미지가 출력될 때 iTerm2에서 간격이 크게 벌어지는 문제가 발생합니다.  
이를 해결하기 위해 iTerm2에서 2가지 설정을 변경해야 합니다.

&nbsp;

#### 첫번째 설정

왼쪽 위에 있는 메뉴바 → iTerm2 → `Settings...` 클릭

![iTerm2 설정 화면 1](./2.png)

`Settings...` 메뉴를 클릭하면 iTerm2 설정창이 열립니다.

&nbsp;

Preferences → Advanced → 검색창 → `Disable potentially insecure escape sequences` → `No`로 설정

![iterm2 설정 화면 2](./3.png)

&nbsp;

#### 두번째 설정

Preferences → Advanced → 검색창 → `Show inline images at retina resolution` → `No`로 설정

![iterm2 설정 화면 3](./4.png)

이제 neofetch를 사용할 준비가 되었습니다.

&nbsp;

### neofetch 자동 적용

zsh 설정파일인 `.zshrc`의 마지막 라인에 neofetch를 실행하도록 아래 라인을 추가합니다.

```bash
$ vi ~/.zshrc
neofetch
```

이제 iTerm2 터미널을 열 때마다 `neofetch` 명령어가 실행되면서 설정파일에 지정된 이미지를 불러옵니다.

&nbsp;

### 테스트

iTerm2 터미널을 열 때, 탭을 새로 생성할 때마다 레드벨벳 아이린이 반겨줍니다.

![neofetch 적용화면](./1.png)

자신이 지정한 사진이 중간중간 보고싶다면 `neofetch` 명령어를 직접 실행해도 이미지가 나옵니다.

매일마다 기분좋게 코딩할 수 있을 것 같습니다.

&nbsp;

## 트러블슈팅 가이드

### verbose 옵션

neofetch의 이미지 호출에 문제가 있는 경우, `-v` 옵션 또는 `-vv` 옵션을 사용해서 상세한 로그를 출력합니다.  
이 `neofetch` 로그들이 트러블슈팅에 많은 도움이 됩니다.

```bash
$ neofetch --iterm2 /path/to/image/ \
    --size 400 \
    -v
```

```bash
...
[!] Config: Sourced user config.    (/Users/younsl/.config/neofetch/config.conf)
[!] Image: Using image ''
[!] Image: '' doesn't exist, falling back to ascii mode.
[!] Info: Couldn't detect Theme.
[!] Info: Couldn't detect Icons.
[!] Neofetch command: /opt/homebrew/bin/neofetch -v --iterm2 /path/to/image/
[!] Neofetch version: 7.1.0
```

&nbsp;

## 참고자료

[younsl/dotfiles](https://github.com/younsl/dotfiles/tree/main/neofetch)  
제가 현재 사용중인 neofetch 설정파일입니다.  
설정하실 때 예시로 참고 삼아 보시면 도움이 될 것 같습니다.
