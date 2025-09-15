#!/bin/bash

# Build Images Script
# This script builds all Docker images locally for the vulnerable cluster

set -e

echo "🔨 Building all Docker images for vulnerable cluster"
echo "=================================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build images for each component
echo "📦 Building infrastructure images..."

cd infrastructure

# List of components to build
components=(
    "batch-check"
    "build-code" 
    "cache-store"
    "health-check"
    "hidden-in-layers"
    "hunger-check"
    "info-app"
    "internal-api"
    "metadata-db"
    "poor-registry"
    "system-monitor"
    "users-repo"
    "helm-tiller"
    "goat-home"
)

# Build each component
for component in "${components[@]}"; do
    if [ -d "$component" ]; then
        echo "🔨 Building $component..."
        cd "$component"
        
        # Use different image names based on component
        case $component in
            "goat-home")
                docker build -t cluster-dashboard:latest .
                ;;
            *)
                docker build -t "$component:latest" .
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully built $component"
        else
            echo "❌ Failed to build $component"
            exit 1
        fi
        
        cd ..
    else
        echo "⚠️  Directory $component not found, skipping..."
    fi
done

cd ..

echo ""
echo "🎉 All images built successfully!"
echo ""
echo "📋 Built images:"
docker images | grep -E "(batch-check|build-code|cache-store|health-check|hidden-in-layers|hunger-check|info-app|internal-api|metadata-db|poor-registry|system-monitor|users-repo|helm-tiller|cluster-dashboard)" | head -20

echo ""
echo "🚀 Next steps:"
echo "1. Deploy the cluster: bash setup-vulnerable-cluster.sh"
echo "2. Access the cluster: bash access-cluster.sh"
echo "3. Open dashboard: http://127.0.0.1:1234"
