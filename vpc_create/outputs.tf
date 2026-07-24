output "vpc_ids" {
  description = "Map of VPC name to its self-generated ID."
  value       = { for name, net in google_compute_network.this : name => net.id }
}

output "vpc_self_links" {
  description = "Map of VPC name to its self_link."
  value       = { for name, net in google_compute_network.this : name => net.self_link }
}

output "vpc_count" {
  description = "Number of VPCs created by this module."
  value       = length(google_compute_network.this)
}

output "subnet_ids" {
  description = "Map of '<vpc_name>/<subnet_name>' to subnetwork ID."
  value       = { for key, subnet in google_compute_subnetwork.this : key => subnet.id }
}

output "subnet_cidrs" {
  description = "Map of '<vpc_name>/<subnet_name>' to its CIDR range."
  value       = { for key, subnet in google_compute_subnetwork.this : key => subnet.ip_cidr_range }
}

output "subnet_regions" {
  description = "Map of '<vpc_name>/<subnet_name>' to its region."
  value       = { for key, subnet in google_compute_subnetwork.this : key => subnet.region }
}
