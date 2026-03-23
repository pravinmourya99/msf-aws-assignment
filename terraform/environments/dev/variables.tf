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
  type        = string
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
    enable_nat_gateway       = optional(bool, false)
    single_nat_gateway       = optional(bool, false)
    enable_security_groups   = optional(bool, true)
    subnets                  = list(object({
      name              = string
      cidr              = string
      availability_zone = string
      type              = string
    }))
  }))
}

# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------
variable "transit_gateway_default_route_table_association" {
  description = "TGW default route table association (enable/disable)"
  type        = string
  default     = "disable"
}

variable "transit_gateway_default_route_table_propagation" {
  description = "TGW default route table propagation (enable/disable)"
  type        = string
  default     = "disable"
}


# -----------------------------------------------------------------------------
# TGW routing: which CIDRs to route via TGW from each compartment
# -----------------------------------------------------------------------------
variable "tgw_routes" {
  description = "Map of compartment name to list of CIDR blocks to route via TGW (e.g. other compartment VPC CIDRs)"
  type        = map(list(string))
  default     = {}
}

variable "private_link_producers" {
  description = "List of producer configs: { compartment, subnet_type, service_suffix, allowed_principals }"
  type = list(object({
    compartment        = string
    subnet_type        = string   # e.g. compute or interfacing
    service_suffix     = optional(string, "api")
    allowed_principals = optional(list(string), ["*"])
  }))
  default = []
}