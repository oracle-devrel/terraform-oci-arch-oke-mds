## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "availability_domain_name" {
  default = ""
}

variable "availablity_domain_number" {
  default = 0
}

variable "ssh_public_key" {
  default = ""
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0"
}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "OKE_LB_Subnet-CIDR" {
  default = "10.0.10.0/24"
}

variable "OKE_API_EndPoint_Subnet-CIDR" {
  default = "10.0.20.0/24"
}

variable "OKE_NodePool_Subnet-CIDR" {
  default = "10.0.30.0/24"
}

variable "Bastion_Subnet-CIDR" {
  default = "10.0.40.0/24"
}

variable "MDS_Subnet-CIDR" {
  default = "10.0.50.0/24"
}

variable "BastionShape" {
  default = "VM.Standard.E4.Flex"
}

variable "BastionFlexShapeOCPUS" {
  default = 1
}

variable "BastionFlexShapeMemory" {
  default = 1
}

variable "cluster_kube_config_token_version" {
  default = "2.0.0"
}

variable "cluster_options_kubernetes_network_config_pods_cidr" {
  default = "10.244.0.0/16"
}

variable "cluster_options_kubernetes_network_config_services_cidr" {
  default = "10.96.0.0/16"
}

variable "node_pool_size" {
  default = 3
}

variable "kubernetes_version" {
  default = "v1.21.5"
}

variable "node_pool_name" {
  default = "OKEMDS_Pool"
}

variable "node_pool_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "instance_os" {
  default = "Oracle Linux"
}

variable "linux_os_version" {
  default = "7.9"
}

variable "node_pool_flex_shape_memory" {
  default = 6
}

variable "node_pool_flex_shape_ocpus" {
  default = 1
}

variable "cluster_name" {
  default = "okemdscluster"
}

variable "admin_password" {
  description = "Password for the admin user for MySQL Database Service"
}

variable "admin_username" {
  description = "MySQL Database Service Username"
  default = "admin"
}

variable "mysql_shape" {
    default = "MySQL.VM.Standard.E3.1.8GB"
}

variable "mysql_db_system_data_storage_size_in_gb" {
  default = 50
}

variable "mysql_db_system_description" {
  description = "MySQL DB System description"
  default = "MySQL DB System description"
}

variable "mysql_db_system_display_name" {
  description = "MySQL DB System display name"
  default = "OKE-MDS"
}

variable "mysql_db_system_fault_domain" {
  description = "The fault domain on which to deploy the Read/Write endpoint. This defines the preferred primary instance."
  default = "FAULT-DOMAIN-1"
}                  

variable "mysql_db_system_hostname_label" {
  description = "The hostname for the primary endpoint of the DB System. Used for DNS. The value is the hostname portion of the primary private IP's fully qualified domain name (FQDN) (for example, dbsystem-1 in FQDN dbsystem-1.subnet123.vcn1.oraclevcn.com). Must be unique across all VNICs in the subnet and comply with RFC 952 and RFC 1123."
  default = "okemds"
}
   
variable "mysql_db_system_maintenance_window_start_time" {
  description = "The start of the 2 hour maintenance window. This string is of the format: {day-of-week} {time-of-day}. {day-of-week} is a case-insensitive string like mon, tue, etc. {time-of-day} is the Time portion of an RFC3339-formatted timestamp. Any second or sub-second time data will be truncated to zero."
  default = "SUNDAY 14:30"
}

variable "mysql_is_highly_available" {
  default = false
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.node_pool_shape)
}
