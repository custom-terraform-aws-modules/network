output "id" {
  description = "The ID of the VPC."
  value       = try(aws_vpc.main.id, null)
}

output "public_subnets" {
  description = "List of IDs of the public subnets."
  value       = try(aws_subnet.public[*].id, [])
}

output "private_subnets" {
  description = "List of IDs of the private subnets."
  value       = try(aws_subnet.private[*].id, [])
}

output "internet_gw" {
  description = "The ID of the Internet Gateway."
  value       = try(aws_internet_gateway.main.id, null)
}

output "nat_gws" {
  description = "List of IDs of the NAT Gateways."
  value       = try(aws_nat_gateway.main[*].id, [])
}

output "log_group_name" {
  description = "The name of the CloudWatch log group created for the VPC flow logs."
  value       = try(aws_cloudwatch_log_group.main[0].name, null)
}
