provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "no_nat_gw" {
  command = plan

  variables {
    identifier = "test"
    nat_gws    = 0
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 0
    error_message = "NAT Gateway was created unexpectedly"
  }
}

run "multiple_nat_gws" {
  command = plan

  variables {
    identifier = "test"
    nat_gws    = 5
    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24",
      "10.0.4.0/24",
      "10.0.5.0/24"
    ]
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 5
    error_message = "NAT Gateways were not created"
  }
}

run "private_subnets_greater_then_nat_gws" {
  command = plan

  variables {
    identifier = "test"
    nat_gws    = 3
    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24"
    ]
    private_subnets = [
      "10.0.4.0/24",
      "10.0.5.0/24",
      "10.0.6.0/24",
      "10.0.7.0/24",
      "10.0.8.0/24"
    ]
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 3
    error_message = "NAT Gateways were not created"
  }

  assert {
    condition     = local.nat_gw_indices[0] == 0
    error_message = "NAT Gateway index of first private subnet wrong, want: 0, got: ${local.nat_gw_indices[0]}"
  }

  assert {
    condition     = local.nat_gw_indices[1] == 1
    error_message = "NAT Gateway index of second private subnet wrong, want: 1, got: ${local.nat_gw_indices[0]}"
  }

  assert {
    condition     = local.nat_gw_indices[2] == 2
    error_message = "NAT Gateway index of third private subnet wrong, want: 2, got: ${local.nat_gw_indices[0]}"
  }

  assert {
    condition     = local.nat_gw_indices[3] == 0
    error_message = "NAT Gateway index of fourth private subnet wrong, want: 0, got: ${local.nat_gw_indices[0]}"
  }

  assert {
    condition     = local.nat_gw_indices[4] == 1
    error_message = "NAT Gateway index of fifth private subnet wrong, want: 1, got: ${local.nat_gw_indices[0]}"
  }
}

run "private_subnets_less_then_nat_gws" {
  command = plan

  variables {
    identifier = "test"
    nat_gws    = 5
    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24",
      "10.0.4.0/24",
      "10.0.5.0/24"
    ]
    private_subnets = [
      "10.0.6.0/24",
      "10.0.7.0/24",
      "10.0.8.0/24",
    ]
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 5
    error_message = "NAT Gateways were not created"
  }

  assert {
    condition     = local.nat_gw_indices[0] == 0
    error_message = "NAT Gateway index of first private subnet wrong, want: 0, got: ${local.nat_gw_indices[0]}"
  }

  assert {
    condition     = local.nat_gw_indices[1] == 1
    error_message = "NAT Gateway index of second private subnet wrong, want: 1, got: ${local.nat_gw_indices[1]}"
  }

  assert {
    condition     = local.nat_gw_indices[2] == 2
    error_message = "NAT Gateway index of third private subnet wrong, want: 2, got: ${local.nat_gw_indices[2]}"
  }
}
