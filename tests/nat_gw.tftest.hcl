provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "no_public_subnet" {
  command = plan

  variables {
    public_subnets = []
    nat_gw         = true
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 0
    error_message = "NAT Gateway was created without a public subnet"
  }
}

run "valid_nat_gw" {
  command = plan

  variables {
    public_subnets = ["10.0.1.0/24"]
    nat_gw         = true
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 1
    error_message = "NAT Gateway was not created"
  }
}
