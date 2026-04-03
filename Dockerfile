# ─── Stage 1: Build Static Binary ───────────────────────────────
FROM golang:1.23-alpine AS builder

# Implement memory limits for CI environments to prevent OOM
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOMEMLIMIT=2048MiB \
    GOTOOLCHAIN=auto

RUN apk add --no-cache git ca-certificates tzdata && \
    update-ca-certificates

# Throttle parallelism (-p 2) and pin to a stable release tag
RUN go install -p 2 -v \
    -tags "with_quic,with_grpc,with_dhcp,with_wireguard,with_ech,with_utls,with_reality_server,with_acme,with_clash_api" \
    -ldflags="-s -w -buildid=" \
    github.com/sagernet/sing-box/cmd/sing-box@v1.8.11 
