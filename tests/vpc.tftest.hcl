provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "invalid_identifier" {
  command = plan

  variables {
    identifier = "a"
  }

  expect_failures = [var.identifier]
}

run "invalid_vpc_cidr" {
  command = plan

  variables {
    identifier = "test"
    cidr       = "10.0.0.0/34"
  }

  expect_failures = [var.cidr]
}

run "valid_vpc_cidr" {
  command = plan

  variables {
    identifier = "test"
    cidr       = "10.0.0.0/16"
  }
}
