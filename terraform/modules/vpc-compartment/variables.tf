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

variable "subnets" {
  description = "List of subnets to be created, type represents if the subnet is private , public or interfacing etc"
  type = list(object({
    name = string
    cidr = string
    availability_zone = string
    type = string
  }))
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway(s) in public subnet(s)"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs (cost-saving for dev)"
  type        = bool
  default     = false
}

variable "enable_security_groups" {
  description = "Whether to create security groups per subnet role"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}