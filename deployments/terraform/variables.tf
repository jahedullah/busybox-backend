variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy the GKE cluster"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "busybox-new-cluster"
}

variable "node_count" {
  description = "The number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "node_machine_type" {
  description = "The type of machine to use for the nodes"
  type        = string
  default     = "e2-medium"
}
