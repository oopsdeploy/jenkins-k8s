#!/bin/bash

# Script to destroy Jenkins deployment

set -e

echo "🗑️  Destroying Jenkins deployment"

# Confirm destruction
read -p "Are you sure you want to destroy the Jenkins deployment? This will delete all data! (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Destroying Terraform resources"
    terraform destroy -auto-approve
    
    echo ""
    echo "✅ Jenkins deployment destroyed!"
    echo "🧹 All resources have been cleaned up."
else
    echo "❌ Destruction cancelled."
fi
