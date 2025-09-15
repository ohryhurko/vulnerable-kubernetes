#!/bin/bash

# Build All Script
# This script builds Go binaries first, then Docker images

set -e

echo "🚀 Building all components for vulnerable cluster"
echo "================================================"

# Step 1: Build Go binaries
echo "📦 Step 1: Building Go binaries..."
chmod +x build-go-binaries.sh
bash build-go-binaries.sh

# Step 2: Build Docker images
echo "📦 Step 2: Building Docker images..."
chmod +x build-essential-images.sh
bash build-essential-images.sh

echo ""
echo "🎉 All components built successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Deploy the cluster: bash setup-vulnerable-cluster.sh"
echo "2. Access the cluster: bash access-cluster.sh"
echo "3. Open dashboard: http://127.0.0.1:1234"
