FROM alpine:3.21.0

LABEL maintainer="Younsung Lee <cysl@kakao.com>" \
      version="1.1.0" \
      description="Lightweight Docker image for running a Hugo blog server for local development" \
      repository="https://github.com/younsl/box" \
      homepage="https://younsl.github.io" \
      runtime="docker-desktop, podman" \
      build-date="2025-01-25"

ARG HUGO_VERSION=0.144.2
ARG OS=linux
ARG ARCH=arm64
ARG HUGO_PACKAGE_NAME=${HUGO_VERSION}_${OS}-${ARCH}

# IMPORTANT:
# To fix the issue "/bin/sh: /usr/local/bin/hugo: not found" during the container build process, 
# you must install the libc6-compat and g++ packages in the alpine image.
# See: https://github.com/gohugoio/hugo/issues/4939#issuecomment-484956006
RUN apk update && \
    apk add --no-cache \
        git \
        wget \
        libc6-compat \
        g++ && \
    wget -O hugo_extended_${HUGO_PACKAGE_NAME}.tar.gz https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_PACKAGE_NAME}.tar.gz && \
    tar -xzvf hugo_extended_${HUGO_PACKAGE_NAME}.tar.gz && \
    rm hugo_extended_${HUGO_PACKAGE_NAME}.tar.gz && \
    mv hugo /usr/local/bin/ && \
    chmod +x /usr/local/bin/hugo && \
    ls -l /usr/local/bin/ && \
    /usr/local/bin/hugo version

WORKDIR /app
VOLUME /app

EXPOSE 1313

ENTRYPOINT ["hugo", "server"]
CMD ["-t", "void", "--bind", "0.0.0.0"]
