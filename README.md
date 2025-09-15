# Vulnerable Kubernetes Cluster

A deliberately vulnerable Kubernetes cluster environment designed for security assessment and penetration testing exercises.

## ⚠️ Important Notice

This cluster contains intentionally vulnerable applications, configurations, and security misconfigurations for educational and testing purposes. **DO NOT** deploy this in production environments or alongside any production infrastructure.

## 🚀 Quick Setup

### Prerequisites

- Admin access to a Kubernetes cluster
- `kubectl` installed and configured
- `helm` package manager installed

### Deployment

1. Clone this repository:
```bash
git clone <your-repo-url>
cd vulnerable-kubernetes
```

2. Deploy the vulnerable cluster:
```bash
chmod +x setup-vulnerable-cluster.sh
bash setup-vulnerable-cluster.sh
```

3. Verify deployment:
```bash
kubectl get pods --all-namespaces
```

4. Access the cluster:
```bash
bash access-cluster.sh
```

5. Navigate to `http://127.0.0.1:1234`

## 🎯 Security Scenarios

This cluster contains various security vulnerabilities and misconfigurations including:

- Sensitive data exposure
- Container escape vulnerabilities
- SSRF attacks
- Privilege escalation
- Network security issues
- RBAC misconfigurations
- And many more...

## 📋 Assessment Guidelines

- Document all findings
- Provide remediation recommendations
- Focus on real-world attack scenarios
- Consider impact and exploitability

## 🔧 Cleanup

To remove all resources:
```bash
bash teardown-cluster.sh
```

## 📝 License

MIT License - Use responsibly and only in authorized environments.