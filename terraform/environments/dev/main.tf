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


# -----------------------------------------------------------------------------
# TGW VPC Attachments (each compartment with interfacing subnets)
# -----------------------------------------------------------------------------
module "tgw_attachment" {
  source = "../../modules/tgw-attachment"

  for_each = {
    for k, v in module.vpc-compartment : k => v
    if length(v.interfacing_subnet_ids) > 0
  }

  name_prefix          = local.name_prefix
  compartment_name     = each.key
  transit_gateway_id   = module.transit_gateway.tgw_id
  vpc_id               = each.value.vpc_id
  subnet_ids           = each.value.interfacing_subnet_ids
  tags                 = {}
}


# -----------------------------------------------------------------------------
# TGW routes: from each compartment's private route tables to other VPC CIDRs via TGW
# -----------------------------------------------------------------------------
locals {
  tgw_route_entries = flatten([
    for comp_name, cidrs in var.tgw_routes : [
      for rt_name, rt_id in module.vpc-compartment[comp_name].private_route_table_ids : [
        for cidr in cidrs : {
          key             = "${comp_name}-${rt_name}-${replace(cidr, "/", "-")}"
          route_table_id  = rt_id
          cidr            = cidr
        }
      ]
    ]
  ])
}

resource "aws_route" "to_tgw" {
  for_each = { for r in local.tgw_route_entries : r.key => r }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = module.transit_gateway.tgw_id
}

# -----------------------------------------------------------------------------
# PrivateLink: Expose API (producer) - e.g. Workload Z exposes service for others
# -----------------------------------------------------------------------------
module "private_link_producer" {
  source = "../../modules/private-link-producer"

  for_each = { for p in var.private_link_producers : p.compartment => p }

  name_prefix         = local.name_prefix
  compartment_name    = each.value.compartment
  vpc_id              = module.vpc-compartment[each.value.compartment].vpc_id
  subnet_ids          = module.vpc-compartment[each.value.compartment].subnet_ids_by_type[each.value.subnet_type]
  service_suffix      = each.value.service_suffix
  allowed_principals  = each.value.allowed_principals
  tags                = {}
}