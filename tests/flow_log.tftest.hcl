provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}

run "invalid_name_prefix" {
  command = plan

  variables {
    flow_log = {
      name_prefix       = "a"
      traffic_type      = "ALL"
      retention_in_days = 1
    }
  }

  expect_failures = [var.flow_log]
}

run "invalid_traffic_type" {
  command = plan

  variables {
    flow_log = {
      name_prefix       = "abc"
      traffic_type      = "FOO"
      retention_in_days = 1
    }
  }

  expect_failures = [var.flow_log]
}

run "invalid_retention_in_days" {
  command = plan

  variables {
    flow_log = {
      name_prefix       = "abc"
      traffic_type      = "ALL"
      retention_in_days = 2
    }
  }

  expect_failures = [var.flow_log]
}

run "valid_flow_log" {
  command = plan

  variables {
    flow_log = {
      name_prefix       = "abc"
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
    flow_log = null
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
