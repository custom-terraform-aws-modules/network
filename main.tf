################################
# VPC                          #
################################

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

################################
# Public Subnets               #
################################

resource "aws_subnet" "public" {
  # creates a subnet for each provided public CIDR
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = length(var.azs) > count.index ? var.azs[count.index] : null

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_route_table" "public" {
  # if no public subnet is created we don't need a route table
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# create NAT Gateway and public IP for it, if flag is true and a public subnet exists
resource "aws_eip" "main" {
  count  = var.nat_gw && length(var.public_subnets) > 0 ? 1 : 0
  domain = "vpc"

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.nat_gw && length(var.public_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.main[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

################################
# Private Subnets              #
################################

resource "aws_subnet" "private" {
  # creates a subnet for each provided private CIDR
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = length(var.azs) > count.index ? var.azs[count.index] : null

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_route_table" "private" {
  # if no private subnet is created we don't need a route table
  count  = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.nat_gw && length(var.public_subnets) > 0 ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# setting default route table of VPC
resource "aws_main_route_table_association" "main" {
  count          = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.private[0].id
}

################################
# Flow Log                     #
################################

data "aws_iam_policy_document" "assume_role" {
  count = var.flow_log != null ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "main" {
  count             = var.flow_log != null ? 1 : 0
  name              = "${try(var.flow_log["identifier"], "")}-flow-log"
  retention_in_days = try(var.flow_log["retention_in_days"], 1)

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

data "aws_iam_policy_document" "log" {
  count = var.flow_log != null ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["${aws_cloudwatch_log_group.main[0].arn}:*"]
  }
}

resource "aws_iam_role" "main" {
  count              = var.flow_log != null ? 1 : 0
  name               = "${try(var.flow_log["identifier"], "")}-ServiceRoleForFlowLog"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  inline_policy {
    name   = "${try(var.flow_log["identifier"], "")}-CloudWatchCreateLog"
    policy = data.aws_iam_policy_document.log[0].json
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_flow_log" "main" {
  count                    = var.flow_log != null ? 1 : 0
  vpc_id                   = aws_vpc.main.id
  traffic_type             = try(var.flow_log["traffic_type"], "ALL")
  iam_role_arn             = aws_iam_role.main[0].arn
  log_destination          = aws_cloudwatch_log_group.main[0].arn
  max_aggregation_interval = 60

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}
