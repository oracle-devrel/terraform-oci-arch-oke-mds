## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#module "set_tags" {
#  source        = "github.com/oracle-devrel/terraform-oci-arch-std-tags"
#  tag_namespace = "terraform-oci-arch-oke-mds"
#}

module "create_policies" {
  source                        = "github.com/oracle-devrel/terraform-oci-arch-policies"
  activate_policies_for_service = ["OKE"]
  tenancy_ocid                  = var.tenancy_ocid
  policy_compartment_ocid       = var.compartment_ocid
  random_id                     = module.set_tags.random_id.tag.hex
  region_name                   = var.region.name
  defined_tags                  = module.set_tags.defined_tags
}
