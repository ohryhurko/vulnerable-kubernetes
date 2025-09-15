#!/bin/bash

# GCP Vulnerable Kubernetes Cluster Setup Script
# This script creates an isolated GKE cluster for security assessment

set -e

# Configuration
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"
CLUSTER_NAME="${CLUSTER_NAME:-vulnerable-cluster}"
REGION="${REGION:-us-central1}"
ZONE="${ZONE:-us-central1-a}"
MACHINE_TYPE="${MACHINE_TYPE:-e2-standard-4}"
NODE_COUNT="${NODE_COUNT:-3}"
DISK_SIZE="${DISK_SIZE:-50GB}"

echo "🚀 Setting up vulnerable Kubernetes cluster on GCP"
echo "Project ID: $PROJECT_ID"
echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Zone: $ZONE"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first:"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first:"
    echo "https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    exit 1
fi

# Set the project
echo "📋 Setting GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required GCP APIs..."
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

# Create GKE cluster
echo "🏗️ Creating GKE cluster..."
gcloud container clusters create $CLUSTER_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --num-nodes=$NODE_COUNT \
    --disk-size=$DISK_SIZE \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --network="default" \
    --subnetwork="default" \
    --enable-network-policy \
    --no-enable-basic-auth \
    --issue-client-certificate \
    --enable-stackdriver-kubernetes

# Get cluster credentials
echo "🔑 Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE

# Verify cluster is running
echo "✅ Verifying cluster status..."
kubectl cluster-info
kubectl get nodes

# Install Helm
echo "📦 Installing Helm..."
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Create a service account for the cluster
echo "👤 Creating service account for cluster access..."
gcloud iam service-accounts create vulnerable-cluster-sa \
    --display-name="Vulnerable Cluster Service Account" \
    --description="Service account for vulnerable cluster access"

# Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:vulnerable-cluster-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/container.developer"

# Create and download service account key
echo "🔐 Creating service account key..."
gcloud iam service-accounts keys create vulnerable-cluster-key.json \
    --iam-account=vulnerable-cluster-sa@$PROJECT_ID.iam.gserviceaccount.com

echo "🎉 GCP cluster setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Deploy vulnerable applications:"
echo "   cd ../.. && bash setup-vulnerable-cluster.sh"
echo ""
echo "2. Access the cluster:"
echo "   bash access-cluster.sh"
echo ""
echo "3. Clean up when done:"
echo "   bash teardown-cluster.sh"
echo "   gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE --quiet"
echo ""
echo "⚠️  Remember to delete the cluster and service account when finished!"
echo "   Service account key: vulnerable-cluster-key.json"
echo "   Service account: vulnerable-cluster-sa@$PROJECT_ID.iam.gserviceaccount.com"
