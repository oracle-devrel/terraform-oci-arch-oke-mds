## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "OKE_MDS_vcn" {
  cidr_block     = var.VCN-CIDR
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_vcn"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_drg" "OKE_MDS_drg" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_drg"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_drg_attachment" "oac_heatwave_drg_vcn_attachment" {
  drg_id       = oci_core_drg.OKE_MDS_drg.id
  vcn_id       = oci_core_vcn.OKE_MDS_vcn.id
  display_name = "OKE_MDS_drg_vcn_attachment"
}


resource "oci_core_service_gateway" "OKE_MDS_sg" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_sg"
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServices.services[0], "id")
  }
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_internet_gateway" "OKE_MDS_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_igw"
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "OKE_MDS_rt_via_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  display_name   = "OKE_MDS_rt_via_igw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.OKE_MDS_igw.id
  }
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "OKE_MDS_natgw" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_natgw"
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "OKE_MDS_rt_via_natgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  display_name   = "OKE_MDS_rt_via_natgw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.OKE_MDS_natgw.id
  }

  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "OKE_MDS_api_endpoint_subnet_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_api_endpoint_subnet_sec_list"
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  # egress_security_rules

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.OKE_NodePool_Subnet-CIDR
  }

  egress_security_rules {
    protocol         = 1
    destination_type = "CIDR_BLOCK"
    destination      = var.OKE_NodePool_Subnet-CIDR

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.OKE_NodePool_Subnet-CIDR

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.OKE_NodePool_Subnet-CIDR

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = 1
    source   = var.OKE_NodePool_Subnet-CIDR

    icmp_options {
      type = 3
      code = 4
    }
  }

}

resource "oci_core_security_list" "OKE_MDS_nodepool_subnet_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_nodepool_subnet_sec_list"
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  egress_security_rules {
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = var.OKE_NodePool_Subnet-CIDR
  }

  egress_security_rules {
    protocol    = 1
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.OKE_API_EndPoint_Subnet-CIDR

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.OKE_API_EndPoint_Subnet-CIDR

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "All"
    source   = var.OKE_NodePool_Subnet-CIDR
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.OKE_API_EndPoint_Subnet-CIDR
  }

  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }
}


resource "oci_core_security_list" "OKE_MDS_mds_subnet_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_MDS_mds_subnet_sec_list"
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "1"
    source   = var.VCN-CIDR
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.VCN-CIDR
  }
  ingress_security_rules {
    tcp_options {
      max = 3306
      min = 3306
    }
    protocol = "6"
    source   = var.VCN-CIDR
  }
  ingress_security_rules {
    tcp_options {
      max = 33061
      min = 33060
    }
    protocol = "6"
    source   = var.VCN-CIDR
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR

    tcp_options {
      min = 2048
      max = 2050
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR

    tcp_options {
      source_port_range {
        min = 2048
        max = 2050
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR

    tcp_options {
      min = 111
      max = 111
    }
  }

  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

}

resource "oci_core_subnet" "OKE_MDS_bastion_subnet" {
  cidr_block     = var.Bastion_Subnet-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  display_name   = "OKE_MDS_bastion_subnet"
  security_list_ids = [oci_core_vcn.OKE_MDS_vcn.default_security_list_id]
  route_table_id    = oci_core_route_table.OKE_MDS_rt_via_igw.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "OKE_MDS_lb_subnet" {
  cidr_block     = var.OKE_LB_Subnet-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.OKE_MDS_vcn.id
  display_name   = "OKE_MDS_lb_subnet"
  prohibit_public_ip_on_vnic = true
  security_list_ids = [oci_core_vcn.OKE_MDS_vcn.default_security_list_id]
  route_table_id    = oci_core_route_table.OKE_MDS_rt_via_igw.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "OKE_MDS_api_endpoint_subnet" {
  cidr_block        = var.OKE_API_EndPoint_Subnet-CIDR
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.OKE_MDS_vcn.id
  display_name      = "OKE_MDS_api_endpoint_subnet"
  prohibit_public_ip_on_vnic = true
  security_list_ids = [oci_core_vcn.OKE_MDS_vcn.default_security_list_id, oci_core_security_list.OKE_MDS_api_endpoint_subnet_sec_list.id]
  route_table_id    = oci_core_route_table.OKE_MDS_rt_via_igw.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "OKE_MDS_nodepool_subnet" {
  cidr_block        = var.OKE_NodePool_Subnet-CIDR
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.OKE_MDS_vcn.id
  display_name      = "OKE_MDS_nodepool_subnet"
  prohibit_public_ip_on_vnic = true
  security_list_ids = [oci_core_vcn.OKE_MDS_vcn.default_security_list_id, oci_core_security_list.OKE_MDS_nodepool_subnet_sec_list.id]
  route_table_id    = oci_core_route_table.OKE_MDS_rt_via_natgw.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "OKE_MDS_mds_subnet" {
  cidr_block        = var.MDS_Subnet-CIDR
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.OKE_MDS_vcn.id
  display_name      = "OKE_MDS_mds_subnet"
  prohibit_public_ip_on_vnic = true
  security_list_ids = [oci_core_vcn.OKE_MDS_vcn.default_security_list_id, oci_core_security_list.OKE_MDS_mds_subnet_sec_list.id]
  route_table_id    = oci_core_route_table.OKE_MDS_rt_via_natgw.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

