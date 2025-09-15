FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /

# Copy the pre-built binary (we'll build it locally)
COPY health-check /health-check
COPY views /views

EXPOSE 80

CMD ["/health-check"]
