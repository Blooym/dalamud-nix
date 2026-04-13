ARG RUNTIME_IMAGE

FROM alpine AS builder
WORKDIR /build
ARG DALAMUD_URL
RUN apk add --no-cache wget unzip \
    && wget -O dalamud.zip "${DALAMUD_URL}" \
    && unzip dalamud.zip -d dalamud

FROM ${RUNTIME_IMAGE}
ENV DALAMUD_HOME=/usr/lib/dalamud
COPY --from=builder /build/dalamud/ ${DALAMUD_HOME}/