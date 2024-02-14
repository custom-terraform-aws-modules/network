provider "aws" {
    region = "eu-central-1"
    default_tags {
      tags = {
        Environment = "Test"
      }
    }
}

run "valid_vpc_cidr" {
    command = plan

    variables {
        cidr = "10.0.0.0/16"
    }
}

run "invalid_vpc_cidr" {
    command = plan

    variables {
        cidr = "10.0.0.0/34"
    }

    expect_failures = [var.cidr]
}

run "valid_public_subnets" {
    command = plan

    variables {
        public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    }
}

run "invalid_public_subnets" {
    command = plan

    variables {
        public_subnets = ["10.0.0.0", "10.0.1.0/24"]
    }

    expect_failures = [var.public_subnets]
}

run "valid_private_subnets" {
    command = plan

    variables {
        private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    }
}

run "invalid_private_subnets" {
    command = plan

    variables {
        private_subnets = ["10.0.0.0", "10.0.1.0/24",]
    }

    expect_failures = [var.private_subnets]
}
