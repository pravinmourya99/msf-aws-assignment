locals {
  compartment_prefix = "${var.name_prefix}-${var.compartment_name}"
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.tags,{
    Name = "${local.compartment_prefix}-vpc"
    Compartment = var.compartment_name
  })
}

# -----------------------------------------------------------------------------
# Internet Gateway (optional)
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "this" {

  count = var.enable_internet_gateway ? 1 : 0 //todo enhance condition to include public subnets as well

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags,{
    Name = "${local.compartment_prefix}-igw"
  })
}