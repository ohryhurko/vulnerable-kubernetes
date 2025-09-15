#!/bin/bash

# GCP Vulnerable Kubernetes Cluster Teardown Script
# This script removes the GKE cluster and associated resources

set -e

# Configuration
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"
CLUSTER_NAME="${CLUSTER_NAME:-vulnerable-cluster}"
REGION="${REGION:-us-central1}"
ZONE="${ZONE:-us-central1-a}"

echo "🧹 Cleaning up vulnerable Kubernetes cluster on GCP"
echo "Project ID: $PROJECT_ID"
echo "Cluster Name: $CLUSTER_NAME"
echo "Zone: $ZONE"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first:"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Set the project
echo "📋 Setting GCP project..."
gcloud config set project $PROJECT_ID

# Delete the cluster
echo "🗑️ Deleting GKE cluster..."
gcloud container clusters delete $CLUSTER_NAME \
    --zone=$ZONE \
    --quiet

# Delete service account
echo "👤 Deleting service account..."
gcloud iam service-accounts delete vulnerable-cluster-sa@$PROJECT_ID.iam.gserviceaccount.com \
    --quiet || echo "Service account not found or already deleted"

# Remove service account key file
echo "🔐 Removing service account key file..."
rm -f vulnerable-cluster-key.json

# Clean up any remaining resources
echo "🧽 Cleaning up any remaining resources..."

# List any remaining clusters in the project
echo "📋 Remaining clusters in project:"
gcloud container clusters list --format="table(name,location,status)" || echo "No clusters found"

# List any remaining service accounts
echo "👤 Remaining service accounts:"
gcloud iam service-accounts list --filter="displayName:vulnerable-cluster" --format="table(email,displayName)" || echo "No vulnerable cluster service accounts found"

echo "✅ GCP cluster cleanup completed!"
echo ""
echo "⚠️  Please verify that all resources have been removed:"
echo "   - GKE cluster: $CLUSTER_NAME"
echo "   - Service account: vulnerable-cluster-sa@$PROJECT_ID.iam.gserviceaccount.com"
echo "   - Service account key: vulnerable-cluster-key.json"
echo ""
echo "💡 You can check your GCP console to ensure all resources are cleaned up."
