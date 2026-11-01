FROM python:3.15.1-slim

ENV PYTHONUNBUFFERED=1 \
    CURL_CHROME116_PATH=/usr/local/bin/curl_chrome116 \
    CURL_PATH=/usr/bin/curl \
    CURL_IMPERSONATE_VERSION=v0.6.1

WORKDIR /app

ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates tar \
    && rm -rf /var/lib/apt/lists/*

RUN build_arch="${TARGETARCH:-$(uname -m)}" \
    && case "${build_arch}" in \
        amd64|x86_64) curl_arch="x86_64-linux-gnu" ;; \
        arm64|aarch64) curl_arch="aarch64-linux-gnu" ;; \
        arm|armv7l) curl_arch="arm-linux-gnueabihf" ;; \
        *) echo "Unsupported TARGETARCH: ${build_arch}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/lwthiker/curl-impersonate/releases/download/${CURL_IMPERSONATE_VERSION}/curl-impersonate-${CURL_IMPERSONATE_VERSION}.${curl_arch}.tar.gz" \
        | tar -xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/curl-impersonate-chrome /usr/local/bin/curl_chrome*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY truth-social-monitor prompt ./
RUN chmod +x /app/truth-social-monitor \
    && mkdir -p /app/cache

ENTRYPOINT ["/app/truth-social-monitor"]
CMD ["-d", "60"]
