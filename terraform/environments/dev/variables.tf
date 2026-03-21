#----------------------------------------------------------------------
# Variable which defines the aws region for the project
#----------------------------------------------------------------------
variable "aws_region" {
  description = "Defines the aws region"
  type = string
}

#----------------------------------------------------------------------
# Variable which defines the project name
#----------------------------------------------------------------------
variable "project" {
  description = "Defines the project prefix name e.g msf or service sg etc"
  type = string
}

#----------------------------------------------------------------------
# Variable which defines environment
#----------------------------------------------------------------------
variable "environment" {
  description = "Defines the environment e.g dev, uat, prod"
  type = string
}

# -----------------------------------------------------------------------------
# Extra tags
# -----------------------------------------------------------------------------
variable "extra_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Compartments
# -----------------------------------------------------------------------------
variable "compartments" {
  description = "Map of compartment name to VPC configuration"
  type = map(object({
    vpc_cidr                 = string
    enable_internet_gateway  = optional(bool, false)
  }))
}