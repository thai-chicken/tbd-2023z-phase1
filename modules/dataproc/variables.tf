variable "project_name" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "GCP region"
}

variable "subnet" {
  type        = string
  description = "VPC subnet used for deployment"
}

variable "machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Machine type to use for both worker and master nodes"
}

variable "image_version" {
  type    = string
  default = "2.1.27-ubuntu20"
}

variable "num_workers" {
  type        = number
  default     = 2
  description = "Number of worker nodes"
}

variable "preemptible_num_workers" {
  description = "The number of preemptible worker nodes"
  type        = number
  default     = 0  # Set a default value or omit the default if you want to make it required
}