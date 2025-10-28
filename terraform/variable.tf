variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "ku-gcp-hackathon"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "lost-and-found-cluster"  # Unique name to avoid conflicts
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "node_disk_size" {
  description = "Disk size for GKE nodes in GB"
  type        = number
  default     = 50
}