FROM golang:1.21-alpine AS builder
WORKDIR /src
RUN adduser -D -u 1001 appuser
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o worker .

FROM scratch
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /src/worker /worker
USER appuser
ENTRYPOINT ["/worker"]
