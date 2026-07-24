# vpc_create

Creates one or more Google Cloud VPC networks, each with one or more
subnetworks, using fully variablized inputs. Supports:

- Any number of VPCs (driven by the length of `var.vpcs`)
- Any number of subnets per VPC, each with its own CIDR range
- Per-subnet region selection (falls back to `var.region` if not set)
- Optional SSH / ICMP firewall rules per VPC

## Usage

```hcl
module "vpc_create" {
  source  = "app.terraform.io/<YOUR-ORG>/vpc-create/google"
  version = "~> 0.1"

  project_id  = "my-project-id"
  name_prefix = "demo"
  region      = "us-central1"

  vpcs = [
    {
      name = "app"
      subnets = [
        { name = "subnet-a", cidr = "10.10.0.0/24", region = "us-central1" },
        { name = "subnet-b", cidr = "10.10.1.0/24", region = "us-east1" },
      ]
    },
    {
      name = "data"
      subnets = [
        { name = "subnet-a", cidr = "10.20.0.0/24" },
      ]
    },
  ]
}
```

## Inputs

| Name              | Description                                                        | Type           | Default        |
|--------------------|--------------------------------------------------------------------|----------------|----------------|
| project_id         | GCP project ID                                                     | string         | n/a (required) |
| name_prefix        | Prefix applied to VPC and subnet names                             | string         | `"demo"`       |
| region             | Default region used when a subnet does not specify one             | string         | `"us-central1"`|
| vpcs               | List of VPC objects, each with a `name` and list of `subnets`       | list(object)   | n/a (required) |
| allow_ssh          | Create a firewall rule allowing inbound tcp/22 per VPC              | bool           | `true`         |
| allow_icmp         | Create a firewall rule allowing inbound ICMP per VPC                 | bool           | `true`         |
| ssh_source_ranges  | Source IP ranges allowed for the SSH firewall rule                  | list(string)   | `["0.0.0.0/0"]`|

Each entry in `vpcs[*].subnets` supports:

| Name                      | Description                                   | Type   | Default            |
|---------------------------|------------------------------------------------|--------|---------------------|
| name                      | Subnet name (unique within its VPC)            | string | n/a (required)      |
| cidr                      | CIDR range for the subnet                      | string | n/a (required)      |
| region                    | Region for the subnet                          | string | `var.region`        |
| private_ip_google_access  | Enable Private Google Access on the subnet     | bool   | `true`              |

## Outputs

| Name             | Description                                            |
|------------------|---------------------------------------------------------|
| vpc_ids          | Map of VPC name to VPC ID                               |
| vpc_self_links   | Map of VPC name to VPC self_link                         |
| vpc_count        | Number of VPCs created                                   |
| subnet_ids       | Map of `<vpc_name>/<subnet_name>` to subnetwork ID        |
| subnet_cidrs     | Map of `<vpc_name>/<subnet_name>` to CIDR range            |
| subnet_regions   | Map of `<vpc_name>/<subnet_name>` to region                 |
