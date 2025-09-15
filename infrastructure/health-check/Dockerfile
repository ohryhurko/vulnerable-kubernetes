FROM golang:latest AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN go build -o health-check main.go

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /

COPY --from=builder /app/health-check /health-check
COPY views /views

EXPOSE 80

CMD ["/health-check"]
