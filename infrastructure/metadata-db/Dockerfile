FROM golang:alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY main.go ./
COPY metadata ./metadata/
RUN go build -o metadata-db main.go

FROM alpine:latest

RUN apk add --no-cache curl ca-certificates

WORKDIR /

COPY --from=builder /app/metadata-db /metadata-db
COPY --from=builder /app/metadata /metadata

EXPOSE 80

CMD ["/metadata-db"]
