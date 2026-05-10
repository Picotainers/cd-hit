# syntax=docker/dockerfile:1

FROM debian:bookworm AS builder

ARG CD_HIT_VERSION=V4.8.1
ARG CD_HIT_URL=https://github.com/weizhongli/cdhit/archive/refs/tags/V4.8.1.tar.gz

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates curl make g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN curl -fsSL "$CD_HIT_URL" -o cdhit.tar.gz \
    && tar -xzf cdhit.tar.gz

WORKDIR /src/cdhit-V4.8.1
RUN make -j"$(nproc)" \
    && test -x cd-hit \
    && cp cd-hit /tmp/cd-hit

RUN mkdir -p /tmp/runtime-libs \
    && (ldd /tmp/cd-hit | awk '/=> \/|^\// {for(i=1;i<=NF;i++) if ($i ~ /^\//) print $i}' | sort -u | xargs -r -I{} cp -v --parents "{}" /tmp/runtime-libs) || true

FROM debian:bookworm-slim

COPY --from=builder /tmp/cd-hit /usr/local/bin/cd-hit
COPY --from=builder /tmp/runtime-libs/ /

RUN chmod +x /usr/local/bin/cd-hit \
    && printf '%s\n' '#!/bin/sh' \
    'if [ "${1:-}" = "cd-hit" ]; then shift; fi' \
    'exec /usr/local/bin/cd-hit "$@"' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
