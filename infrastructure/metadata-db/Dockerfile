FROM alpine:latest

RUN apk add --no-cache curl ca-certificates

WORKDIR /

# Copy the pre-built binary
COPY metadata-db /metadata-db
COPY metadata /metadata

EXPOSE 80

CMD ["/metadata-db"]
