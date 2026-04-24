FROM golang:1.21-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o dashboard .

FROM alpine:3.18
RUN apk add --no-cache ca-certificates curl
COPY --from=builder /src/dashboard /dashboard
EXPOSE 8081
HEALTHCHECK --interval=10s --timeout=3s CMD curl -f http://localhost:8081/healthz || exit 1
CMD ["/dashboard"]
