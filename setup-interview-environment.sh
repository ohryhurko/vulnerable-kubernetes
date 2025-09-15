#!/bin/bash

# Interview Environment Setup Script
# This script prepares a clean, isolated environment for security assessment interviews

set -e

echo "🎯 Setting up interview environment for Offensive Security Engineer assessment"
echo "=================================================================="

# Configuration
INTERVIEW_ID="${INTERVIEW_ID:-$(date +%Y%m%d-%H%M%S)}"
CANDIDATE_NAME="${CANDIDATE_NAME:-candidate}"
CLUSTER_NAME="interview-cluster-${INTERVIEW_ID}"

echo "Interview ID: $INTERVIEW_ID"
echo "Candidate: $CANDIDATE_NAME"
echo "Cluster Name: $CLUSTER_NAME"
echo ""

# Create isolated namespace for the interview
echo "📁 Creating isolated namespace for interview..."
kubectl create namespace interview-${INTERVIEW_ID} || echo "Namespace may already exist"

# Set context to the interview namespace
kubectl config set-context --current --namespace=interview-${INTERVIEW_ID}

# Deploy vulnerable applications in isolated namespace
echo "🚀 Deploying vulnerable applications in isolated environment..."

# Create modified deployments for the interview namespace
mkdir -p /tmp/interview-${INTERVIEW_ID}

# Copy and modify deployment files
cp scenarios/batch-check/job.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/build-code/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/cache-store/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/health-check/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/hunger-check/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/internal-proxy/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/kubernetes-goat-home/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/poor-registry/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/system-monitor/deployment.yaml /tmp/interview-${INTERVIEW_ID}/
cp scenarios/hidden-in-layers/deployment.yaml /tmp/interview-${INTERVIEW_ID}/

# Modify namespace in all deployment files
for file in /tmp/interview-${INTERVIEW_ID}/*.yaml; do
    sed -i.bak "s/namespace: default/namespace: interview-${INTERVIEW_ID}/g" "$file"
    sed -i.bak "s/namespace: big-monolith/namespace: interview-${INTERVIEW_ID}/g" "$file"
    rm "$file.bak"
done

# Apply deployments to the interview namespace
kubectl apply -f /tmp/interview-${INTERVIEW_ID}/

# Deploy insecure RBAC in the interview namespace
echo "🔐 Setting up insecure RBAC for assessment..."
kubectl apply -f scenarios/insecure-rbac/setup.yaml

# Deploy metadata-db helm chart
echo "📊 Deploying metadata database..."
helm install metadata-db-${INTERVIEW_ID} scenarios/metadata-db/ --namespace interview-${INTERVIEW_ID}

# Create interview-specific access script
echo "🔧 Creating interview-specific access script..."
cat > access-interview-${INTERVIEW_ID}.sh << EOF
#!/bin/bash

# Interview Environment Access Script
# Interview ID: ${INTERVIEW_ID}
# Candidate: ${CANDIDATE_NAME}

echo "🎯 Accessing interview environment for ${CANDIDATE_NAME}"
echo "Interview ID: ${INTERVIEW_ID}"
echo "Namespace: interview-${INTERVIEW_ID}"
echo ""

# Set namespace context
kubectl config set-context --current --namespace=interview-${INTERVIEW_ID}

# Create port forwards for interview environment
echo "Creating port forwards for interview environment..."

# Build Code Service (Port 1230)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=build-code" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1230:3000 > /dev/null 2>&1 &

# Health Check Service (Port 1231)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=health-check" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1231:80 > /dev/null 2>&1 &

# Internal Proxy Service (Port 1232)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=internal-proxy" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1232:3000 > /dev/null 2>&1 &

# System Monitor Service (Port 1233)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=system-monitor" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1233:8080 > /dev/null 2>&1 &

# Cluster Dashboard (Port 1234)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=kubernetes-goat-home" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1234:80 > /dev/null 2>&1 &

# Poor Registry Service (Port 1235)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=poor-registry" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1235:5000 > /dev/null 2>&1 &

# Hunger Check Service (Port 1236)
export POD_NAME=\$(kubectl get pods --namespace interview-${INTERVIEW_ID} -l "app=hunger-check" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME --address 0.0.0.0 1236:8080 > /dev/null 2>&1 &

echo "✅ Interview environment is ready!"
echo "Dashboard: http://127.0.0.1:1234"
echo "Services available on ports 1230-1236"
echo ""
echo "To stop port forwarding, run: pkill -f 'kubectl port-forward'"
EOF

chmod +x access-interview-${INTERVIEW_ID}.sh

# Create interview cleanup script
echo "🧹 Creating interview cleanup script..."
cat > teardown-interview-${INTERVIEW_ID}.sh << EOF
#!/bin/bash

# Interview Environment Cleanup Script
# Interview ID: ${INTERVIEW_ID}

echo "🧹 Cleaning up interview environment: ${INTERVIEW_ID}"

# Delete all resources in the interview namespace
kubectl delete namespace interview-${INTERVIEW_ID} --ignore-not-found=true

# Remove interview-specific files
rm -f access-interview-${INTERVIEW_ID}.sh
rm -f teardown-interview-${INTERVIEW_ID}.sh
rm -rf /tmp/interview-${INTERVIEW_ID}

echo "✅ Interview environment cleanup completed!"
EOF

chmod +x teardown-interview-${INTERVIEW_ID}.sh

# Wait for pods to be ready
echo "⏳ Waiting for applications to be ready..."
kubectl wait --for=condition=ready pod -l app=kubernetes-goat-home --timeout=300s --namespace=interview-${INTERVIEW_ID} || echo "Some pods may still be starting"

# Display interview information
echo ""
echo "🎉 Interview environment setup completed!"
echo "=================================================================="
echo "Interview ID: ${INTERVIEW_ID}"
echo "Candidate: ${CANDIDATE_NAME}"
echo "Namespace: interview-${INTERVIEW_ID}"
echo ""
echo "📋 Next steps:"
echo "1. Access the environment:"
echo "   bash access-interview-${INTERVIEW_ID}.sh"
echo ""
echo "2. Open the dashboard:"
echo "   http://127.0.0.1:1234"
echo ""
echo "3. Clean up after interview:"
echo "   bash teardown-interview-${INTERVIEW_ID}.sh"
echo ""
echo "🔍 Assessment Guidelines:"
echo "- Document all security findings"
echo "- Provide remediation recommendations"
echo "- Focus on real-world attack scenarios"
echo "- Consider impact and exploitability"
echo ""
echo "⚠️  This environment is isolated and contains intentional vulnerabilities"
echo "   for educational and assessment purposes only."
