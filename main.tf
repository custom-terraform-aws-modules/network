################################
# VPC                          #
################################

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = var.tags
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
    { "kubernetes.io/role/elb" = "1" },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route_table" "public" {
  # if no public subnet is created we don't need a route table
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = var.tags
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# create NAT Gateways and public IPs for them
resource "aws_eip" "main" {
  count  = var.nat_gws
  domain = "vpc"

  tags = var.tags
}

resource "aws_nat_gateway" "main" {
  count         = var.nat_gws
  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = var.tags
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
    { "kubernetes.io/role/internal-elb" = "1" },
    var.tags
  )
}

locals {
  nat_gw_indices = [for index, value in var.private_subnets : index % var.nat_gws]
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.nat_gws > 0 ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.main[local.nat_gw_indices[count.index]].id
    }
  }

  tags = var.tags
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

################################
# Flow Log                     #
################################

data "aws_iam_policy_document" "assume_role" {
  count = var.log_config != null ? 1 : 0

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
  count             = var.log_config != null ? 1 : 0
  name              = "${var.identifier}-flow-log"
  retention_in_days = try(var.log_config["retention_in_days"], null)

  tags = var.tags
}

data "aws_iam_policy_document" "log" {
  count = var.log_config != null ? 1 : 0

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
  count              = var.log_config != null ? 1 : 0
  name               = "${var.identifier}-ServiceRoleForFlowLog"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  inline_policy {
    name   = "${var.identifier}-CloudWatchCreateLog"
    policy = data.aws_iam_policy_document.log[0].json
  }

  tags = var.tags
}

resource "aws_flow_log" "main" {
  count                    = var.log_config != null ? 1 : 0
  vpc_id                   = aws_vpc.main.id
  traffic_type             = try(var.log_config["traffic_type"], null)
  iam_role_arn             = aws_iam_role.main[0].arn
  log_destination          = aws_cloudwatch_log_group.main[0].arn
  max_aggregation_interval = 60

  tags = var.tags
}
