FROM alpine:3.19

RUN apk add --no-cache ca-certificates wget unzip \
    && wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip Xray-linux-64.zip xray \
    && mv xray /usr/local/bin/xray \
    && chmod +x /usr/local/bin/xray \
    && rm Xray-linux-64.zip

COPY config.json /etc/xray/config.json

EXPOSE 8080

CMD ["xray", "run", "-config", "/etc/xray/config.json"]
