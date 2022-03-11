## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_instance" "bastion_instance" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availablity_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "BastionVM"
  shape               = var.BastionShape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.BastionFlexShapeMemory
      ocpus         = var.BastionFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.OKE_MDS_bastion_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.BastionImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


