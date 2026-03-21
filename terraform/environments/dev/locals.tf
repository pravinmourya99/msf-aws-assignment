locals {
  common_tags = merge(var.extra_tags,{
    Project = var.project
    Environment = var.environment
    ManagedBy = "Terraform"
  })
}
