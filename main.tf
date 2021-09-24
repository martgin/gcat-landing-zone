##############################################################################
# IBM Cloud Provider
##############################################################################

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

resource ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create VPC
##############################################################################

module multizone_vpc {
  source               = "./multizone-vpc"
  prefix               = var.prefix
  region               = var.region
  resource_group_id    = ibm_resource_group.resource_group.id
  classic_access       = var.classic_access
  subnets              = var.subnets
  use_public_gateways  = var.use_public_gateways
  acl_rules            = var.acl_rules
  security_group_rules = var.security_group_rules
}

##############################################################################


##############################################################################
# Access Groups
##############################################################################

module access_groups {
  source        = "./iam"
  access_groups = var.access_groups

  depends_on = [ ibm_resource_group.resource_group ]
}

##############################################################################