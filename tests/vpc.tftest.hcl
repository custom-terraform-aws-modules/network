provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "invalid_vpc_cidr" {
  command = plan

  variables {
    cidr = "10.0.0.0/34"
  }

  expect_failures = [var.cidr]
}

run "valid_vpc_cidr" {
  command = plan

  variables {
    cidr = "10.0.0.0/16"
  }
}
