variable "project_id" {
  description = "GCP project ID where VPC resources are created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used when naming VPCs and subnets."
  type        = string
  default     = "demo"
}

variable "region" {
  description = "Default GCP region used for subnets that do not specify their own region."
  type        = string
  default     = "us-central1"
}

variable "vpcs" {
  description = <<-EOT
    List of VPC networks to create. The number of VPCs created equals the length
    of this list. Each VPC can define one or more subnets, each with its own
    CIDR range and region.
  EOT
  type = list(object({
    name                    = string
    auto_create_subnetworks = optional(bool, false)
    routing_mode            = optional(string, "REGIONAL")
    mtu                     = optional(number, 1460)
    subnets = list(object({
      name                     = string
      cidr                     = string
      region                   = optional(string)
      private_ip_google_access = optional(bool, true)
    }))
  }))

  validation {
    condition     = length(var.vpcs) > 0
    error_message = "At least one VPC must be defined in var.vpcs."
  }

  validation {
    condition = alltrue([
      for vpc in var.vpcs : length(vpc.subnets) > 0
    ])
    error_message = "Each VPC must define at least one subnet."
  }

  validation {
    condition = alltrue(flatten([
      for vpc in var.vpcs : [
        for subnet in vpc.subnets : can(cidrhost(subnet.cidr, 0))
      ]
    ]))
    error_message = "Each subnet cidr must be a valid CIDR range (e.g. 10.0.0.0/24)."
  }

  validation {
    condition     = length(distinct([for vpc in var.vpcs : vpc.name])) == length(var.vpcs)
    error_message = "VPC names must be unique within var.vpcs."
  }
}

variable "allow_ssh" {
  description = "Whether to create a firewall rule allowing inbound SSH (tcp/22) on each VPC."
  type        = bool
  default     = true
}

variable "allow_icmp" {
  description = "Whether to create a firewall rule allowing inbound ICMP on each VPC."
  type        = bool
  default     = true
}

variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for the SSH firewall rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
