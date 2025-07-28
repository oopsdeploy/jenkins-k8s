# Jenkins on Docker Desktop Kubernetes

This project provides a Terraform configuration to deploy Jenkins on Docker Desktop's Kubernetes cluster.

## Prerequisites

1. **Docker Desktop**: Install and start Docker Desktop
2. **Kubernetes**: Enable Kubernetes in Docker Desktop settings
3. **Terraform**: Install Terraform (>= 1.0)
4. **kubectl**: Install kubectl CLI tool
5. **Helm**: The configuration uses Helm provider (automatically managed by Terraform)

## Quick Start

1. **Clone and navigate to the repository**:
   ```bash
   git clone <repository-url>
   cd jenkins-k8s
   ```

2. **Configure your deployment**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired settings
   ```

3. **Deploy Jenkins**:
   ```bash
   ./deploy.sh
   ```

4. **Access Jenkins**:
   ```bash
   # Port forward to access Jenkins
   kubectl port-forward -n jenkins svc/jenkins 8080:8080
   
   # Open browser to http://localhost:8080
   # Login with admin/<your-password>
   ```

## Configuration

### terraform.tfvars

Key configuration options in `terraform.tfvars`:

```hcl
jenkins_namespace = "jenkins"
jenkins_admin_user = "admin"
jenkins_admin_password = "your-secure-password"
jenkins_storage_size = "20Gi"
jenkins_cpu_request = "1000m"
jenkins_memory_request = "2Gi"
```

### Resource Requirements

Default resource allocation:
- **CPU Request**: 1000m (1 CPU core)
- **Memory Request**: 2Gi
- **CPU Limit**: 2000m (2 CPU cores)
- **Memory Limit**: 4Gi
- **Storage**: 20Gi persistent volume

## Architecture

This deployment includes:

- **Jenkins Controller**: Main Jenkins instance with web UI
- **Persistent Storage**: 20Gi volume for Jenkins data persistence
- **RBAC**: Proper Kubernetes permissions for Jenkins
- **Service Account**: Dedicated service account for Jenkins
- **Kubernetes Agents**: Dynamic agent provisioning in Kubernetes
- **Default Plugins**: Pre-installed essential plugins

## File Structure

```
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── jenkins-values.yaml        # Helm chart values template
├── terraform.tfvars.example   # Example configuration
├── deploy.sh                  # Deployment script
├── destroy.sh                 # Cleanup script
└── README.md                  # This file
```

## Useful Commands

### Deployment
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply deployment
terraform apply

# Get outputs
terraform output
```

### Access Jenkins
```bash
# Port forward to Jenkins
kubectl port-forward -n jenkins svc/jenkins 8080:8080

# Get admin password (if using auto-generated)
kubectl get secret -n jenkins jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d
```

### Kubernetes Operations
```bash
# Check Jenkins pods
kubectl get pods -n jenkins

# Check Jenkins service
kubectl get svc -n jenkins

# View Jenkins logs
kubectl logs -n jenkins deployment/jenkins

# Access Jenkins pod
kubectl exec -it -n jenkins deployment/jenkins -- /bin/bash
```

### Cleanup
```bash
# Destroy all resources
./destroy.sh

# Or manually with Terraform
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Docker Desktop not running**:
   - Ensure Docker Desktop is started and Kubernetes is enabled

2. **Context issues**:
   ```bash
   kubectl config use-context docker-desktop
   ```

3. **Port already in use**:
   ```bash
   # Find and kill process using port 8080
   lsof -ti:8080 | xargs kill -9
   ```

4. **Persistent volume issues**:
   ```bash
   # Delete and recreate PV if needed
   kubectl delete pv jenkins-pv
   terraform apply
   ```

### Logs and Debugging

```bash
# View Terraform state
terraform show

# Check Kubernetes events
kubectl get events -n jenkins --sort-by='.lastTimestamp'

# Debug pod issues
kubectl describe pod -n jenkins <pod-name>
```

## Customization

### Adding Plugins

Edit `jenkins-values.yaml` and add plugins to the `installPlugins` list:

```yaml
installPlugins:
  - kubernetes:latest
  - git:latest
  - your-plugin:version
```

### Resource Adjustments

Modify resource limits in `variables.tf` or `terraform.tfvars`:

```hcl
jenkins_cpu_limit = "4000m"      # 4 CPU cores
jenkins_memory_limit = "8Gi"     # 8GB RAM
jenkins_storage_size = "50Gi"    # 50GB storage
```

### Configuration as Code (JCasC)

Jenkins Configuration as Code is enabled. Add configurations in `jenkins-values.yaml` under `JCasC.configScripts`.

## Security Notes

- Change the default admin password in `terraform.tfvars`
- Consider using Kubernetes secrets for sensitive data
- Review RBAC permissions based on your security requirements
- Enable network policies if needed for your environment

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Kubernetes and Jenkins logs
3. Consult the Jenkins on Kubernetes documentation