# ═══════════════════════════════════════════════════════════════
#  SING-BOX │ SCRATCH-BASED │ CLOUD RUN OPTIMIZED
#  SS + HTTPUpgrade + TLS  │  Zero OS bloat │ 500Mbps+
# ═══════════════════════════════════════════════════════════════

# ─── Stage 1: Build Static Binary ───────────────────────────────
FROM golang:1.23-alpine AS builder

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOTOOLCHAIN=auto

RUN apk add --no-cache git ca-certificates tzdata && \
    update-ca-certificates

RUN go install -v \
    -tags "with_quic,with_grpc,with_dhcp,with_wireguard,with_ech,with_utls,with_reality_server,with_acme,with_clash_api" \
    -ldflags="-s -w -buildid=" \
    github.com/sagernet/sing-box/cmd/sing-box@latest

# ─── Stage 2: Scratch (Zero OS) ─────────────────────────────────
FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/share/zoneinfo                  /usr/share/zoneinfo
COPY --from=builder /go/bin/sing-box                     /sing-box
COPY config.json                                         /etc/sing-box/config.json

EXPOSE 8080

ENTRYPOINT ["/sing-box", "run", "-c", "/etc/sing-box/config.json"]
