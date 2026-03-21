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
  tags                    = {}

}