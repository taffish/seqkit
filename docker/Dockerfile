ARG SEQKIT_VERSION=2.14.0
ARG SEQKIT_AMD64_SHA256=3d664ffb48438d1fbd3f3cfc060c71d00368a26435f1c876944aea7fcdff86b5
ARG SEQKIT_ARM64_SHA256=f0f68f3b595c9fa2ef7185a93a6f16a83d7411f9027318e8987031b8646d56bf

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251 AS fetch
ARG TARGETARCH
ARG SEQKIT_VERSION
ARG SEQKIT_AMD64_SHA256
ARG SEQKIT_ARM64_SHA256

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl file \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build
COPY docker/licenses.tar.gz docker/fixtures.tar.gz ./
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) archive_sha="${SEQKIT_AMD64_SHA256}" ;; \
      arm64) archive_sha="${SEQKIT_ARM64_SHA256}" ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fL --retry 3 -o seqkit.tar.gz \
      "https://github.com/shenwei356/seqkit/releases/download/v${SEQKIT_VERSION}/seqkit_linux_${TARGETARCH}.tar.gz"; \
    printf '%s  seqkit.tar.gz\n' "$archive_sha" | sha256sum -c -; \
    printf '%s  licenses.tar.gz\n' '54bcfae56973297dfa8f1c53aa88f58be914c2b94f2ed2f043abfaafa7b3af31' | sha256sum -c -; \
    printf '%s  fixtures.tar.gz\n' '8ee85946bcccc3d4c188ccaa83eb8019ca81feca7987077866667fe76d53d8cf' | sha256sum -c -; \
    mkdir -p /opt/seqkit/bin /opt/seqkit/share; \
    tar -xzf seqkit.tar.gz -C /opt/seqkit/bin seqkit; \
    tar -xzf licenses.tar.gz -C /opt/seqkit/share; \
    tar -xzf fixtures.tar.gz -C /opt/seqkit/share; \
    chmod 0755 /opt/seqkit/bin/seqkit; \
    file /opt/seqkit/bin/seqkit | grep -F 'statically linked'; \
    printf 'version=%s\narch=%s\narchive_sha256=%s\n' "$SEQKIT_VERSION" "$TARGETARCH" "$archive_sha" > /opt/seqkit/share/source.txt

FROM debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251
ARG SEQKIT_VERSION
LABEL maintainer="taffish@163.com"
COPY --from=fetch /opt/seqkit /opt/seqkit
COPY --from=fetch /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=fetch /usr/share/doc/ca-certificates/copyright /opt/seqkit/share/licenses/ca-certificates-COPYRIGHT
COPY docker/smoke.sh /opt/seqkit/share/smoke.sh
ENV PATH=/opt/seqkit/bin:${PATH}

# 构建期只做稳定身份/help/tiny 功能；绘图和完整回归留给离线 runtime smoke。
RUN set -eu; \
    command -v bash; \
    seqkit version > /tmp/version.txt; \
    grep -Fx "seqkit v${SEQKIT_VERSION}" /tmp/version.txt; \
    seqkit --help > /tmp/help.txt; \
    grep -F 'SeqKit -- a cross-platform and ultrafast toolkit' /tmp/help.txt; \
    printf '>tiny\nACGT\n' > /tmp/input.fa; \
    seqkit seq /tmp/input.fa > /tmp/output.fa; \
    cmp /tmp/input.fa /tmp/output.fa; \
    rm /tmp/version.txt /tmp/help.txt /tmp/input.fa /tmp/output.fa

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=seqkit
WORKDIR /tmp
