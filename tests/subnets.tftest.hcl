provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

################################
# Public Subnets               #
################################

run "invalid_public_subnets" {
  command = plan

  variables {
    public_subnets = ["10.0.0.0", "10.0.1.0/24"]
  }

  expect_failures = [var.public_subnets]
}

run "valid_public_subnets" {
  command = plan

  variables {
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  assert {
    condition     = length(aws_subnet.public) == length(var.public_subnets)
    error_message = "Public subnet was not created for every public CIDR"
  }
}

################################
# Private Subnets              #
################################

run "invalid_private_subnets" {
  command = plan

  variables {
    private_subnets = ["10.0.0.0", "10.0.1.0/24", ]
  }

  expect_failures = [var.private_subnets]
}

run "valid_private_subnets" {
  command = plan

  variables {
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  assert {
    condition     = length(aws_subnet.private) == length(var.private_subnets)
    error_message = "Private subnet was not created for every private CIDR"
  }
}
