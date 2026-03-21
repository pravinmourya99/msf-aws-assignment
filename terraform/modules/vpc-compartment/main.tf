locals {
  compartment_prefix = "${var.name_prefix}-${var.compartment_name}"
  public_subnets = [for s in var.subnets : s if s == "public"]
  private_subnets = [for s in var.subnets : s if s != "public"]
  has_public_subnets = length(local.public_subnets) > 0
  # NAT + EIP: one per "instance" (single key "single" or one per public subnet)
  nat_for_each = var.enable_nat_gateway && local.has_public_subnets ? (
    var.single_nat_gateway ? { "single" = local.public_subnets[0] } : { for s in local.public_subnets : s.name => s }
  ) : {}
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
# Public Route table association
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  for_each = {for s in local.public_subnets : s.name => s}

  route_table_id = aws_route_table.public[0].id
  subnet_id = aws_subnet.this[each.value.name].id
}

# -----------------------------------------------------------------------------
# Elastic IP for NAT gateway
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  for_each = local.nat_for_each

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.compartment_prefix}-nat-eip-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

# -----------------------------------------------------------------------------
# NAT Gateway (optional) - in first public subnet or one per AZ
# -----------------------------------------------------------------------------

resource "aws_nat_gateway" "this" {
  for_each = local.nat_for_each

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[each.value.name].id

  tags = merge(var.tags, {
    Name = "${local.compartment_prefix}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

# -----------------------------------------------------------------------------
# Private route table(s): one per private subnet (or shared)
# -----------------------------------------------------------------------------
resource "aws_route_table" "private" {
  for_each = { for s in local.private_subnets : s.name => s }

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway && local.has_public_subnets ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? "single" : local.public_subnets[0].name].id
    }
  }

  tags = merge(var.tags, {
    Name        = "${local.compartment_prefix}-rt-${each.value.type}"
    Type        = each.value.type
    Compartment = var.compartment_name
  })
}

# -----------------------------------------------------------------------------
# Private Route table association
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "private" {
  for_each = { for s in local.private_subnets : s.name => s }

  subnet_id      = aws_subnet.this[each.value.name].id
  route_table_id = aws_route_table.private[each.value.name].id
}

# -----------------------------------------------------------------------------
# Security groups for non public subnets
# -----------------------------------------------------------------------------
resource "aws_security_group" "by_type" {
  for_each = var.enable_security_groups ? { for t in toset([for s in var.subnets : s.type if s.type != "public"]) : t => t } : {}

  name        = "${local.compartment_prefix}-sg-${each.key}"
  description = "Security group for ${each.key} subnet in ${var.compartment_name}"
  vpc_id      = aws_vpc.this.id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${local.compartment_prefix}-sg-${each.key}"
    Type        = each.key
    Compartment = var.compartment_name
  })
}

# -----------------------------------------------------------------------------
# Security groups for public subnets
# -----------------------------------------------------------------------------
resource "aws_security_group" "public" {
  count = var.enable_security_groups && local.has_public_subnets ? 1 : 0

  name        = "${local.compartment_prefix}-sg-public"
  description = "Security group for public subnet in ${var.compartment_name}"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${local.compartment_prefix}-sg-public"
    Type        = "public"
    Compartment = var.compartment_name
  })
}
