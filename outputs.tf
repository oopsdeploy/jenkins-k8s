# Outputs for Jenkins deployment
output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_service_name" {
  description = "Jenkins service name"
  value       = "${helm_release.jenkins.name}"
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = var.jenkins_url
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = var.jenkins_admin_user
}

output "jenkins_port_forward_command" {
  description = "Command to port-forward to Jenkins service"
  value       = "kubectl port-forward -n ${kubernetes_namespace.jenkins.metadata[0].name} svc/${helm_release.jenkins.name} 8080:8080"
}

output "jenkins_admin_password_command" {
  description = "Command to get Jenkins admin password"
  value       = "kubectl get secret -n ${kubernetes_namespace.jenkins.metadata[0].name} ${helm_release.jenkins.name} -o jsonpath='{.data.jenkins-admin-password}' | base64 -d"
}
