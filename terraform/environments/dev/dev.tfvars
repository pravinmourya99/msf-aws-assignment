# -----------------------------------------------------------------------------
# Project & environment - change these to run in any AWS account/region
# -----------------------------------------------------------------------------

aws_region = "ap-southeast-1"
project = "msf"
environment = "dev"

compartments = {

  # Internet compartment

  internet = {
    vpc_cidr                 = "10.0.0.0/16"
    enable_internet_gateway  = true
    enable_nat_gateway       = true
    single_nat_gateway       = true
    enable_security_groups   = true
  }
}