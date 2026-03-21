variable "name_prefix" {
  description = "Name prefix for the resource"
  type        = string
}

variable "compartment_name" {
  description = "Name of the compartment"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "enable_internet_gateway" {
  description = "Variable which defines whether to enable internet gateway or not"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}