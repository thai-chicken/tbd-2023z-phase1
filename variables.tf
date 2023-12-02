variable "project_name" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "GCP region"
}

variable "ai_notebook_instance_owner" {
  type        = string
  description = "Vertex AI workbench owner"
}

variable "dataproc_num_workers" {
  type        = number
  default     = 2
  description = "Number of dataproc workers"
}

variable "preemptible_num_workers" {
  type        = number
  default     = 0
  description = "Number of preemptible dataproc workers"
}

variable "dataproc_worker_machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Dataproc worker machine type"
}

variable "vertex_machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Vertex AI machine type"
}