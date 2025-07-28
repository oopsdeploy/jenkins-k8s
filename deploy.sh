#!/bin/bash

# Script to deploy Jenkins on Docker Desktop Kubernetes using Terraform

set -e

echo "🚀 Deploying Jenkins on Docker Desktop Kubernetes"

# Check if Docker Desktop is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker Desktop is not running. Please start Docker Desktop first."
    exit 1
fi

# Check if Kubernetes is enabled in Docker Desktop
if ! kubectl cluster-info --context docker-desktop >/dev/null 2>&1; then
    echo "❌ Kubernetes is not enabled in Docker Desktop. Please enable it in Docker Desktop settings."
    exit 1
fi

# Switch to docker-desktop context
echo "🔄 Switching to docker-desktop Kubernetes context"
kubectl config use-context docker-desktop

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit terraform.tfvars with your desired configuration before proceeding."
    echo "   Especially update the jenkins_admin_password value."
    read -p "Press Enter to continue after editing terraform.tfvars..."
fi

# Initialize Terraform
echo "🔧 Initializing Terraform"
terraform init

# Plan the deployment
echo "📋 Planning Terraform deployment"
terraform plan

# Apply the deployment
echo "🚀 Applying Terraform configuration"
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Jenkins deployment completed!"
    echo ""
    echo "🔗 To access Jenkins:"
    echo "1. Run the port-forward command:"
    echo "   kubectl port-forward -n jenkins svc/jenkins 8080:8080"
    echo ""
    echo "2. Open your browser to: http://localhost:8080"
    echo ""
    echo "3. Login with:"
    echo "   Username: admin"
    echo "   Password: (check terraform.tfvars or run the password command below)"
    echo ""
    echo "📋 Useful commands:"
    terraform output
else
    echo "❌ Deployment cancelled."
fi
