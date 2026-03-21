locals {
  compartment_prefix = "${var.name_prefix}-${var.compartment_name}"
  public_subnets = [for s in var.subnets : s if s == "public"]
  has_public_subnets = length(local.public_subnets) > 0
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

  count = var.enable_internet_gateway && local.has_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags,{
    Name = "${local.compartment_prefix}-igw"
  })
}
# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "this" {

  for_each = {for s in var.subnets : s.name => s }
  vpc_id = aws_vpc.this.id
  cidr_block = each.value.cidr
  availability_zone = each.value.availability_zone

  map_public_ip_on_launch = each.value.type == "public"

  tags = merge(var.tags,{
    Name = "${local.compartment_prefix}-subnet-${each.value.type}"
    Compartment = var.compartment_name
    Type = each.value.type
  })
}
# -----------------------------------------------------------------------------
# Route tables: public
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  count = local.has_public_subnets ? 1 : 0
  vpc_id         = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
  tags = merge(var.tags,{
    Name = "${local.compartment_prefix}-rt-public"
  })
}

# -----------------------------------------------------------------------------
# Route table association
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "public" {

  for_each = {for s in local.public_subnets : s.name => s}

  route_table_id = aws_route_table.public[0].id
  subnet_id = aws_subnet.this[each.value.name].id
}