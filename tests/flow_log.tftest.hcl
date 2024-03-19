provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "invalid_traffic_type" {
  command = plan

  variables {
    identifier = "test"

    log_config = {
      traffic_type      = "FOO"
      retention_in_days = 1
    }
  }

  expect_failures = [var.log_config]
}

run "invalid_retention_in_days" {
  command = plan

  variables {
    identifier = "test"

    log_config = {
      traffic_type      = "ALL"
      retention_in_days = 2
    }
  }

  expect_failures = [var.log_config]
}

run "valid_flow_log" {
  command = plan

  variables {
    identifier = "test"

    log_config = {
      traffic_type      = "ALL"
      retention_in_days = 1
    }
  }

  assert {
    condition     = length(aws_flow_log.main) == 1
    error_message = "Flow log was not created"
  }

  assert {
    condition     = length(aws_iam_role.main) == 1
    error_message = "IAM role for flow log was not created"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.main) == 1
    error_message = "CloudWatch log group for flow log was not created"
  }
}

run "no_flow_log" {
  command = plan

  variables {
    identifier = "test"

    log_config = null
  }

  assert {
    condition     = length(aws_flow_log.main) == 0
    error_message = "Flow log was created unexpectedly"
  }

  assert {
    condition     = length(aws_iam_role.main) == 0
    error_message = "IAM role for flow log was created unexpectedly"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.main) == 0
    error_message = "CloudWatch log group for flow log was created unexpectedly"
  }
}
