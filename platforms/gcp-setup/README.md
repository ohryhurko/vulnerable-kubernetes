# GCP Vulnerable Kubernetes Cluster Setup

This directory contains scripts to deploy a vulnerable Kubernetes cluster on Google Cloud Platform (GCP) for security assessment purposes.

## Prerequisites

1. **GCP Account**: You need a Google Cloud Platform account with billing enabled
2. **gcloud CLI**: Install and configure the Google Cloud SDK
3. **kubectl**: Install the Kubernetes command-line tool
4. **Helm**: Will be installed automatically if not present

## Quick Setup

### 1. Configure Environment Variables

Set the following environment variables or modify the script defaults:

```bash
export PROJECT_ID="your-gcp-project-id"
export CLUSTER_NAME="vulnerable-cluster"
export REGION="us-central1"
export ZONE="us-central1-a"
export MACHINE_TYPE="e2-standard-4"
export NODE_COUNT="3"
export DISK_SIZE="50GB"
```

### 2. Deploy the Cluster

```bash
chmod +x setup-gcp-cluster.sh
bash setup-gcp-cluster.sh
```

### 3. Deploy Vulnerable Applications

After the cluster is created, deploy the vulnerable applications:

```bash
cd ../../
bash setup-vulnerable-cluster.sh
```

### 4. Access the Cluster

```bash
bash access-cluster.sh
```

## Configuration Options

- **PROJECT_ID**: Your GCP project ID
- **CLUSTER_NAME**: Name for the GKE cluster (default: vulnerable-cluster)
- **REGION**: GCP region (default: us-central1)
- **ZONE**: GCP zone (default: us-central1-a)
- **MACHINE_TYPE**: Node machine type (default: e2-standard-4)
- **NODE_COUNT**: Number of nodes (default: 3)
- **DISK_SIZE**: Node disk size (default: 50GB)

## Security Considerations

⚠️ **Important Security Notes:**

1. This cluster is intentionally vulnerable and should **NEVER** be used in production
2. The cluster is created with minimal security hardening for assessment purposes
3. Network policies are enabled but may contain misconfigurations
4. Service accounts are created with broad permissions for testing
5. Always clean up resources after assessment

## Cleanup

To remove all resources:

```bash
bash teardown-gcp-cluster.sh
```

This will:
- Delete the GKE cluster
- Remove the service account
- Clean up the service account key file
- List any remaining resources for manual cleanup

## Cost Management

- The cluster uses e2-standard-4 instances (4 vCPUs, 16GB RAM each)
- With 3 nodes, this creates a cluster with 12 vCPUs and 48GB RAM
- Estimated cost: ~$0.50-1.00 per hour depending on region
- **Always delete the cluster when finished to avoid charges**

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure your GCP account has the necessary permissions
2. **Quota Exceeded**: Check your GCP quotas for compute instances
3. **API Not Enabled**: The script enables required APIs automatically
4. **Cluster Creation Fails**: Check the GCP console for detailed error messages

### Getting Help

- Check GCP documentation: https://cloud.google.com/kubernetes-engine/docs
- Verify your project has billing enabled
- Ensure you have sufficient quotas for the selected machine type

## Next Steps

After setting up the cluster:

1. Deploy vulnerable applications using the main setup script
2. Access the cluster dashboard at http://127.0.0.1:1234
3. Begin your security assessment
4. Document all findings and remediation steps
5. Clean up all resources when finished
