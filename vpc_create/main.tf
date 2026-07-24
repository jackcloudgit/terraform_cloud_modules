provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  # Index VPC definitions by name for for_each.
  vpcs_by_name = { for vpc in var.vpcs : vpc.name => vpc }

  # Flatten every subnet across every VPC into a single map keyed by
  # "<vpc_name>/<subnet_name>" so each subnet resource has a stable address.
  subnets_flat = merge([
    for vpc in var.vpcs : {
      for subnet in vpc.subnets : "${vpc.name}/${subnet.name}" => merge(subnet, {
        vpc_name = vpc.name
        region   = coalesce(subnet.region, var.region)
      })
    }
  ]...)
}

resource "google_compute_network" "this" {
  for_each = local.vpcs_by_name

  name                    = "${var.name_prefix}-${each.value.name}"
  project                 = var.project_id
  auto_create_subnetworks = each.value.auto_create_subnetworks
  routing_mode            = each.value.routing_mode
  mtu                     = each.value.mtu
}

resource "google_compute_subnetwork" "this" {
  for_each = local.subnets_flat

  name                     = "${var.name_prefix}-${each.value.vpc_name}-${each.value.name}"
  project                  = var.project_id
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.this[each.value.vpc_name].id
  private_ip_google_access = each.value.private_ip_google_access
}

resource "google_compute_firewall" "ssh" {
  for_each = var.allow_ssh ? local.vpcs_by_name : {}

  name    = "${var.name_prefix}-${each.value.name}-allow-ssh"
  project = var.project_id
  network = google_compute_network.this[each.value.name].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "icmp" {
  for_each = var.allow_icmp ? local.vpcs_by_name : {}

  name    = "${var.name_prefix}-${each.value.name}-allow-icmp"
  project = var.project_id
  network = google_compute_network.this[each.value.name].name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["icmp"]
}
