# syntax=docker/dockerfile:1

FROM debian:bookworm AS builder

ARG CD_HIT_VERSION=V4.8.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates git make g++ zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "$CD_HIT_VERSION" https://github.com/weizhongli/cdhit.git cdhit

WORKDIR /src/cdhit
RUN make -j"$(nproc)" \
    && test -x cd-hit \
    && cp cd-hit /tmp/cd-hit

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates libstdc++6 zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/cd-hit /usr/local/bin/cd-hit

RUN chmod +x /usr/local/bin/cd-hit \
    && printf '%s\n' '#!/bin/sh' \
    'if [ "${1:-}" = "cd-hit" ]; then shift; fi' \
    'exec /usr/local/bin/cd-hit "$@"' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
