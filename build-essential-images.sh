#!/bin/bash

# Build Essential Images Script
# This script builds only the most essential Docker images to save space

set -e

echo "🔨 Building essential Docker images for vulnerable cluster"
echo "========================================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Clean up Docker to free space
echo "🧹 Cleaning up Docker to free space..."
docker system prune -f
docker builder prune -f

# Build only essential images
echo "📦 Building essential infrastructure images..."

cd infrastructure

# Essential components only
essential_components=(
    "build-code"
    "health-check" 
    "system-monitor"
    "kubernetes-goat-home"
)

# Build each essential component
for component in "${essential_components[@]}"; do
    if [ -d "$component" ]; then
        echo "🔨 Building $component..."
        cd "$component"
        
        # Use different image names based on component
        case $component in
            "kubernetes-goat-home")
                docker build -t cluster-dashboard:latest .
                ;;
            *)
                docker build -t "$component:latest" .
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully built $component"
            # Clean up build cache after each successful build
            docker builder prune -f > /dev/null 2>&1
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
echo "🎉 Essential images built successfully!"
echo ""
echo "📋 Built images:"
docker images | grep -E "(build-code|health-check|system-monitor|cluster-dashboard)" | head -10

echo ""
echo "🚀 Next steps:"
echo "1. Deploy the cluster: bash setup-vulnerable-cluster.sh"
echo "2. Access the cluster: bash access-cluster.sh"
echo "3. Open dashboard: http://127.0.0.1:1234"
echo ""
echo "💡 Note: Only essential services are running. For full functionality,"
echo "   run 'bash build-images.sh' to build all components."
