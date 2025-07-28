# Main Terraform configuration for Jenkins on Docker Desktop Kubernetes
terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

# Configure the Kubernetes provider to use Docker Desktop's Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}

# Configure the Helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

# Create namespace for Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
    labels = {
      name = var.jenkins_namespace
      app  = "jenkins"
    }
  }
}

# Create persistent volume for Jenkins data
resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name = "jenkins-pv"
    labels = {
      app = "jenkins"
    }
  }
  spec {
    capacity = {
      storage = var.jenkins_storage_size
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/var/jenkins_home"
        type = "DirectoryOrCreate"
      }
    }
    storage_class_name = "hostpath"
  }
}

# Create persistent volume claim
resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins-pvc"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.jenkins_storage_size
      }
    }
    storage_class_name = "hostpath"
    volume_name        = kubernetes_persistent_volume.jenkins_pv.metadata[0].name
  }
}

# Create service account for Jenkins
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}

# Create cluster role for Jenkins
resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "jenkins"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "pods/log", "persistentvolumeclaims", "events"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Create cluster role binding
resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}

# Deploy Jenkins using Helm
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.jenkins_chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    templatefile("${path.module}/jenkins-values.yaml", {
      jenkins_admin_user     = var.jenkins_admin_user
      jenkins_admin_password = var.jenkins_admin_password
      jenkins_url           = var.jenkins_url
      storage_class         = "hostpath"
      storage_size          = var.jenkins_storage_size
    })
  ]

  depends_on = [
    kubernetes_persistent_volume.jenkins_pv,
    kubernetes_persistent_volume_claim.jenkins_pvc,
    kubernetes_service_account.jenkins,
    kubernetes_cluster_role_binding.jenkins
  ]
}
