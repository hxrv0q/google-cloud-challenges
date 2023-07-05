variable "region" {
  type        = string
  description = "The region to deploy the resources."
  default     = "us-east1"
}

variable "zone" {
  type        = string
  description = "The zone to deploy the resources."
  default     = "us-east1-d"
}

variable "project_id" {
  type        = string
  description = "The project id to deploy the resources."
}

variable "vpc_id" {
  type        = string
  description = "The name of the VPC."
}