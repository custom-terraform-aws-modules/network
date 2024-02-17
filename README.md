# Module: Network

![Network visualized](.github/diagrams/network-transparent.png)

This module provides a VPC with variable public and private subnets in it. The traffic of the public subnets is directly routed through the Internet Gateway and the resources in it are therefore exposed to the public internet. The traffic of the private subnets will be routed through a NAT Gateway, which will live in the first public subnet.

## Contents

- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Example](#example)
- [Contributing](#contributing)

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 5.20 |

## Inputs

| Name            | Description                                                                                                                          | Type           | Default       | Required |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------------- | ------------- | :------: |
| name            | Name of this module, which is used as identifier on all resources.                                                                   | `string`       | ""            |    no    |
| cidr            | The IPv4 CIDR block of the VPC.                                                                                                      | `string`       | "10.0.0.0/16" |    no    |
| azs             | A list of availability zone names in the region.                                                                                     | `list(string)` | []            |    no    |
| public_subnets  | A list of CIDR blocks for the public subnets inside the VPC.                                                                         | `list(string)` | []            |    no    |
| private_subnets | A list of CIDR blocks for the private subnets inside the VPC.                                                                        | `list(string)` | []            |    no    |
| nat_gw          | A flag for wether or not creating a NAT Gateway in the first public subnet in order to route the private subnets traffic through it. | `bool`         | false         |    no    |
| flow_log        | An object for the definition for a flow log of the VPC.                                                                              | `object`       | null          |    no    |
| tags            | A map of tags to add to all resources. Name is always set as tag and the other tags will be appended.                                | `map(string)`  | {}            |    no    |

### `flow_log`

| Name              | Description                                                                                                                | Type     | Default | Required |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| identifier        | Unique identifier to differentiate global resources.                                                                       | `string` | n/a     |   yes    |
| traffic_type      | The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL.                                                          | `string` | n/a     |   yes    |
| retention_in_days | Specifies the number of days the log events shall be retained. Valid values: 1, 3, 5, 7, 14, 30, 365 and 0 (never expire). | `number` | n/a     |   yes    |

## Outputs

| Name            | Description                         |
| --------------- | ----------------------------------- |
| id              | The ID of the VPC.                  |
| public_subnets  | List of IDs of the public subnets.  |
| private_subnets | List of IDs of the private subnets. |
| internet_gw     | The ID of the Internet Gateway.     |
| nat_gw          | The ID of the NAT Gateway.          |

## Example

```hcl
module "network" {
  source = "github.com/custom-terraform-aws-modules/network"

  name            = "example-network"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  nat_gw          = true
  flow_log = {
    identifier        = "example-network-dev"
    traffic_type      = "ALL"
    retention_in_days = 7
  }

  tags = {
    Project     = "example-project"
    Environment = "prod"
  }
}
```

## Contributing

In order for a seamless CI workflow copy the `pre-commit` git hook from `.github/hooks` into your local `.git/hooks`. The hook formats the terraform code automatically before each commit.

```bash
cp ./.github/hooks/pre-commit ./.git/hooks/pre-commit
```
