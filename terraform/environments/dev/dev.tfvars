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
    subnets = [
      { name = "public-1", cidr = "10.0.1.0/24", availability_zone = "ap-southeast-1a", type = "public" },
      { name = "public-2", cidr = "10.0.2.0/24", availability_zone = "ap-southeast-1b", type = "public" },
      { name = "firewall-1", cidr = "10.0.10.0/24", availability_zone = "ap-southeast-1a", type = "firewall" },
      { name = "firewall-2", cidr = "10.0.11.0/24", availability_zone = "ap-southeast-1b", type = "firewall" },
      { name = "interfacing-1", cidr = "10.0.20.0/24", availability_zone = "ap-southeast-1a", type = "interfacing" },
      { name = "interfacing-2", cidr = "10.0.21.0/24", availability_zone = "ap-southeast-1b", type = "interfacing" },
    ]
  }
}