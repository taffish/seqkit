ARG SEQKIT_VERSION=2.13.0
ARG SEQKIT_TAG=v2.13.0
ARG SEQKIT_AMD64_SHA256=7d686de448464fada1b1988e2e07d693bec68768312da62846bc0e2b502bfc46
ARG SEQKIT_ARM64_SHA256=2bce55ea352ceab56a428b2d6e06e6565485a446c17dc17cadb5dc28ab7a9cdc

FROM debian:12-slim AS fetch

ARG TARGETARCH
ARG SEQKIT_VERSION
ARG SEQKIT_TAG
ARG SEQKIT_AMD64_SHA256
ARG SEQKIT_ARM64_SHA256

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) seqkit_arch="amd64"; seqkit_sha="${SEQKIT_AMD64_SHA256}" ;; \
      arm64) seqkit_arch="arm64"; seqkit_sha="${SEQKIT_ARM64_SHA256}" ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL \
      -o seqkit.tar.gz \
      "https://github.com/shenwei356/seqkit/releases/download/${SEQKIT_TAG}/seqkit_linux_${seqkit_arch}.tar.gz"; \
    echo "${seqkit_sha}  seqkit.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/seqkit/bin /opt/seqkit/share/licenses/seqkit; \
    tar -xzf seqkit.tar.gz -C /opt/seqkit/bin seqkit; \
    chmod 0755 /opt/seqkit/bin/seqkit; \
    curl -fsSL \
      -o /opt/seqkit/share/licenses/seqkit/LICENSE \
      "https://raw.githubusercontent.com/shenwei356/seqkit/${SEQKIT_TAG}/LICENSE"; \
    /opt/seqkit/bin/seqkit version | grep -Fx "seqkit v${SEQKIT_VERSION}" >/dev/null; \
    /opt/seqkit/bin/seqkit --help 2>&1 | grep -F "SeqKit -- a cross-platform and ultrafast toolkit" >/dev/null; \
    file /opt/seqkit/bin/seqkit | grep -E "(statically linked|static)" >/dev/null

FROM debian:12-slim

ARG SEQKIT_VERSION

LABEL maintainer="taffish@163.com"

COPY --from=fetch /opt/seqkit /opt/seqkit

RUN set -eux; \
    ln -sf /opt/seqkit/bin/seqkit /usr/local/bin/seqkit; \
    command -v seqkit >/dev/null; \
    command -v ldd >/dev/null; \
    seqkit version | grep -Fx "seqkit v${SEQKIT_VERSION}" >/dev/null; \
    seqkit --help 2>&1 | grep -F "SeqKit -- a cross-platform and ultrafast toolkit" >/dev/null; \
    seqkit sample2 --help 2>&1 | grep -F "sample sequences" >/dev/null; \
    { ldd "$(command -v seqkit)" 2>&1 || true; } | grep -E "(not a dynamic executable|statically linked)" >/dev/null; \
    mkdir -p /tmp/seqkit-check; \
    cd /tmp/seqkit-check; \
    printf '>chr1\nACGTACGTNNNNACGT\n>chr2\nTTAGGGTTAGGGCCCTAA\n' > ref.fa; \
    printf '@r1\nACGTNN\n+\nFFFFFF\n@r2\nTTAGGGTTAGGG\n+\nFFFFFFFFFFFF\n' > reads.fq; \
    seqkit stats -T ref.fa reads.fq > stats.tsv; \
    grep -F "ref.fa" stats.tsv >/dev/null; \
    grep -F "reads.fq" stats.tsv >/dev/null; \
    seqkit fq2fa reads.fq > reads.fa; \
    grep -F ">r1" reads.fa >/dev/null; \
    seqkit grep -p chr2 ref.fa > chr2.fa; \
    grep -F ">chr2" chr2.fa >/dev/null; \
    seqkit faidx ref.fa chr1:2-5 > slice.fa; \
    grep -F "CGTA" slice.fa >/dev/null; \
    seqkit seq -o ref.fa.lz4 ref.fa; \
    test -s ref.fa.lz4; \
    seqkit stats ref.fa.lz4 > lz4.stats; \
    grep -F "ref.fa.lz4" lz4.stats >/dev/null; \
    rm -rf /tmp/seqkit-check

ENV PATH=/opt/seqkit/bin:${PATH}

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=seqkit

WORKDIR /root
