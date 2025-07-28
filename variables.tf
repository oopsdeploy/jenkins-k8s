# Variables for Jenkins Kubernetes deployment
variable "jenkins_namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_storage_size" {
  description = "Storage size for Jenkins persistent volume"
  type        = string
  default     = "20Gi"
}

variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  default     = "admin123!"
  sensitive   = true
}

variable "jenkins_url" {
  description = "Jenkins URL"
  type        = string
  default     = "http://localhost:8080"
}

variable "jenkins_chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "4.12.1"
}

variable "jenkins_cpu_request" {
  description = "CPU request for Jenkins pod"
  type        = string
  default     = "1000m"
}

variable "jenkins_memory_request" {
  description = "Memory request for Jenkins pod"
  type        = string
  default     = "2Gi"
}

variable "jenkins_cpu_limit" {
  description = "CPU limit for Jenkins pod"
  type        = string
  default     = "2000m"
}

variable "jenkins_memory_limit" {
  description = "Memory limit for Jenkins pod"
  type        = string
  default     = "4Gi"
}
