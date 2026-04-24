FROM golang:1.23-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o dashboard .

FROM alpine:3.18
RUN apk add --no-cache ca-certificates curl \
    && adduser -D -u 1001 appuser
COPY --from=builder /src/dashboard /dashboard
USER appuser
EXPOSE 8081
HEALTHCHECK --interval=10s --timeout=3s CMD curl -f http://localhost:8081/healthz || exit 1
CMD ["/dashboard"]
