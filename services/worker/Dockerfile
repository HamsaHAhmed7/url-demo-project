FROM golang:1.21-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o worker .

FROM scratch
COPY --from=builder /src/worker /worker
ENTRYPOINT ["/worker"]
