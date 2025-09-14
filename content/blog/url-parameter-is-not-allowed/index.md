---
title: "url parameter is not allowed"
date: 2025-08-12T19:56:30+09:00
lastmod: 2025-08-12T19:56:35+09:00
slug: ""
description: "next.js 14.2.5에서 발생한 400 Bad Request 해결하기"
keywords: []
tags: ["frontend", "nextjs"]
---

## 개요

Next.js 14.2.5 환경에서 외부 S3 버킷의 이미지를 Next.js Image 컴포넌트로 불러올 때 발생하는 "url parameter is not allowed" 400 에러에 대한 해결 방법을 다룹니다.

Next.js의 [Image Optimization API](https://nextjs.org/docs/14/pages/api-reference/components/image)는 이미지를 자동으로 최적화(리사이징, 포맷 변환, 품질 조정 등)하여 성능을 향상시키는 기능이지만, 보안상의 이유로 `next.config.js`의 `images.domains` 또는 `images.remotePatterns`에 명시적으로 허용된 외부 도메인만 처리할 수 있습니다. 

이 문제는 허용되지 않은 외부 도메인의 이미지 URL을 Image Optimization API가 거부하여 발생하며, [커스텀 loader](https://nextjs.org/docs/14/pages/api-reference/components/image#optional-props)를 통해 최적화 과정을 우회함으로써 해결할 수 있습니다.

## 증상

앞단의 Cloudflare는 통과했으며 에셋용 S3는 CORS 설정이 아예 없으나 400 Bad Request가 발생함.

로컬에서 해당 프론트엔드에 노출된 URL의 Image Optimization API를 호출해봅니다.

```bash
$ curl -v "https://my.frontend.co.kr/_next/image?url=https%3A%2F%2F<REDACTED_BUCKET_URL>%2F<ASSET_NAME>.png&w=1080&q=75"
...
< HTTP/2 400
< date: Tue, 12 Aug 2025 06:47:40 GMT
< cf-ray: 96de05cb18e58b5f-ICN
< cf-cache-status: DYNAMIC
< server: cloudflare
<
* Connection #0 to host 
"url" parameter is not allowed
```

해당 에러의 반환은 [image-optimizer.ts](https://github.com/vercel/next.js/blob/44fe971e6b3ba240ecd8f2d2d92025d831bc609d/packages/next/next-server/server/image-optimizer.ts#L89-L93) 코드에서 직접 확인 가능합니다.

프론트엔드 파드가 참조하는 해당 버킷의 이미지 에셋 URL에 직접 들어가면 이미지가 정상적으로 출력되며, 200 OK 응답 반환되는 것을 확인

## 환경

- Kubernetes 1.32
- Next.js 14.2.5

```bash
$ cat package.json | grep next
    "@mui/material-nextjs": "^5.15.11",
    "next": "14.2.5",
```

## 해결방법

Next.js 서버 설정파일인 next.config.js에 remotePatterns 값을 확인합니다.

```js
const config = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "**.first-bucket.co.kr",
        port: "",
        pathname: "**",
      },
      {
        protocol: "https",
        hostname: "**.second-bucket.co.kr",
        port: "",
        pathname: "**",
      },
    ],
  },
  assetPrefix,
  crossOrigin: "anonymous"
};
```

버킷 URL은 remotePatterns에 잘 등록되어 있습니다.

관련 이미지를 불러오는 `.tsx` 파일에서 loader를 추가합니다. 레포지터리에서의 모노레포 절대경로는 `/apps/<REDACTED>/app/<REDACTED>/(home)/_module/components/banner/banner.tsx` 이런식입니다.

수정 전:

```
  return (
    <Root>
      <SlideView
        {...STAKING_BANNER_SLIDE_VIEW_SETTINGS}
        dots={!isSingleBanner}
        infinite={!isSingleBanner}
        autoplay={!isSingleBanner}
      >
        {data?.banners.map(
          (banner) =>
            banner.lightBannerImagePath && (
              <Button
                key={`banner-${banner.id}`}
                onMouseDown={handleMouseDown}
                onClick={(e) => handleOnClick(e, moveToBannerLink(banner))}
              >
                <BannerImage
                  src={
                    isLight(theme)
                      ? banner.lightBannerImagePath
                      : banner.darkBannerImagePath
                  }
                  alt="staking banner"
                  width={480}
                  height={109}
                />
              </Button>
            ),
        )}
      </SlideView>
    </Root>
  );
```

수정 후:

배너 이미지를 호출하는 `.tsx` 파일에서 loader를 추가하니까 해결됨

```yaml
                <BannerImage
                  loader={() =>
                    isLight(theme)
                      ? banner.lightBannerImagePath
                      : banner.darkBannerImagePath
                  }
                  src={
                    isLight(theme)
                      ? banner.lightBannerImagePath
                      : banner.darkBannerImagePath
                  }
                  alt="staking banner"
                  width={480}
                  height={109}
                />
```

### 동작 원리

여러 이유들로 인해 설정파일(next.config.js)에 remotePatterns가 설정되어 있어도 여전히 에러가 발생할 수 있으며, 프론트엔드 코드 단에서 커스텀 loader를 사용하는 것이 더 확실한 해결책이 될 수 있습니다.

- 기본 동작: Next.js Image 컴포넌트는 src 속성의 URL을 /_next/image?url=<encoded_url>&w=<width>&q=<quality> 형태로 변환하여 Image Optimization API를 통해 처리
- 커스텀 loader 적용: loader 함수가 제공되면 Image Optimization API를 우회하고 loader 함수가 반환하는 URL을 직접 사용
- 결과: 외부 S3 버킷의 이미지가 remotePatterns 설정 없이도 직접 로드됨

이 방법을 사용하면 Next.js의 이미지 최적화 기능(자동 리사이징, WebP 변환 등)은 사용할 수 없지만, 외부 도메인 제한 문제를 해결할 수 있습니다.

## 관련자료

- [NEXT JS IMAGE 태그 400 error 해결방법](https://velog.io/@gbwlxhd97/NEXT-JS-IMAGE-%ED%83%9C%EA%B7%B8-400-error-%ED%95%B4%EA%B2%B0%EB%B0%A9%EB%B2%95)
- [Image optimisation external resource not working #18412](https://github.com/vercel/next.js/issues/18412)
