#!/bin/bash

# Build Go Binaries Script
# This script builds Go binaries locally to avoid network issues in Docker

set -e

echo "🔨 Building Go binaries locally"
echo "==============================="

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go first."
    echo "   Download from: https://golang.org/dl/"
    exit 1
fi

# Build health-check binary
echo "🔨 Building health-check binary..."
cd infrastructure/health-check

# Download dependencies
go mod download

# Build the binary
go build -o health-check main.go

if [ $? -eq 0 ]; then
    echo "✅ Successfully built health-check binary"
else
    echo "❌ Failed to build health-check binary"
    exit 1
fi

cd ../..

# Build metadata-db binary
echo "🔨 Building metadata-db binary..."
cd infrastructure/metadata-db

# Download dependencies
go mod download

# Build the binary
go build -o metadata-db main.go

if [ $? -eq 0 ]; then
    echo "✅ Successfully built metadata-db binary"
else
    echo "❌ Failed to build metadata-db binary"
    exit 1
fi

cd ../..

echo ""
echo "🎉 All Go binaries built successfully!"
echo ""
echo "📋 Built binaries:"
ls -la infrastructure/health-check/health-check
ls -la infrastructure/metadata-db/metadata-db

echo ""
echo "🚀 Next steps:"
echo "1. Build Docker images: bash build-essential-images.sh"
echo "2. Deploy the cluster: bash setup-vulnerable-cluster.sh"
echo "3. Access the cluster: bash access-cluster.sh"
