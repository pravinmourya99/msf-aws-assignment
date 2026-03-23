# -----------------------------------------------------------------------------
# VPC Compartments
# -----------------------------------------------------------------------------

module "vpc-compartment" {

  source = "../../modules/vpc-compartment"

  for_each = var.compartments

  name_prefix             = local.name_prefix
  compartment_name        = each.key
  vpc_cidr                = each.value.vpc_cidr
  subnets                 = each.value.subnets
  enable_internet_gateway = each.value.enable_internet_gateway
  enable_nat_gateway      = each.value.enable_nat_gateway
  single_nat_gateway      = each.value.single_nat_gateway
  enable_security_groups    = each.value.enable_security_groups
  tags                    = {}

}

# -----------------------------------------------------------------------------
# Transit Gateway (central hub per diagram)
# -----------------------------------------------------------------------------
module "transit_gateway" {
  source = "../../modules/transit-gateway"

  name_prefix                      = local.name_prefix
  description                      = "Central hub for inter-VPC routing (Internet, GEN, Workloads)"
  default_route_table_association  = var.transit_gateway_default_route_table_association
  default_route_table_propagation  = var.transit_gateway_default_route_table_propagation
  tags                             = {}
}
